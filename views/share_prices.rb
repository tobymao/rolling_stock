require './views/base'

module Views
  class SharePrices < Base
    needs :share_prices

    def content
      div(class: 'heading') { text 'Share Prices' }

      share_prices.each do |share_price|
        render_share_price share_price
      end
    end

    def render_share_price share_price
      div share_price.price
    end

  end
end
