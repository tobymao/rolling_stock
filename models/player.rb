require './models/base'

class Player < Base
  #one_to_many :games
  many_to_one: game

  attr_reader :companies, :shares, :cash

  def initialize
    @companies = []
    @shares = []
    @cash = 0
  end
end
