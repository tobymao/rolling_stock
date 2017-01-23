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
        render_header corporation.name, 'Corporation', 'The name of the corporation'
        render_header corporation.pp_cash, 'Cash', 'Amount of cash the company has'
        render_header "$#{corporation.book_value}", 'Value', 'Total value of the corporation (company values + cash)'
        title = "$#{corporation.base_income} (Base) + $#{corporation.synergy_income} (Synergies) - $#{corporation.cost_of_ownership tier} (Cost of ownership)"
        render_header "$#{corporation.income tier}", 'Income', title
        render_header "$#{corporation.price}", 'Price', "Current share price of the corporation. $#{corporation.max_dividend} max dividend"
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
          render_footer 'Synergy Bonus', "$#{corporation.synergy_income}"
          render_footer 'Info', 'Price', small: true
        end

        index = corporation.share_price.index
        double_drop = SharePrice::PRICES[index - 2] if index > 1
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
          render_footer 'Value', 'Price', small: true
        end
      end
    end

    def render_footer left, right, small: false
      div style: (small ? inline(font_size: '11px') : nil) do
        div(style: inline(display: 'inline-block', text_align: 'left')) { text left }
        div(style: inline(display: 'inline-block', text_align: 'right', float: 'right')) { text right }
      end
    end

  end
end
