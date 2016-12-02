require './models/base'
require './models/share_price'

class Game < Base
  many_to_one :user

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
    @loaded = false
    @stock_market = SharePrice.initial_market
    @available_corportations = Corporation::CORPORATIONS.dup
    @corporations = {}
    @available_companies = []
    @deck = []
    @current_bid = nil
    @foreign_investor = ForeignInvestor.new
    @round = 0
    @phase = 0
  end

  def players
    @players ||= User
      .where(id: users.to_a)
      .map { |user| [user.id, Player.new(user.id, user.name)] }
      .to_h
  end

  def new?
    state == 'new'
  end

  def active?
    state == 'active'
  end

  def finished?
    state == 'finished'
  end

  def process_action
  end

  def process_action_data phase, data
    send "process_phase_#{phase}", data
  end

  # phase 1
  def process_phase_1 data
    corporation = @corporations[data[:corporation]]
    corporation.pass
    issue_share corporation unless data[:pass]
    check_phase_change @corporations.values
  end

  def issue_share corporation
    raise unless corporation.can_issue_share?
    corporation.issue_share
  end

  # phase 2
  def process_phase_2 data
    player = @players[data[:player]]
    company = player.companies.find { |c| c.name == data[:company] }
    company.pass

    share_price = @share_prices.find { |sp| sp.price == data[:price] }
    corporation = data[:corporation]
    form_corporation player, company, share_price, corporation

    check_phase_change @players.flat_map(&:companies)
  end

  def form_corporation player, company, share_price, corporation_name
    raise unless player.companies.include? company
    raise unless @available_corportations.include? corporation_name
    # check share price is legit
    @available_corportations.remove corporation_name
    @corporations[corporation_name] = Corporation.new corporation_name, player, company, share_price
  end

  # phase 3
  def buy_share player, corporation
    raise unless corporation.can_buy_share?
    corporation.buy_share player
  end

  def sell_share player, corporation
    raise unless corporation.can_sell_share? player
    corporation.sell_share player
  end

  def auction_company player, company, price
    @current_bid = Bid.new player, company, price
  end

  def finalize_auction
    company = @current_bid.company
    @current_bid.player.buy_company company, @current_bid.price
    @available_companies.remove company
    fill_companies
  end

  # phase 4
  def new_player_order
    @players.sort_by(&:cash).reverse!
  end

  # phase 5
  def foreign_investor_purchase
    foreign_investor.purchase_companies @available_compaies
    fill_companies
  end

  # phase 6
  def buy_company corporation, seller, company, price
    raise unless company.valid_price? price
    corporation.buy_company seller, company, price
  end

  # phase 7
  def close_company holder, company
    holder.close_company company
  end

  # phase 8
  def collect_income
    (@corporations.values + @players.values).each do |entity|
      entity.collect_income @cost_of_ownership
    end
  end

  # phase 9
  def pay_dividend corporation, amount
    corporation.pay_dividend amount, @players.values
  end

  # phase 10
  def check_end
  end

  private

  def fill_companies
    @available_companies.concat @deck.pop(@players.size - @available_compaies.size)
    @available_companies.sort_by! &:price
  end

  def check_phase_change passers
    return unless passers.all? &:passed?
    passers.each &:unpass
    @phase += 1
  end
end
