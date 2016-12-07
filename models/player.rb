require './models/passer'
require './models/purchaser'

class Player
  include Passer
  include Purchaser

  attr_reader :id, :name, :companies, :shares
  attr_accessor :cash

  def initialize id, name
    @id = id
    @name = name
    @companies = []
    @shares = []
    @cash = 30
  end

  def owner
    self
  end

  def value
    @cash + (@companies.map(&:value).reduce(&:+) || 0)
  end
end
