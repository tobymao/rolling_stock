class Share
  PRESIDENT = 0.2.freeze
  NORMAL    = 0.1.freeze

  attr_accessor :user

  def self.president
    new PRESIDENT
  end

  def self.normal
    new NORMAL
  end

  def initialize value, user = nil
    @value = value
    @user = user
  end
end
