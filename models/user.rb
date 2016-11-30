require './models/base'

class User < Base
  attr_reader :companies

  def initialize
    @companies = []
  end
end
