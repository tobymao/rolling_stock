require './models/passer'
require './models/purchaser'

class Player
  include Passer
  include Purchaser

  attr_reader :id, :name, :companies, :shares, :cash

  def initialize id, name
    @id = id
    @name = name
    @companies = []
    @shares = []
    @cash = 30
  end

  def value
    @cash + (@companies.map(&:value).reduce(&:+) || 0)
  end

=begin
  def buy_company company, price
    @cash -= price
    company.owner = self
    @companies << company
  end
=end

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
