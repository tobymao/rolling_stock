require './models/passer'
require './models/purchaser'

class Player
  include Passer
  include Purchaser
  include Ownable

  attr_reader :id, :name, :companies, :shares
  attr_accessor :cash, :order

  def initialize id, name, log = nil
    @id        = id
    @name      = name
    @companies = []
    @shares    = []
    @cash      = 30
    @log       = log || []
  end

  def owner
    self
  end

  def value
    @cash +
      (@companies.map(&:value).reduce(&:+) || 0) +
      (@shares.map { |s| s.corporation.share_price.price }.reduce(&:+) || 0)
  end
end
