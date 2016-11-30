class Player
  attr_reader :companies, :shares, :cash

  def initialize
    @companies = []
    @shares = []
    @cash = 0
  end
end
