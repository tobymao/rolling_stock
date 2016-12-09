class Offer
  attr_accessor :corporation, :company, :price

  def initialize corporation, company, price
    @corporation = corporation
    @company = company
    @price = price
  end
end
