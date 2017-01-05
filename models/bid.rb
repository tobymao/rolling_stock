class Bid
  attr_accessor :player, :company, :price

  def initialize player, company, price, log = nil
    raise GameException, 'Bid must be greater than value' if price < company.value
    raise GameException, 'Bid must not be more than cash on hand' if price > player.cash

    @player  = player
    @company = company
    @price   = price
    @log     = log || []
    @log << "#{player.name} bids $#{@price} for #{@company.name}"
  end
end
