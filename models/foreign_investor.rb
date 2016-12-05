require './models/purchaser'

class ForeignInvestor
  include Purchaser

  attr_reader :companies
  attr_accessor :cash

  def initialize
    @companies = []
    @cash = 0
  end

  def purchase_companies companies
    company = companies.first

    while company && @cash >= company.price
      buy_company company, company.price
      company = companies.first
    end
  end
end
