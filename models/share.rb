class Share
  attr_accessor :president, :user

  def self.president
    new true
  end

  def self.normal
    new false
  end

  def initialize president, user = nil
    @president = president
    @user = user
  end
end
