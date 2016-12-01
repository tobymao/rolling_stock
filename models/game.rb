require './models/base'
require './models/share_price'

class Game < Base
  many_to_one :user

  def load
    @loaded = false
    @stock_market = SharePrice.initial_market
    @available_corportations = Corporation::CORPORATIONS.dup
    @corporations = []
    @available_companies = []
    @deck = []
    @current_bid = nil
    @foreign_investor = ForeignInvestor.new
    @players = self.users.map { |id| Player.new id }
  end

  # phase 1
  def issue_share player, corporation
    raise unless corporation.can_issue_share? player
    corporation.issue_share
  end

  # phase 2
  def form_corporation player, company, share_price, name
    raise unless player.companies.include? company
    raise unless @available_corportations.include? name
    # check share price is legit
    @available_corportations.remove name
    @corporations << Corporation.new(name, player, company, share_price)
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
    company = @available_companies.first

    while @foreign_investor.cash >= company.price
      @available_companies.remove company
      @foreign_investor.companies << company
      @foreign_investor.cash -= company.price
      company = @available_compaies.first
    end

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
    (@corporations + @players).each do |entity|
      entity.collect_income @cost_of_ownership
    end
  end

  # phase 9
  def pay_dividend corporation, amount
    corporation.pay_dividend amount, players
  end

  # phase 10
  def check_end
  end

  private
  def fill_companies
    @available_companies.concat @deck.pop(@players.size - @available_compaies.size)
    @available_companies.sort_by! &:price
  end
end
