require './models/game'

class Engine
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
    :stats,
  )

  PHASE_TO_ID = {
    issue:       1,
    ipo:         2,
    investment:  3,
    order:       4,
    foreign:     5,
    acquisition: 6,
    closing:     7,
    income:      8,
    dividend:    9,
    end:         10,
  }.freeze

  PHASE_NAME = {
    issue:       'Issue New Shares',
    ipo:         'Form Corporations',
    investment:  'Auctions And Share Trading',
    order:       'Determine New Player Order',
    foreign:     'Foreign Investor Buys Companies',
    acquisition: 'Corporations Buys Companies',
    closing:     'Close Companies',
    income:      'Collect Income',
    dividend:    'Pay Dividends And Adjust Share Prices',
    end:         'Check Game End',
  }.freeze

  PHASE_DESCRIPTION = {
    issue:       'Issue a share of your corporation',
    ipo:         'Choose a company and IPO price to form a corporation',
    investment:  'Select a company to auction or buy and sell shares',
    acquisition: 'Select a company and offer a price to purchase it',
    closing:     'Select companies you want to close',
    dividend:    'Select the amount of dividends to pay each share',
  }.freeze

  def initialize game, round, phase
    @game = game
    @log = []
    players.each { |p| p.log = @log }
    @share_prices = share_price_class.initial_market
    @available_corporations = corporation_class::CORPORATIONS.dup
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
    @phase = map_phase :investment
    @end_game_card = :penultimate
    @name = 'the bank'
    @check_point = [round.to_i, phase.to_i] if round && phase
    @ended = false
    @stats = []
  end

  def players
    @game.players
  end

  def player_by_user user
    @game.player_by_user
  end

  def player_by_id id
    @game.player_by_id id
  end

  def owner
    nil
  end

  def company_class
    Company
  end

  def corporation_class
    Corporation
  end

  def share_price_class
    SharePrice
  end

  def map_phase phase_sym
    self.class::PHASE_TO_ID[phase_sym]
  end

  def map_phase_id phase_id
    @id_to_phase ||= self.class::PHASE_TO_ID.invert
    @id_to_phase[phase_id.to_i]
  end

  def phase_sym
    map_phase_id @phase
  end

  def phase_name
    self.class::PHASE_NAME[phase_sym]
  end

  def phase_description
    self.class::PHASE_DESCRIPTION[phase_sym]
  end

  def process_action_data data
    if data['action'] == 'pass'
      pass_entity passing_entity(data)
    elsif data['action'] == 'autopass'
      autopass passing_entity(data)
    elsif data['action'] == 'skip'
      skip = [passing_entity(data), map_phase_id(data['phase'])]
      @skips.include?(skip) ? @skips.delete(skip) : @skips << skip
    elsif msg = data['message']
      @log << "#{player_by_id(data['player']).name}: #{msg}"
    else
      process_action data
    end

    step
  end

  def start_game
    setup_deck
    draw_companies
    untap_pending_companies
    players.each { |player| @skips << [player, :closing] } if @game.settings['default_close']
    players.each { |p| p.cash = 25 } if players.size > 5
    step
    process_actions
  end

  def active_entities
    case phase_sym
    when :issue
      active_corporations.select &:can_issue_share?
    when :ipo
      active_player_companies
    when :investment
      active_players = players.select &:active?

      if @current_bid
        active_players.reject { |p| p.cash <= @current_bid.price }
      else
        min = [
          @corporations.select(&:can_buy_share?).map { |c| c.next_share_price&.price }.compact.min,
          @companies.map(&:value).min,
          99999,
        ].compact.min

        active_players.reject { |p| p.cash < min && !p.can_sell_shares? }
      end
    when :acquisition
      purchasable = all_companies.select &:can_be_sold?

      corps = @corporations.select do |corp|
        min_price = purchasable.reject { |c| c.owner == corp }.map(&:min_price).min
        corp.active? && corp.cash >= (min_price || 99999)
      end

      offers = @offers.flat_map do |offer|
        owner = offer.company.owner
        arr = []
        arr << owner unless owner.is_a? ForeignInvestor
        arr.concat offer.suitors if offer.suitors
        arr
      end

      (offers + corps).uniq
    when :closing
      held_companies
        .reject { |c| c.auto_close? || (c.orphan? && c.owner.is_a?(Corporation)) }
        .select { |c| c.active? || c.pending_closure? }
    when :dividend
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
    case phase_sym
    when :issue, :ipo, :investment, :dividend
      active_entities.slice(0..0)
    when :acquisition, :closing
      active_entities
    else
      []
    end
  end

  def can_act? entity
    if entity.is_a? Player
      acting.any? { |e| e.owned_by? entity }
    else
      acting.include? entity
    end
  end

  def held_companies
    @corporations.flat_map(&:companies) + players.flat_map(&:companies)
  end

  def all_companies
    held_companies.concat @foreign_investor.companies
  end

  def ownership_tier
    if @company_deck.empty?
      @end_game_card
    else
      @company_deck.first.tier
    end
  end

  def sorted_actions
    @game.actions.sort_by { |a| [a.round, a.phase] }
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

  private
  def step
    current_phase = @phase

    case phase_sym
    when :issue, :ipo, :acquisition, :closing, :dividend
      check_phase_change
    when :investment
      check_no_player_purchases
      end_game if @share_prices.last.corporation
      process_max_bids
    when :order
      new_player_order true
    when :foreign
      foreign_purchase
    when :upkeep
      new_player_order false
      foreign_purchase
    when :income
      collect_income
    when :end
      check_end
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

  def passing_entity data
    if id = data['player']
      player_by_id id
    elsif id = data['corporation']
      @corporations.find { |c| id == c.name }
    elsif id = data['company']
      held_companies.find { |c| id == c.name }
    end
  end

  def process_action data
    case phase_sym
    when :issue
      process_issue data
    when :ipo
      process_form data
    when :investment
      process_auction data
    when :acquisition
      process_buy data
    when :closing
      process_close data
    when :dividend
      process_dividend data
    end
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
    raise GameException, "Not your turn to pass #{entity.name}" unless can_act? entity

    if phase_sym == :dividend
      process_dividend 'corporation' => entity.name, 'amount' => 0
    else
      entity.pass
    end

    @log << "#{entity.name} #{@current_bid ? 'leaves auction' : 'passes'}"
  end

  def process_issue data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    corporation.issue_share
    corporation.pass
    check_bankruptcy corporation
  end

  def process_form data
    name = data['corporation']
    share_price = @share_prices.find { |sp| sp.price == data['price'].to_i }
    company = active_player_companies.find { |c| c.name == data['company'] }
    raise GameException, "Corporation #{name} not available" unless @available_corporations.include? name
    company.pass
    @available_corporations.delete name
    @corporations << corporation_class.new(
      name,
      company,
      share_price,
      @share_prices,
      @game.minor_version,
      @log
    )
  end

  def process_auction data
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
        raise GameException, 'Bid must be greater than previous' if price <= @current_bid.price
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

  def new_player_order change
    players.sort_by! { |player| [-player.cash, player.order] }
    players.each_with_index { |p, i| p.order = i + 1 }
    @log << "New player order: #{players.map(&:name).join(', ')}"
    change_phase if change
  end

  def foreign_purchase
    @foreign_investor.purchase_companies @companies
    draw_companies
    untap_pending_companies
    change_phase
  end

  def process_buy data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    company = all_companies.find { |c| c.name == data['company'] }
    owner = company.owner
    offer = @offers.find do |o|
      (o.corporation == corporation && o.company == company) ||
        (o.company == company && o.foreign_purchase?)
    end

    case data['action']
    when 'accept'
      reject_suitors offer, corporation

      if !offer.foreign_purchase? || offer.suitors.empty?
        @offers.reject! { |o| o.company == company }
        corporation.buy_company company, offer.price
      else
        @log << "#{corporation.name} offers to buy #{company.name} from the Foreign Investor for $#{offer.price}"
        offer.corporation = corporation
      end
    when 'decline'
      offer.suitors.delete corporation

      if offer.foreign_purchase?
        @log << "#{corporation.name} declines to buy #{company.name} from the Foreign Investor"

        if offer.suitors.empty?
          @offers.delete offer
          offer_corp = offer.corporation
          offer_corp.buy_company company, offer.price if offer_corp.cash >= offer.price
        end
      else
        @log << "#{owner.name} declines to sell #{company.name} to #{corporation.name} for $#{offer.price}"
        @offers.delete offer
      end
    else
      price = data['price'].to_i
      check_price corporation, company, price
      raise GameException, 'Already have an offer' if @offers.any? { |o| o.corporation == corporation && o.company == company}
      raise GameException, 'Cannot buy own company' if corporation == owner
      try_to_buy corporation, owner, company, price
    end
  end

  def reject_suitors offer, corporation
    offer.suitors.reject! { |s| corporation.price >= s.price }
  end

  def try_to_buy corporation, owner, company, price
    suitors = get_suitors corporation, owner, company, price

    if (suitors && suitors.empty?) || corporation.owned_by?(owner)
      corporation.buy_company company, price
    else
      @offers << Offer.new(corporation, company, price, suitors, @log)
    end
  end

  def check_price corporation, company, price
    raise GameException, 'Not a valid price' unless company.valid_price? price
  end

  def get_suitors corporation, owner, company, price
    @corporations.select do |c|
      c.price > corporation.price &&
        c.owner != corporation.owner &&
        c.cash >= price
    end if owner.is_a? ForeignInvestor
  end

  def process_close data
    company = held_companies.find { |c| c.name == data['company'] }
    company.close
  end

  def collect_income
    (@corporations + players + [@foreign_investor]).each &:collect_income
    change_phase
  end

  def process_dividend data
    corporation = @corporations.find { |c| c.name == data['corporation'] }
    raise GameException, 'Not corporation turn' unless acting.include? corporation
    corporation.pass
    corporation.pay_dividend data['amount'].to_i, players
    check_bankruptcy corporation
  end

  def check_end
    if ownership_tier == :last_turn || @share_prices.last.corporation
      end_game unless @ended
    else
      change_phase
    end

    if (ownership_tier == :penultimate && @companies.empty?)
      @end_game_card = :last_turn
      set_income
    end
  end

  def setup_deck
    unless @game.state['deck']
      groups = company_class.all.values.group_by &:tier
      new_deck = []

      company_class::TIERS.each do |tier|
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

      @game.update_state 'deck' => new_deck.map(&:name)
    end

    @company_deck = @game.state['deck'].map do |sym|
      company_class.new self, sym, *company_class::COMPANIES[sym], @log
    end
  end

  def draw_companies
    num = players.size - @companies.size - @pending_companies.size
    @pending_companies.concat @company_deck.shift(num)

    if @last_tier != ownership_tier
      @last_tier = ownership_tier
      set_income
    end
  end

  def set_income
    all_companies
      .each { |c| c.ownership_tier = ownership_tier }
      .map(&:owner)
      .uniq
      .reject { |owner| owner == self }
      .each { |owner| owner.set_income }
  end

  def restart_order player
    players.rotate!
    restart_order player if player != players.last
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
    did_pass = false
    acting.each do |entity|
      next if !@autopasses.include?(entity) && !skipped?(entity)

      no_pass =
        case phase_sym
        when :closing
          entity.pending_closure?
        when :acquisition
          # if they are already passed, it means they have an action to respond to
          # foreign investor purchase or an offer on the table
          @offers.dup.each do |offer|
            if entity.passed? && (offer.company.owner == entity || offer.suitor?(entity))
              process_buy(
                'corporation' => offer.corporation.name,
                'company' => offer.company.name,
                'action' => 'decline',
              )
            end
          end

          entity.passed?
        end

      next if no_pass

      pass_entity(entity)
      did_pass = true
    end

    step if did_pass
  end

  def skipped? entity
    @skips.include? [entity.player, phase_sym]
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
    @phase = map_phase :end
    scores = players.sort_by(&:value).reverse.map { |p| "#{p.name} ($#{p.value})" }
    @log << "Game over. #{scores.join ', '}"

    if @game.active?
      result = players.map { |p| [p.id, p.value] }.to_h
      @game.update_state 'status' => 'finished', 'result' => result
    end
  end

  def change_phase
    case phase_sym
    when :investment, :foreign, :acquisition, :upkeep
      finalize_purchases
    when :closing, :income, :dividend
      @corporations.dup.each { |c| check_bankruptcy c }
      sort_corporations
    end

    if phase_sym == :closing
      @foreign_investor.close_companies
      player_companies.each { |c| c.close if c.auto_close? }
    end

    @stats << ["#{@round}.#{@phase}"].concat(players.sort_by(&:name).map(&:value))

    @phase += 1

    phase_ids = self.class::PHASE_TO_ID.values

    if @phase > phase_ids.max
      @phase = phase_ids.min
      @round += 1
    end

    @autopasses.clear

    @log << "-- Round: #{@round} Phase: #{@phase} (#{phase_name}) --"
  end
end
