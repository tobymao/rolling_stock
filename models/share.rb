class Share
  attr_accessor :corporation

  def self.president corporation
    new corporation, true
  end

  def self.normal corporation
    new corporation, false
  end

  def initialize corporation, president
    @corporation = corporation
    @president = president
  end

  def president?
    @president
  end
end
