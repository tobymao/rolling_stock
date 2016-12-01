class ForeignInvestor
  attr_reader :companies
  attr_accessor :cash

  def initialize
    @companies = []
    @cash = 0
  end
end
