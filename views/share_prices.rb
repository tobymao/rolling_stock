require './views/base'

module Views
  class SharePrices < Base
    needs :share_prices
    needs :company_class

    def content
      div(class: 'heading') { text 'Share Prices' }

      div class: 'wrapper' do
        share_prices.each do |share_price|
          render_share_price share_price
        end
      end
    end

    def render_share_price share_price
      share_style = inline(
        display: 'inline-block',
        margin: '5px',
        padding: '2px',
        vertical_align: 'top',
        border: 'solid 1px rgba(0,0,0,0.2)',
        width: '80px',
        height: '50px',
        position: 'relative',
      )

      div style: share_style, title: "$#{share_price.max_dividend} max dividend" do
        span share_price.price
        if corporation = share_price.corporation
          img style: inline(position: 'absolute', right: '2px'), src: corporation.image_url
          div corporation.name
        end

        div style: inline(position: 'absolute', bottom: 0, vertical_align: 'bottom') do
          company_class::TIERS.each do |tier|
            if share_price.valid_range? tier
              range_style = inline(
                background_color: company_class::color_for_tier(tier),
                width: '80px',
                height: '5px',
                margin_bottom: '1px',
              )

              div style: range_style
            end
          end
        end
      end
    end

  end
end
