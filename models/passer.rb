module Passer
  attr_reader :passed

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

  def type
    self.class.to_s.downcase
  end
end
