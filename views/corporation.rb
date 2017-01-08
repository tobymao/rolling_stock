require './views/base'
require './views/purchaser'

module Views
  class Corporation < Purchaser
    needs :corporation
    needs :tier

    def content
      div style: inline(container_style) do
        render_headers corporation
        render_companies corporation, true
        render_price_movement
      end
    end

    def render_headers corporation
      div style: inline(headers_style.merge(background_color: 'lightblue')) do
        img style: inline(vertical_align: 'top'), src: corporation.image_url
        render_header corporation.name, 'Corp', true
        render_header corporation.pp_cash, 'Cash'
        render_header "$#{corporation.book_value}", 'Value'
        render_header "$#{corporation.share_price.price}", 'Price'
        render_header "$#{corporation.income(tier)}", 'Income'
      end
    end

    def render_price_movement
      div style: inline(text_align: 'left') do
        block_style = inline(
          display: 'inline-block',
          margin_left: '24px',
          text_align: 'left',
          width: '40%',
        )

        div style: block_style do
          render_footer 'President', corporation.president.name.upcase
          render_footer 'Issued Shares', corporation.shares_issued
          render_footer 'Shares In Bank', corporation.bank_shares.size
          render_footer 'Market Cap', corporation.market_cap
          render_footer 'Info', 'Price', inline(font_size: '11px')
        end

        index = corporation.share_price.index
        double_drop = SharePrice::PRICES[index - 2]
        single_drop = SharePrice::PRICES[index - 1]
        current_price = SharePrice::PRICES[index]
        single_jump = SharePrice::PRICES[index + 1]
        double_jump = SharePrice::PRICES[index + 2]
        num = corporation.shares_issued

        div style: block_style do
          render_footer "$#{num * single_jump} - ∞", "$#{double_jump}" if double_jump
          render_footer "$#{num * current_price}-$#{num * single_jump - 1}", "$#{single_jump}" if single_jump
          render_footer "$#{num * single_drop}-$#{num * current_price - 1}", "$#{single_drop}" if single_drop
          render_footer "$0 - $#{num * single_drop - 1}", "$#{double_drop}" if double_drop
          render_footer 'Value', 'Price', inline(font_size: '11px')
        end
      end
    end

    def render_footer left, right, footer_style = ''
      div style: footer_style do
        div(style: inline(display: 'inline-block', text_align: 'left')) { text left }
        div(style: inline(display: 'inline-block', text_align: 'right', float: 'right')) { text right }
      end
    end

  end
end
