require './models/share_price'

class SharePriceV2 < SharePrice
  PRICES = [
    0,  5,  6,  7,  8,
    9, 10, 11, 12, 13, 14,
    16, 18, 20, 22, 24,
    27, 30, 33, 37, 41,
    45, 50, 55, 61, 68, 75
  ].freeze

  RANGES = {
    red:    [6, 10],
    orange: [6, 13],
    yellow: [11, 16],
    green:  [14, 19],
    blue:   [17, 19],
  }.freeze

  def stars shares_issued
    (shares_issued * @price / 10.0).round
  end
end
