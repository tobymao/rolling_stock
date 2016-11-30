#require './models/base'

class Player 
  #many_to_one :games

  attr_reader :companies, :shares, :cash

  def initialize
    @companies = []
    @shares = []
    @cash = 0
  end
end
