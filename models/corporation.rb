class Corporation
  CORPORATIONS = %w(Android Bear Eagle Horse Jupiter Orion Saturn Ship Star Wheel).freeze

  attr_reader :shares, :share_price

  def initialize name, president, company, share_price
    @name = name
    @president = president
    @companies = [company]
    @share_price = share_price
    @cash = 0
    @shares = [Share.president] + 9.times.map { Share.normal }
  end

  def issue_initial_shares bank_shares
    company = @companies.first
    price = @share_price.price
    value = company.value
    num_shares = value / price
    seed = value - num_shares * price

    @cash = seed
    @president.cash - seed
    @cash += num_shares * price

    @president.shares.concat @shares.shift num_shares
    bank_shares.concat @shares.shift num_shares
  end

  def can_issue_share? user
    @president == user && @shares.size > 0
  end

  def issue_share share_prices, bank_shares
    new_price = share_prices.take(@share_price.index).reverse.compact.first
    swap_share_price share_prices, new_price
    @cash += @share_price.price
    bank_shares << @shares.shift
  end

  def swap_share_price share_prices, new_price
    share_prices[old_price.index] = @share_price
    share_prices[new_price.index] = nil
    @share_price = new_price
  end
end
