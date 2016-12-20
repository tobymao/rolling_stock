class Bid
  attr_accessor :player, :company, :price

  def initialize player, company, price, log = nil
    @player  = player
    @company = company
    @price   = price
    @log     = log || []
    @log << "#{player.name} bids #{@price} for #{@company.name}"
  end
end
