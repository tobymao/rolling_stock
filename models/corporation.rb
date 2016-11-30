class Corporation
  CORPORATIONS = %w(Android Bear Eagle Horse Jupiter Orion Saturn Ship Star Wheel).freeze

  attr_reader :name, :president, :companies, :share_price, :cash, :shares, :bank_shares

  def initialize name, president, company, share_price, share_prices
    @name = name
    @president = president
    @companies = [company]
    @share_price = share_price
    @share_prices = share_prices
    @cash = 0
    @shares = [Share.president(self)].concat 9.times.map { Share.normal(self) }
    @bank_shares = []

    issue_initial_shares
  end

  def can_buy_share?
    !@bank_shares.empty?
  end

  def buy_share user
    swap_share_price next_share_price(@share_prices)
    user.cash - @share_price.price
    user.shares << @bank_shares.pop
  end

  def can_sell_share? user
    share = user.shares.last
    share && !share.president?
  end

  def sell_share user
    swap_share_price prev_share_price
    user.cash + @share_price.price
    @bank_shares << user.shares.pop
  end

  def can_issue_share? user
    @president == user && @shares.size > 0
  end

  def issue_share
    swap_share_price prev_share_price
    @cash += @share_price.price
    @bank_shares << @shares.shift
  end

  private
  def issue_initial_shares
    company = @companies.first
    price = @share_price.price
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
    @share_prices.take(@share_price.index).reverse.compact.first
  end

  def next_share_price
    @share_prices.drop(@share_price.index).compact.first
  end

  def swap_share_price new_price
    @share_prices[@share_price.index] = @share_price
    @share_prices[new_price.index] = nil
    @share_price = new_price
  end
end
