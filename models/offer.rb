class Offer
  attr_accessor :corporation, :company, :price
  attr_reader :suitors

  def initialize corporation, company, price, suitors, log = nil
    @corporation = corporation
    @company     = company
    @price       = price
    @suitors     = suitors || []
    @log         = log || []
    @log << "Corporation #{corporation.name} offers #{price} for #{company.name}"
  end

  def suitor? owner
    @suitors.any? { |c| c.owned_by? owner }
  end

  def foreign_purchase?
    company.owner.is_a? ForeignInvestor
  end
end
