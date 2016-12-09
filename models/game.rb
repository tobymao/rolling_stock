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
    :stock_market,
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
    @stock_market = SharePrice.initial_market
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
    setup_deck
    draw_companies
    untap_pending_companies
    step
    process_actions
  end

  def players
    users_array = users.to_a

    @_players ||= User
      .where(id: users_array)
      .map { |user| Player.new(user.id, user.name) }
      .sort_by { |p| users_array.find_index p.id }
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
    when 1, 6, 9
      active_corporations
    when 2
      active_player_companies
    when 3
      players.select &:active?
    when 7
      active_companies
    end
  end

  # todo get rid of this sort
  def active_corporations
    @corporations.sort_by(&:price).reverse.select &:active?
  end

  def active_companies
    held_companies.select &:active?
  end

  def active_player_companies
    players.flat_map(&:companies).sort_by(&:value).reverse.select &:active?
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
    acting.any? { |e| e.owned_by? player }
  end

  def held_companies
    @corporations.flat_map(&:companies) + players.flat_map(&:companies)
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
      puts "** #{action.phase} - #{@phase}"
      raise 'Invalid action for phase' if action.phase != @phase
      action.turns.each { |turn| process_action_data turn }
    end
  end

  # todo fix auto passing on corps and stuff
  def process_action_data data
    if data['action'] == 'pass'
      entities = [
        active_companies.select { |c| data['company']&.include? c.symbol },
        player_by_id(data['player']&.first),
        @corporations.select { |c| data['corporation']&.include? c.name },
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
    issue_share corporation
  end

  def issue_share corporation
    raise unless corporation.can_issue_share?
    corporation.issue_share
    check_bankruptcy corporation
  end

  # phase 2
  def process_phase_2 data
    corporation = data['corporation']
    share_price = @stock_market.find { |sp| sp.price == data['price'].to_i }
    company = active_player_companies.find { |c| c.symbol == data['company'] }
    company.pass
    form_corporation company, share_price, corporation
  end

  def form_corporation company, share_price, corporation_name
    raise unless @available_corporations.include? corporation_name
    raise unless share_price.valid_range? company
    @available_corporations.delete corporation_name
    @corporations << Corporation.new(corporation_name, company, share_price, @stock_market)
  end

  # phase 3
  def process_phase_3 data
    player = player_by_id data['player']
    action = data['action']
    raise 'Not your turn' unless can_act? player
    raise 'You must bid or pass' if @current_bid && action != 'bid'

    case action
    when 'bid'
      company = @companies.find { |c| c.symbol == data['company'] }
      players.each &:unpass unless @current_bid
      bid_company player, company, data['price']
    when 'buy'
      buy_share player, data['corporation']
      player.unpass
    when 'sell'
      sell_share player, data['corporation']
      player.unpass
    else
      raise 'Unspecified action'
    end

    players.rotate!
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
    price = price.to_i

    if @current_bid
      raise 'Must bid on same company' if @current_bid.company != company
      raise 'Bid must be greater than previous' unless @current_bid.price < price
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
    restart_order
    @auction_starter = nil
    @current_bid = nil
  end

  def restart_order
    players.rotate!
    restart_order if @auction_starter != players.first
  end

  # phase 4
  def new_player_order
    players.sort_by(&:cash).reverse!
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
    company = companies.find { |c| c.symbol == data['company'] }
    offer = @offers.find { |o| o.corporation == corporation && o.company == company }
    owner = company.owner
    raise "Can't sell last company" if owner.is_a?(Corporation) && owner.companies.size == 1

    case data['action']
    when 'accept'
      corporation.buy_company company, offer.price
    when 'decline'
      @offers.delete offer
    else
      price = data['price'].to_i
      raise "Not a valid price" unless company.valid_price? price
      raise "Already have an offer" if @offers.any? { |o| o.corporation == corporation && o.company == company}

      if corporation.president != company.owner
        @offers << Offer.new(corporation, company, price)
      else
        corporation.buy_company company, price
      end
    end
  end

  # phase 7
  # todo check if you can close other people's company
  # solve this buy passing current_user into external action
  def process_phase_7 data
    company = held_companies.find { |c| c.symbol == data['company'] }
    company.owner.close_company company
  end

  # phase 8
  def collect_income
    tier = cost_of_ownership_tier
    @foreign_investor.close_companies tier
    (@corporations + players).each { |entity| entity.collect_income tier }
    @phase += 1
  end

  # phase 9
  def process_phase_9 data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    corporation.pass
    pay_dividend corporation, data[:amount]
  end

  def pay_dividend corporation, amount
    corporation.pay_dividend amount, players
    check_bankruptcy corporation
  end

  # phase 10
  def check_end
    @eng_game_card = :last_turn if cost_of_ownership_tier == :penultimate
    if cost_of_ownership_tier == :last_turn || @stock_market.last.nil?
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

      update deck: @company_deck.map(&:symbol)
    else
      @company_deck = deck.map { |sym| Company.new self, sym, *Company::COMPANIES[sym] }
    end
  end

  def cost_of_ownership_tier
    if @company_deck.empty?
      @end_game_card
    else
      @company_deck.first.tier
    end
  end

  def draw_companies
    num = players.size - @companies.size - @pending_companies.size
    @pending_companies.concat @company_deck.shift(num)
  end

  def untap_pending_companies
    @companies.concat @pending_companies.slice!(0..-1)
  end

  def check_phase_change passers
    return unless passers.all? &:passed?
    passers.each &:unpass
    @phase += 1
  end

  def check_no_player_purchases
    if @current_bid
      eligible = players.reject { |p| p == @current_bid.player || p.cash < @current_bid.price }
      finalize_auction if eligible.all? &:passed?
    else
      min = [
        @corporations.map { |c| c.next_share_price.price }.min,
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
    @stock_market[corporation.share_price.index] = corporation.share_price
  end
end
