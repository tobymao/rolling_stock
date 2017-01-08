require './models/base'

class GameException < Exception
end

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

  PHASE_DESCRIPTION = {
    1 => 'Issue a share of your corporation',
    2 => 'Choose a company and IPO price to form a corporation',
    3 => 'Select a company to auction or buy and sell shares',
    6 => 'Select a company and offer a price to purchase it',
    7 => 'Select companies you want to close',
    9 => 'Select the amount of dividends to pay each share',
  }

  attr_reader(
    :share_prices,
    :available_corporations,
    :corporations,
    :companies,
    :pending_companies,
    :company_deck,
    :current_bid,
    :offers,
    :passes,
    :foreign_investor,
    :round,
    :phase,
    :log,
    :name,
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
    @log = []
    @share_prices = SharePrice.initial_market
    @available_corporations = Corporation::CORPORATIONS.dup
    @corporations = []
    @companies = [] # available companies
    @pending_companies = []
    @company_deck = []
    @current_bid = nil
    @max_bids = {}
    @offers = []
    @passes = []
    @foreign_investor = ForeignInvestor.new @log
    @round = 1
    @phase = 1
    @end_game_card = :penultimate
    @name = 'the bank'

    start_game unless new_game?
  end

  def start_game
    setup_deck
    draw_companies
    untap_pending_companies
    step
    process_actions
  end

  def players all_users = nil
    @_players ||=
      begin
        user_ids = users.to_a
        (all_users&.select { |u| user_ids.include? u.id } || User.where(id: user_ids))
          .map { |user| Player.new(user.id, user.name, @log) }
          .each{ |player| player.order = user_ids.find_index(player.id) + 1 }
          .sort_by(&:order)
      end
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

  def phase_description
    PHASE_DESCRIPTION[@phase]
  end

  def active_entities
    case @phase
    when 1
      active_corporations.select &:can_issue_share?
    when 2
      active_player_companies
    when 3
      active_players = players.select &:active?

      if @current_bid
        active_players.reject { |p| p.cash <= @current_bid.price }
      else
        min = [
          @corporations.select(&:can_buy_share?).map { |c| c.next_share_price.price }.min,
          @companies.map(&:value).min,
          99999,
        ].compact.min

        active_players.reject { |p| p.cash < min && !p.can_sell_shares? }
      end
    when 6
      min_player_company = [
        players.flat_map { |p| p.companies.map &:min_price }.min,
        @foreign_investor.companies.map(&:min_price).min,
        99999,
      ].compact.min

      corps = corporations.select do |corporation|
        min_corp_company = @corporations
          .reject { |c| c.companies.size == 1 && c == corporation }
          .flat_map { |p| p.companies.map &:min_price }
          .min

        min_price = [min_player_company, min_corp_company].compact.min

        corporation.active? && corporation.cash >= min_price
      end

      (@offers.map { |o| o.company.owner } + corps).uniq
    when 7
      regular_companies = active_companies.reject { |c| c.auto_close?(@phase, ownership_tier) }
      poor_companies = @corporations
        .select { |c| c.negative_income?(ownership_tier) && c.companies.size > 1 }
        .flat_map &:companies

      (regular_companies + poor_companies).uniq
    when 9
      active_corporations
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
    else
      []
    end
  end

  def can_act? entity
    if entity.is_a? Player
      acting.any? { |e| e.owned_by? entity } ||
        @offers.find { |o| o.company.owned_by? entity }
    else
      acting.include? entity
    end
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
    when 1, 2, 6, 7, 9
      check_phase_change
    when 3
      automate_max_bids
      check_no_player_purchases
    when 4
      new_player_order
    when 5
      foreign_investor_purchase
    when 8
      collect_income
    when 10
      check_end
    end

    step if @phase != current_phase
  end

  def process_actions
    actions.sort_by { |action| [action.round, action.phase] }.each do |action|
      raise GameException, 'Invalid action for phase' if action.phase != @phase
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

      raise GameException, 'No one to pass' if entities.empty?

      entities.each do |entity|
        if can_act? entity.owner
          pass_entity entity
        else
          @passes << entity
        end
      end
    elsif msg = data['message']
      player = player_by_id data['player'].to_i
      @log << "#{player.name}: #{msg}"
    else
      send "process_phase_#{@phase}", data
    end

    @passes.each do |entity|
      pass_entity(entity) if can_act? entity
    end

    @passes.reject! &:passed?

    step
  end

  def pass_entity entity
    raise GameException, 'Already passed' if entity.passed?
    entity.pass
    @log << "#{entity.name} #{@current_bid ? 'leaves auction' : 'passes'}"
  end

  # phase 1
  def process_phase_1 data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    corporation.issue_share
    corporation.pass
    check_bankruptcy corporation
  end

  # phase 2
  def process_phase_2 data
    name = data['corporation']
    share_price = @share_prices.find { |sp| sp.price == data['price'].to_i }
    company = active_player_companies.find { |c| c.name == data['company'] }
    raise GameException, "Corporation #{name} not available" unless @available_corporations.include? name
    company.pass
    @available_corporations.delete name
    @corporations << Corporation.new(name, company, share_price, @share_prices, @log)
  end

  # phase 3
  def process_phase_3 data
    player = player_by_id data['player']
    action = data['action']
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    raise GameException, 'Not your turn' unless can_act? player
    raise GameException, 'You must bid or pass' if @current_bid && action != 'bid'

    case action
    when 'bid'
      company = @companies.find { |c| c.name == data['company'] }
      players.each &:unpass unless @current_bid
      price = data['price'].to_i
      raise GameException, 'You cannot bid more than you have' if price > player.cash

      @max_bids[player] = price if data['max']

      if @current_bid
        raise GameException, 'Must bid on same company' if @current_bid.company != company
        raise GameException, 'Bid must be greater than previous' if price < @current_bid.price
      else
        raise GameException, 'Bid must be face value or higher' if price < company.value
        @auction_starter = player
      end

      max = @max_bids[player]

      if max && max > (@current_bid&.price || 0)
        price = company.value
        price = @current_bid.price + 1 if @current_bid
      end

      @current_bid = Bid.new player, company, price, @log
    when 'buy'
      corporation.buy_share player
      player.unpass
    when 'sell'
      corporation.sell_share player
      check_bankruptcy corporation
      player.unpass
    else
      raise GameException, 'Unspecified action'
    end

    restart_order player
  end

  def restart_order player
    players.rotate!
    restart_order player if player != players.last
  end

  # phase 4
  def new_player_order
    index = 0

    players.sort_by! do |player|
      index += 1
      [-player.cash, index]
    end

    players.each_with_index { |p, i| p.order = i + 1 }
    @log << "New player order: #{players.map &:name}"
    change_phase
  end

  # phase 5
  def foreign_investor_purchase
    @foreign_investor.purchase_companies @companies
    draw_companies
    untap_pending_companies
    change_phase
  end

  # phase 6
  # corporations buy companies
  def process_phase_6 data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    companies = held_companies + @foreign_investor.companies
    company = companies.find { |c| c.name == data['company'] }
    offer = @offers.find do |o|
      (o.corporation == corporation && o.company == company) ||
        (o.company == company && o.foreign_purchase?)
    end
    owner = company.owner

    case data['action']
    when 'accept'
      offer.suitors.delete corporation

      if !offer.foreign_purchase? || offer.suitors.empty?
        @offers.delete offer
        corporation.buy_company company, offer.price
      end
    when 'decline'
      offer.suitors.delete corporation
      @log << "#{corporation.name} declines to buy #{company.name} for $#{offer.price}"

      if offer.foreign_purchase?
        if offer.suitors.empty?
          @offers.delete offer
          offer.corporation.buy_company(company, offer.price)
        end
      else
        @offers.delete offer
      end
    else
      price = data['price'].to_i
      raise GameException, 'Not a valid price' unless company.valid_price? price
      raise GameException, 'Already have an offer' if @offers.any? { |o| o.corporation == corporation && o.company == company}
      raise GameException, 'Cannot buy own company' if corporation == company.owner

      suitors = @corporations.select do |c|
        c.price > corporation.price &&
          c.owner != corporation.owner &&
          c.owner.cash >= price
      end if owner.is_a? ForeignInvestor

      if suitors && suitors.empty?
        raise GameException, 'Foreign Investor purchase must be max price' if price != company.max_price
        corporation.buy_company company, price
      elsif !corporation.owned_by? owner
        @offers << Offer.new(corporation, company, price, suitors, @log)
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
    change_phase
  end

  # phase 9
  def process_phase_9 data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    raise GameException, 'Not corporation turn' unless acting.include? corporation
    corporation.pass
    corporation.pay_dividend data['amount'].to_i, players
    check_bankruptcy corporation
  end

  # phase 10
  def check_end
    @end_game_card = :last_turn if (ownership_tier == :penultimate && @companies.empty?)

    if ownership_tier == :last_turn || @share_prices.last.corporation
      scores = players.sort_by(&:value).reverse.map { |p| "#{p.name} ($#{p.value})" }
      @log << "Game over. #{scores.join ', '}"
      update(state: :finished)
    else
      change_phase
    end
  end

  private

  def setup_deck
    if deck.size.zero?
      groups = Company.all.values.group_by &:tier
      new_deck = []

      Company::TIERS.each do |tier|
        num_cards = players.size + 1
        num_cards = 6 if tier == :orange && players.size == 4
        num_cards = 8 if tier == :orange && players.size == 5

        group = groups[tier]
        largest = group.sort_by!(&:value).pop
        group.shuffle!.pop(group.size - num_cards + 1)
        group << largest
        new_deck.concat group.shuffle!
      end

      update deck: new_deck.map(&:name)
    end

    @company_deck = deck.map { |sym| Company.new self, sym, *Company::COMPANIES[sym], @log }
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

  def finalize_purchases
    ([@foreign_investor] + players + @corporations).each &:finalize_purchases
  end

  def sort_corporations
    @corporations.sort_by!(&:price).reverse!
  end

  def check_phase_change
    return unless active_entities.empty?
    unpass_all
    change_phase
  end

  def automate_max_bids
    while player = active_entities.first
      max = @max_bids[player]
      break if !max || player == @current_bid.player

      company = @current_bid.company
      price = @current_bid.price

      if max > price
        @current_bid = Bid.new player, company, price + 1, @log
        restart_order player
      else
        @max_bids.delete(player)
        pass_entity player
      end
    end
  end

  def check_no_player_purchases
    if @current_bid && active_entities.reject { |p| p == @current_bid.player }.empty?
      @current_bid.player.buy_company @current_bid.company, @current_bid.price
      draw_companies
      players.each &:unpass
      restart_order @auction_starter
      @max_bids.clear
      @auction_starter = nil
      @current_bid = nil
    end

    check_phase_change
  end

  def check_bankruptcy corporation
    return unless corporation.bankrupt?
    @log << "#{corporation.name} becomes bankrupt"
    @corporations.delete corporation
    @available_corporations << corporation.name
    players.each do |player|
      player.shares.reject! { |share| share.corporation == corporation }
    end
    corporation.share_price.corporation = nil
  end

  def change_phase
    case @phase
    when 3, 5, 6
      finalize_purchases
    when 7, 8, 9
      @corporations.each { |c| check_bankruptcy c }
      sort_corporations
    end

    @phase += 1

    if @phase > 10
      @phase = 1
      @round += 1
    end

    @log << "-- Round: #{@round} Phase: #{@phase} (#{phase_name}) --"
  end
end
