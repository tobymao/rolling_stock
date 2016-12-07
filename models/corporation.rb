require './models/passer'
require './models/purchaser'

class Corporation
  include Passer
  include Purchaser

  CORPORATIONS = %w(Android Bear Eagle Horse Jupiter Orion Saturn Ship Star Wheel).freeze

  attr_reader :name, :president, :companies, :share_price, :cash, :shares, :bank_shares

  def self.calculate_synergy tier, other_tier
    case tier
    when :red
      1
    when :orange
      other_tier == :red ? 1 : 2
    when :yellow
      other_tier == :orange ? 2 : 4
    when :green
      4
    when :blue
      [:green, :yellow].include? other_tier ? 4 : 8
    when :purple
      other_tier == :blue ? 8 : 16
    end
  end

  def initialize name, company, share_price, stock_market
    @name = name
    @president = company.owner
    @companies = [company]
    @share_price = share_price
    @stock_market = stock_market
    @cash = 0
    @shares = [Share.president(self)].concat 9.times.map { Share.normal(self) }
    @bank_shares = []

    issue_initial_shares
  end

  def owner
    @president
  end

  def price
    @share_price.price
  end

  def can_buy_share?
    !@bank_shares.empty?
  end

  def is_bankrupt?
    price.zero?
  end

  def buy_share player
    swap_share_price next_share_price
    player.cash - price
    player.shares << @bank_shares.pop
  end

  def can_sell_share? player
    share = player.shares.last
    share && !share.president?
  end

  def sell_share player
    swap_share_price prev_share_price
    player.cash + price
    @bank_shares << player.shares.pop
  end

  def can_issue_share?
    @shares.size > 0
  end

  def issue_share
    swap_share_price prev_share_price
    @cash += price
    @bank_shares << @shares.shift
  end

  def collect_income tier
    synergies = @companies.map { |c| [c.symbol, c.tier] }.to_h

    @companies.each do |company|
      @cash += company.income
      @cash -= company.cost_of_ownership tier

      company.synergies.each do |synergy|
        if companies.include? synergy
          @cash += self.class.calculate_synergy company.tier, synergies[synergy]
        end
      end

      synergies.delete company.symbol
    end
  end

  def pay_dividend amount, players
    @cash -= amount * @bank_shares.size

    players.each do |player|
      total = amount * player.shares.count { |share| share.corporation == self }
      @cash -= total
      player.cash += total
    end

    adjust_share_price
  end

  def book_value
    @cash + @companies.reduce(0) { |p, c| c.value + p }
  end

  def market_cap
    shares_issued * price
  end

  def shares_issued
    10 - @shares.size
  end

  private
  def issue_initial_shares
    company = @companies.first
    value = company.value
    num_shares = (value / price) + 1
    seed = value - num_shares * price

    @cash = -seed
    @president.cash + seed
    @cash += num_shares * price

    @president.shares.concat @shares.shift(num_shares)
    @bank_shares.concat @shares.shift(num_shares)
  end

  def prev_share_price
    @stock_market.take(@share_price.index).reverse.compact.first || @stock_market.first
  end

  def next_share_price
    @stock_market.drop(@share_price.index).compact.first || @stock_market.last
  end

  def swap_share_price new_price
    @stock_market[@share_price.index] = @share_price
    @stock_market[new_price.index] = nil
    @share_price = new_price
  end

  def above_valuation?
    book_value - market_cap >= SharePrice::PRICES[@share_price.index]
  end

  def adjust_share_price
    if above_valuation?
      swap_share_price next_share_price
      swap_share_price next_share_price if above_valuation?
    else
      swap_share_price prev_share_price
      swap_share_price next_share_price unless above_valuation?
    end
  end
end
