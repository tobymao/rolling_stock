class Corporation
  CORPORATIONS = %w(Android Bear Eagle Horse Jupiter Orion Saturn Ship Star Wheel).freeze

  def initialize name, president, company, price
    @name = name
    @president = president
    @companies = [company]
    @price = price
    @cash = 0
    @shares = [Share.president] + 9.times.map { Share.normal }
  end

  def form_corportation president, company
    num_shares = company.price / @price
    diff = company.value - num_shares * @price

    if diff > 0
      @cash = diff
    else
      president.cash + diff
    end

    num_shares
  end

  def issue_share
  end
end
