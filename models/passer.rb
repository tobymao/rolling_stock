module Passer
  attr_accessor :passed

  def passed?
    @passed
  end

  def active?
    !@passed
  end

  def pass
    @passed = true
  end

  def unpass
    @passed = false
  end
end
