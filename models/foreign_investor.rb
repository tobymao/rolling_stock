require './models/purchaser'

class ForeignInvestor < Purchaser
  include Ownable

  def initialize log = nil
    super 4
    @log = log || []
  end

  def owner
    self
  end

  def name
    'Foreign Investor'
  end

  def close_companies
    @companies.each do |company|
      close_company(company) if company.income < company.cost_of_ownership
    end
  end

  def income
    super + 5
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
