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
      share_style = inline(
        display: 'inline-block',
        margin: '5px',
        vertical_align: 'top',
        border: 'solid 1px rgba(0,0,0,0.2)',
        width: '60px',
        height: '40px',
      )

      div style: share_style do
        div share_price.price
        div share_price.corporation&.name
      end
    end

  end
end
