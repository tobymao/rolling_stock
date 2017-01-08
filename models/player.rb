require './models/passer'
require './models/purchaser'

class Player < Purchaser
  include Passer
  include Ownable

  attr_reader :id, :name, :shares
  attr_accessor :order

  def initialize id, name, log = nil
    super 30
    @id     = id
    @name   = name
    @shares = []
    @log    = log || []
  end

  def owner
    self
  end

  def value
    @cash +
      @pending_cash +
      (@companies.map(&:value).reduce(&:+) || 0) +
      (@shares.map { |s| s.corporation.share_price.price }.reduce(&:+) || 0)
  end

  def can_sell_shares?
    @shares.any? { |share| share.corporation.can_sell_share? self }
  end

  def corporation_shares corporation
    @shares.select { |s| s.corporation == corporation }
  end
end
