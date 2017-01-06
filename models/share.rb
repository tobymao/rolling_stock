class Share
  attr_accessor :corporation, :president

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

  def valid_tier? tier
    range =
      case @tier
      when :red
        [10, 14]
      when :orange
        [10, 20]
      when :yellow
        [10, 26]
      when :green
        [15, 34]
      when :blue
        [22, 45]
      when :purple
        [28, 45]
      else
        raise GameException, "Invalid share price for #{@tier}"
      end

    share_price.price.between? range[0], range[1]
  end
end
