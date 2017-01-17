class Offer
  attr_accessor :corporation, :company, :price
  attr_reader :suitors

  def initialize corporation, company, price, suitors, log = nil
    raise GameException, 'Cannot offer more cash than you have' if price > corporation.cash
    @corporation = corporation
    @company     = company
    @price       = price
    @suitors     = suitors || []
    @log         = log || []
    @log << "#{corporation.name} offers $#{price} for #{company.name}"
  end

  def suitor? owner
    @suitors.any? { |c| c.owned_by? owner }
  end

  def foreign_purchase?
    company.owner.is_a? ForeignInvestor
  end
end
