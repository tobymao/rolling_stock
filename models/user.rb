require './models/base'

class User < Base
  one_to_many :games

  attr_reader :companies, :shares, :cash

  def initialize
    @companies = []
    @shares = []
    @cash = 0
  end
end
