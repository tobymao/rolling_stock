require './models/passer'
require './models/purchaser'

class Player
  include Passer
  include Purchaser

  attr_reader :id, :name, :companies, :shares
  attr_accessor :cash

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

  def close_company company
    @companies.delete company
  end

  def collect_income tier
    @companies.each do |company|
      @cash += company.income
      @cash -= company.cost_of_ownership tier
    end
  end
end
