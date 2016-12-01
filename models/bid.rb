class Player
  attr_accessor :player, :company, :price

  def initialize player, company, price
    @player = player
    @company = company
    @price = price
  end
end
