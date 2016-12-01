module Passer
  attr_accessor :passed

  def passed?
    @passed
  end

  def pass
    @pass = true
  end

  def unpass
    @pass = false
  end
end
