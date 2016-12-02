require './models/passer'

class Player
  include Passer

  attr_reader :id, :name, :companies, :shares, :cash

  def initialize id, name
    @id = id
    @name = name
    @companies = []
    @shares = []
    @cash = 0
  end

  def value
    @cash + (@companies.map(&:value).reduce(&:+) || 0)
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
