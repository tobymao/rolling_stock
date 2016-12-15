require './views/base'

module Views
  class Bid < Base
    needs :bid
    needs :tier

    def content
      h3 "Current Bid"
      div "High Bidder - #{bid.player.name}"
      div "Price - #{bid.price}"
      widget Company, company: bid.company, tier: tier
    end
  end
end
