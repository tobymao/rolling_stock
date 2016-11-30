require './models/base'

class User < Base
  one_to_many :games

  def initialize
  end
end
