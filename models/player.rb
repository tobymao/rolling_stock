class Player
  attr_reader :id, :companies, :shares, :cash

  def initialize id
    @id = id
    @companies = []
    @shares = []
    @cash = 0
  end

  def buy_company company, price
    @cash -= price
    @companies << company
  end

  def close_company company
    @companies.remove company
  end

  def collect_income cost_of_ownership
    @companies.each do |company|
      @cash += company.income
      @cash -= cost_of_ownership[company.tier]
    end
  end
end
