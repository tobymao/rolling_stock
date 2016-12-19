require './models/purchaser'

class ForeignInvestor
  include Purchaser

  attr_reader :companies
  attr_accessor :cash

  def initialize
    @companies = []
    @cash = 4
  end

  def close_companies tier
    @companies.each do |company|
      close_company(company) if company.income < company.cost_of_ownership(tier)
    end
  end

  def collect_income tier
    @cash += 5
    super
  end

  def purchase_companies available_companies
    available_companies.sort_by! &:value
    company = available_companies.first

    while company && @cash >= company.value
      buy_company company, company.value
      company = available_companies.first
    end
  end
end
