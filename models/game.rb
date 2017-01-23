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
  }.freeze

  DEFAULT_MAX_PLAYERS = 5.freeze

  attr_reader(
    :share_prices,
    :available_corporations,
    :corporations,
    :companies,
    :pending_companies,
    :company_deck,
    :current_bid,
    :offers,
    :autopasses,
    :skips,
    :foreign_investor,
    :round,
    :phase,
    :log,
    :name,
    :check_point,
  )

  def self.empty_game user, settings
    Game.create(
      user: user,
      users: [user.id],
      settings: { 'version' => '1.0' }.merge(settings),
      state: { status: 'new' },
    )
  end

  # if sequel converts the dataset to a result, update doesn't save
  def update_settings hash
    update settings: settings.merge(hash)
    save
  end

  def update_state hash
    update state: state.merge(hash)
    save
  end

  def new_game?
    state['status'] == 'new'
  end

  def active?
    state['status'] == 'active'
  end

  def finished?
    state['status'] == 'finished'
  end

  def max_players
    settings['max_players'] || DEFAULT_MAX_PLAYERS
  end

  def load round = nil, phase = nil
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
    @autopasses = Set.new
    @skips = Set.new
    # when a user autopasses in an auction, it's only to leave the auction
    @leaves = Set.new
    @foreign_investor = ForeignInvestor.new @log
    @round = 1
    @phase = 1
    @end_game_card = :penultimate
    @name = 'the bank'
    @check_point = [round.to_i, phase.to_i] if round && phase
    @ended = false

    start_game unless new_game?
  end

  def start_game
    setup_deck
    draw_companies
    untap_pending_companies
    players.each { |player| @skips << [player, 7] } if settings['default_close']
    players.each { |p| p.cash = 25 } if players.size > 5
    step
    process_actions
  end

  def players preloaded = nil
    @_players ||=
      begin
        ids = users.to_a
        user_models = preloaded.select { |u| ids.include? u.id } if preloaded
        user_models = User.where(id: ids) unless user_models
        user_models
          .map { |user| Player.new(user.id, user.name, @log) }
          .each{ |player| player.order = ids.find_index(player.id) + 1 }
          .sort_by(&:order)
      end
  end

  def acting_players
    acting.map(&:player).uniq
  end

  def player_by_user user
    player_by_id user.id
  end

  def player_by_id id
    id = id.to_i
    players.find { |p| p.id == id }
  end

  def phase_name
    PHASE_NAME[@phase]
  end

  def phase_description
    PHASE_DESCRIPTION[@phase]
  end

  def owner
    nil
  end

  def sorted_actions
    actions.sort_by { |a| [a.round, a.phase] }
  end

  def next
    action = sorted_actions
      .reject { |a| a.round < @round }
      .find { |a| a.round > @round || a.phase > @phase }

    action ? [action.round, action.phase] : nil
  end

  def prev
    action = sorted_actions
      .reject { |a| a.round > @round }
      .reverse
      .find { |a| a.round < @round || a.phase < @phase }

    action ? [action.round, action.phase] : nil
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
      purchasable = (held_companies + foreign_investor.companies).select &:can_be_sold?

      corps = @corporations.select do |corp|
        min_price = purchasable.reject { |c| c.owner == corp }.map(&:min_price).min
        corp.active? && corp.cash >= (min_price || 99999)
      end

      (@offers.map { |o| o.company.owner } + corps).uniq
    when 7
      held_companies
        .reject { |c| c.auto_close? ownership_tier }
        .select { |c| c.active? || c.pending_closure?(ownership_tier) }
    when 9
      active_corporations
    else
      []
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
      acting.any? { |e| e.owned_by? entity } || @offers&.find { |o| o.company.owned_by? entity }
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
      check_no_player_purchases
      end_game if @share_prices.last.corporation
      process_max_bids
    when 4
      process_phase_4
    when 5
      process_phase_5
    when 8
      process_phase_8
    when 10
      process_phase_10
    end

    process_autopasses
    step if @phase != current_phase
  end

  def process_actions
    sorted_actions.each do |action|
      raise GameException, 'Invalid action for phase' if action.phase != @phase
      break if @check_point && @round == @check_point[0] && @phase == @check_point[1]
      action.turns.each { |turn| process_action_data turn }
    end
  end

  def process_action_data data
    entity =
      if id = data['player']
        player_by_id id
      elsif id = data['corporation']
        @corporations.find { |c| id == c.name }
      elsif id = data['company']
        held_companies.find { |c| id == c.name }
      end

    if data['action'] == 'pass'
      pass_entity entity
    elsif data['action'] == 'autopass'
      autopass entity
    elsif data['action'] == 'skip'
      skip = [entity, data['phase'].to_i]
      @skips.include?(skip) ? @skips.delete(skip) : @skips << skip
    elsif msg = data['message']
      @log << "#{entity.name}: #{msg}"
    else
      send "process_phase_#{@phase}", data
    end

    step
  end

  def autopass entity
    if @autopasses.include? entity
      @autopasses.delete entity
      @leaves.delete entity if @current_bid
    else
      @autopasses << entity
      @leaves << entity if @current_bid
    end
  end

  def pass_entity entity
    raise GameException, "Already passed #{entity.name}" if entity.passed?
    raise GameException, 'Not your turn to pass' unless can_act? entity

    if @phase == 9
      process_phase_9 'corporation' => entity.name, 'amount' => 0
    else
      entity.pass
    end

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
    players.each &:unpass unless @current_bid

    case action
    when 'bid'
      company = @companies.find { |c| c.name == data['company'] }
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
    when 'sell'
      corporation.sell_share player
      check_bankruptcy corporation
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
  # new player order
  def process_phase_4
    index = 0

    players.sort_by! do |player|
      index += 1
      [-player.cash, index]
    end

    players.each_with_index { |p, i| p.order = i + 1 }
    @log << "New player order: #{players.map(&:name).join(', ')}"
    change_phase
  end

  # phase 5
  # foreign investor purchase
  def process_phase_5
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
    owner = company.owner
    offer = @offers.find do |o|
      (o.corporation == corporation && o.company == company) ||
        (o.company == company && o.foreign_purchase?)
    end

    case data['action']
    when 'accept'
      offer.suitors.delete corporation

      if !offer.foreign_purchase? || offer.suitors.empty?
        @offers.delete offer
        corporation.buy_company company, offer.price
      end
    when 'decline'
      offer.suitors.delete corporation

      if offer.foreign_purchase?
        @log << "#{corporation.name} declines to buy #{company.name} from the Foreign Investor"

        if offer.suitors.empty?
          @offers.delete offer
          offer.corporation.buy_company(company, offer.price)
        end
      else
        @log << "#{owner.name} declines to sell #{company.name} to #{corporation.name} for $#{offer.price}"
        @offers.delete offer
      end
    else
      price = data['price'].to_i
      raise GameException, 'Not a valid price' unless company.valid_price? price
      raise GameException, 'Already have an offer' if @offers.any? { |o| o.corporation == corporation && o.company == company}
      raise GameException, 'Cannot buy own company' if corporation == owner

      suitors = @corporations.select do |c|
        c.price > corporation.price &&
          c.owner != corporation.owner &&
          c.owner.cash >= price
      end if owner.is_a? ForeignInvestor

      if (suitors && suitors.empty?) || corporation.owned_by?(owner)
        corporation.buy_company company, price
      else
        @offers << Offer.new(corporation, company, price, suitors, @log)
      end
    end
  end

  # phase 7
  # close companies
  def process_phase_7 data
    company = held_companies.find { |c| c.name == data['company'] }
    company.close
  end

  # phase 8
  # collect income
  def process_phase_8
    @foreign_investor.close_companies ownership_tier
    player_companies.each { |c| c.close if c.auto_close?(ownership_tier) }
    entities = @corporations + players + [@foreign_investor]
    entities.each { |entity| entity.collect_income ownership_tier }
    change_phase
  end

  # phase 9
  # pay dividends
  def process_phase_9 data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    raise GameException, 'Not corporation turn' unless acting.include? corporation
    corporation.pass
    corporation.pay_dividend data['amount'].to_i, players
    check_bankruptcy corporation
  end

  # phase 10
  # check end
  def process_phase_10
    if ownership_tier == :last_turn || @share_prices.last.corporation
      end_game unless @ended
    else
      change_phase
    end

    @end_game_card = :last_turn if (ownership_tier == :penultimate && @companies.empty?)
  end

  private

  def setup_deck
    unless state['deck']
      groups = Company.all.values.group_by &:tier
      new_deck = []

      Company::TIERS.each do |tier|
        num_cards = players.size + 1
        num_cards = 6 if tier == :orange && players.size == 4
        num_cards = 8 if tier == :orange && players.size == 5

        group = groups[tier]

        if players.size < 6
          largest = group.sort_by!(&:value).pop
          group.shuffle!.pop(group.size - num_cards + 1)
          group << largest
        end

        new_deck.concat group.shuffle!
      end

      update_state 'deck' => new_deck.map(&:name)
    end

    @company_deck = state['deck'].map { |sym| Company.new self, sym, *Company::COMPANIES[sym], @log }
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

  def process_max_bids
    player = active_entities.first
    max = @max_bids[player]

    if max && player != @current_bid.player
      company = @current_bid.company
      price = @current_bid.price

      if max > price
        @current_bid = Bid.new player, company, price + 1, @log
        restart_order player
      else
        @max_bids.delete(player)
        pass_entity player
      end

      step
    end
  end

  def process_autopasses
    entity = active_entities.first
    return unless entity
    no_pass = entity.pending_closure?(ownership_tier) if @phase == 7
    if @autopasses.include?(entity) || @skips.include?([entity.player, @phase]) && !no_pass
      pass_entity(entity)
      step
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

      @autopasses -= @leaves
      @leaves.clear
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

  def end_game
    @ended = true
    scores = players.sort_by(&:value).reverse.map { |p| "#{p.name} ($#{p.value})" }
    @log << "Game over. #{scores.join ', '}"

    if active?
      result = players.map { |p| [p.id, p.value] }.to_h
      update_state 'status' => 'finished', 'result' => result
    end
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

    @autopasses.clear

    @log << "-- Round: #{@round} Phase: #{@phase} (#{phase_name}) --"
  end
end
