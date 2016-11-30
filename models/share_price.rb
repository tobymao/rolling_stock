class SharePrice
  PRICES = [
    0,  5,  6,  7,  8,  9, 10, 11,
    12, 13, 14, 15, 16, 18, 20, 22,
    24, 26, 28, 31, 34, 37, 41, 45,
    50, 55, 60, 66, 73, 81, 90, 100,
  ].freeze

  attr_reader :price, :index

  def self.initial_market
    PRICES.map.with_index { |p, i| new p, i }
  end

  def initialize price, index
    @price = price
    @index = index
  end
end
