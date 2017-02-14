class SharePrice
  PRICES = [
    0,  5,  6,  7,  8,  9, 10, 11,
    12, 13, 14, 15, 16, 18, 20, 22,
    24, 26, 28, 31, 34, 37, 41, 45,
    50, 55, 60, 66, 73, 81, 90, 100,
  ].freeze

  RANGES = {
    red:    [6, 10],
    orange: [6, 14],
    yellow: [6, 17],
    green:  [11, 20],
    blue:   [15, 23],
    purple: [18, 23],
  }.freeze

  attr_reader :price, :index
  attr_accessor :corporation

  def self.initial_market
    self::PRICES.map.with_index { |p, i| new p, i }
  end

  def initialize price, index
    @price = price
    @index = index
  end

  def valid_range? tier
    @index.between? *self.class::RANGES[tier]
  end

  def unowned?
    !corporation
  end

  def max_dividend
    @price / 3
  end

end
