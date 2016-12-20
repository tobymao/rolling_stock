require './models/base'

class Game < Base
  many_to_one :user
  one_to_many :actions

  PHASE_NAME = {
    1 => 'Issue New Shares',
    2 => 'Form Corporations',
    3 => 'Auctions And Share Trading',
    4 => 'Determine New Player Order',
    5 => 'Foreign Investor Buys Companies',
    6 => 'Corporations Buys Companies',
    7 => 'Close Companies',
    8 => 'Collect Income',
    9 => 'Pay Dividends And Adjust Share Prices',
    10 => 'Check Game End',
  }.freeze

  attr_reader(
    :share_prices,
    :available_corporations,
    :corporations,
    :companies,
    :pending_companies,
    :company_deck,
    :current_bid,
    :offers,
    :foreign_investor,
    :round,
    :phase,
  )

  def self.empty_game user
    Game.create(
      user: user,
      users: [user.id],
      version: '1.0',
      settings: '',
      state: 'new',
      deck: [],
    )
  end

  def load
    @share_prices = SharePrice.initial_market
    @available_corporations = Corporation::CORPORATIONS.dup
    @corporations = []
    @companies = [] # available companies
    @pending_companies = []
    @company_deck = []
    @current_bid = nil
    @offers = []
    @foreign_investor = ForeignInvestor.new
    @round = 1
    @phase = 1
    @end_game_card = :penultimate

    start_game unless new_game?
  end

  def start_game
    setup_deck
    draw_companies
    untap_pending_companies
    step
    process_actions
  end

  def players
    @_players ||= User
      .where(id: users.to_a)
      .map { |user| Player.new(user.id, user.name) }
      .each_with_index { |p, i| p.order = i }
      .sort_by(&:order)
  end

  def players_in_order
    players.sort_by &:order
  end

  def player_by_user user
    player_by_id user.id
  end

  def player_by_id id
    players.find { |p| p.id == id.to_i }
  end

  def new_game?
    state == 'new'
  end

  def active?
    state == 'active'
  end

  def finished?
    state == 'finished'
  end

  def phase_name
    PHASE_NAME[@phase]
  end

  def active_entities
    case @phase
    when 1
      active_corporations.select &:can_issue_share?
    when 6, 9
      active_corporations
    when 2
      active_player_companies
    when 3
      # check if player doesn't have enough money to buy anything
      players.select &:active?
    when 7
      active_companies
    end
  end

  def active_corporations
    @corporations.select &:active?
  end

  def active_companies
    held_companies.select &:active?
  end

  def active_player_companies
    player_companies.select &:active?
  end

  def player_companies
    players.flat_map(&:companies).sort_by(&:value).reverse
  end

  def acting
    case @phase
    when 1, 2, 3, 9
      active_entities.slice(0..0)
    when 6, 7
      active_entities
    end
  end

  def can_act? player
    acting.any? { |e| e.owned_by? player } ||
      @offers.find { |o| o.company.owned_by? player }
  end

  def held_companies
    @corporations.flat_map(&:companies) + players.flat_map(&:companies)
  end

  def ownership_tier
    if @company_deck.empty?
      @end_game_card
    else
      @company_deck.first.tier
    end
  end

  def step
    current_phase = @phase

    case @phase
    when 1
      check_phase_change @corporations.reject { |c| c.shares.empty? }
    when 2
      check_phase_change players.flat_map(&:companies)
    when 3
      check_no_player_purchases
    when 4
      new_player_order
    when 5
      foreign_investor_purchase
    when 6
      check_no_company_purchases
    when 7
      check_phase_change held_companies
    when 8
      collect_income
    when 9
      check_phase_change @corporations.reject { |c| c.cash.zero? }
    when 10
      check_end
    end

    step if @phase != current_phase
  end

  def process_actions
    actions.sort_by { |action| [action.round, action.phase] }.each do |action|
      raise 'Invalid action for phase' if action.phase != @phase
      action.turns.each { |turn| process_action_data turn }
    end
  end

  def process_action_data data
    if data['action'] == 'pass'
      entities = [
        active_companies.select { |c| data['company'] == c.name },
        player_by_id(data['player']),
        @corporations.select { |c| data['corporation'] ==  c.name },
      ].flatten.compact

      entities.each do |entity|
        raise 'Already passed' if entity.passed?
        entity.pass
      end
    else
      send "process_phase_#{@phase}", data
    end

    step
  end

  # phase 1
  def process_phase_1 data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    corporation.pass
    raise unless corporation.can_issue_share?
    corporation.issue_share
    check_bankruptcy corporation
  end

  # phase 2
  def process_phase_2 data
    name = data['corporation']
    share_price = @share_prices.find { |sp| sp.price == data['price'].to_i }
    company = active_player_companies.find { |c| c.name == data['company'] }
    raise if share_price.corporation
    raise unless @available_corporations.include? name
    raise unless share_price.valid_range? company
    company.pass
    @available_corporations.delete name
    @corporations << Corporation.new(name, company, share_price, @share_prices)
  end

  # phase 3
  def process_phase_3 data
    player = player_by_id data['player']
    action = data['action']
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    raise 'Not your turn' unless can_act? player
    raise 'You must bid or pass' if @current_bid && action != 'bid'
    raise unless player

    case action
    when 'bid'
      company = @companies.find { |c| c.name == data['company'] }
      raise unless company
      players.each &:unpass unless @current_bid
      bid_company player, company, data['price'].to_i
    when 'buy'
      buy_share player, corporation
      player.unpass
    when 'sell'
      sell_share player, corporation
      player.unpass
    else
      raise 'Unspecified action'
    end

    restart_order player
  end

  def buy_share player, corporation
    raise unless corporation.can_buy_share?
    corporation.buy_share player
  end

  def sell_share player, corporation
    raise unless corporation.can_sell_share? player
    corporation.sell_share player
    check_bankruptcy corporation
  end

  def bid_company player, company, price
    raise 'Bid must be greater than value' if price < company.value
    raise 'Bid must not be more than cash on hand' if price > player.cash

    if @current_bid
      raise 'Must bid on same company' if @current_bid.company != company
      raise 'Bid must be greater than previous' if price < @current_bid.price
    else
      @auction_starter = player
    end

    @current_bid = Bid.new player, company, price
  end

  def finalize_auction
    company = @current_bid.company
    @current_bid.player.buy_company company, @current_bid.price
    draw_companies
    players.each &:unpass
    restart_order @auction_starter
    @auction_starter = nil
    @current_bid = nil
    check_no_player_purchases
  end

  def restart_order player
    players.rotate!
    restart_order player if player != players.last
  end

  # phase 4
  def new_player_order
    players.sort_by!(&:cash).reverse!
    players.each_with_index { |p, i| p.order = i }
    @phase += 1
  end

  # phase 5
  def foreign_investor_purchase
    @foreign_investor.purchase_companies @companies
    draw_companies
    untap_pending_companies
    @phase += 1
  end

  # phase 6
  # corporations buy companies
  # todo: don't allow multi movement of cash and companies
  def process_phase_6 data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    companies = held_companies + @foreign_investor.companies
    company = companies.find { |c| c.name == data['company'] }
    offer = @offers.find do |o|
      (o.corporation == corporation && o.company == company) ||
        (o.company == company && o.foreign_purchase?)
    end
    owner = company.owner
    raise "Can't sell last company" if owner.is_a?(Corporation) && owner.companies.size == 1

    case data['action']
    when 'accept'
      offer.suitors.delete corporation

      if !offer.foreign_purchase? || offer.suitors.empty?
        corporation.buy_company company, offer.price
      end
    when 'decline'
      offer.suitors.delete corporation

      if offer.foreign_purchase?
        offer.corporation.buy_company(company, offer.price) if offer.suitors.empty?
      else
        @offers.delete offer
      end
    else
      price = data['price'].to_i
      raise "Not a valid price" unless company.valid_price? price
      raise "Already have an offer" if @offers.any? { |o| o.corporation == corporation && o.company == company}

      suitors = @corporations.select do |c|
        c.price > corporation.price && c.owner != corporation.owner
      end if owner.is_a? ForeignInvestor

      if suitors && suitors.empty?
        raise 'Foreign Investor purchase must be max price' if price != company.max_price
        corporation.buy_company company, price
      elsif corporation.owner != owner
        @offers << Offer.new(corporation, company, price, suitors)
      else
        corporation.buy_company company, price
      end
    end
  end

  # phase 7
  # todo check if you can close other people's company
  # solve this buy passing current_user into external action
  def process_phase_7 data
    company = held_companies.find { |c| c.name == data['company'] }
    company.owner.close_company company
  end

  # phase 8
  def collect_income
    @foreign_investor.close_companies ownership_tier
    entities = @corporations + players + [@foreign_investor]
    entities.each { |entity| entity.collect_income ownership_tier }
    sort_corporations
    @phase += 1
  end

  # phase 9
  def process_phase_9 data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    raise 'Not corporation turn' unless acting.include? corporation
    corporation.pass
    corporation.pay_dividend data['amount'].to_i, players
    check_bankruptcy corporation
  end

  # phase 10
  def check_end
    @end_game_card = :last_turn if ownership_tier == :penultimate
    sort_corporations

    if ownership_tier == :last_turn || @share_prices.last.nil?
      update(state: :finished)
    else
      @phase = 1
      @round += 1
    end
  end

  private

  def setup_deck
    if deck.size.zero?
      groups = Company.all.values.group_by &:tier

      Company::TIERS.each do |tier|
        num_cards = players.size + 1
        num_cards = 6 if tier == :orange && players.size == 4
        num_cards = 8 if tier == :orange && players.size == 5
        @company_deck.concat(groups[tier].shuffle.take num_cards)
      end

      update deck: @company_deck.map(&:name)
    else
      @company_deck = deck.map { |sym| Company.new self, sym, *Company::COMPANIES[sym] }
    end
  end

  def draw_companies
    num = players.size - @companies.size - @pending_companies.size
    @pending_companies.concat @company_deck.shift(num)
  end

  def untap_pending_companies
    @companies.concat @pending_companies.slice!(0..-1)
  end

  def unpass_all
    (players + held_companies + @corporations).each &:unpass
  end

  def sort_corporations
    @corporations.sort_by!(&:price).reverse!
  end

  def check_phase_change passers
    return unless passers.all? &:passed?
    unpass_all
    @phase += 1
  end

  def check_no_player_purchases
    if @current_bid
      eligible = players.reject { |p| p == @current_bid.player || p.cash < @current_bid.price }
      finalize_auction if eligible.all? &:passed?
    else
      min = [
        @corporations.select(&:can_buy_share?).map { |c| c.next_share_price.price }.min,
        @companies.map(&:value).min,
        99999,
      ].compact.min

      check_phase_change players.reject { |p| p.cash < min && p.shares.empty? }
    end
  end

  def check_no_company_purchases
    min = [
      players.flat_map { |p| p.companies.map &:min_price }.min,
      @corporations.reject { |c| c.companies.size == 1 }.flat_map { |p| p.companies.map &:min_price }.min,
      @foreign_investor.companies.map(&:min_price).min,
      99999,
    ].compact.min

    check_phase_change @corporations.reject { |c| c.cash < min }
  end

  def check_bankruptcy corporation
    return unless corporation.is_bankrupt?
    @corporations.drop corporation
    @available_corporations << corporation.name
    players.each do |player|
      player.shares.reject! { |share| share.corporation == corporation }
    end
    @share_prices[corporation.share_price.index] = corporation.share_price
  end
end
