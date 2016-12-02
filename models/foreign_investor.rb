class ForeignInvestor
  attr_reader :companies
  attr_accessor :cash

  def initialize
    @companies = []
    @cash = 0
  end

  def purchase_companies companies
    company = companies.first

    while @cash >= company.price
      companies.remove company
      company.owner = self
      @companies << company
      @cash -= company.price
      company = companies.first
    end
  end
end
