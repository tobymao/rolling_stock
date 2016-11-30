require './models/base'

class User < Base
  one_to_many :games

  attr_reader :cash

  def initialize
    #leaving in cash in the hopes that users can be charged someday.
    @cash = 0
  end
end
