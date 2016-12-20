require './models/purchaser'

class ForeignInvestor
  include Purchaser

  attr_reader :companies
  attr_accessor :cash

  def initialize log = nil
    @companies = []
    @cash = 4
    @log = log || []
  end

  def name
    'Foreign Investor'
  end

  def close_companies tier
    @companies.each do |company|
      close_company(company) if company.income < company.cost_of_ownership(tier)
    end
  end

  def collect_income tier
    amount = income(tier) + 5
    @cash += amount
    @log << "#{self.name} collects #{amount} income"
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
