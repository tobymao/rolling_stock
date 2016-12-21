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
        render_header corporation.name, 'Corp', true
        render_header "$#{corporation.cash}", 'Cash'
        render_header "$#{corporation.book_value}", 'Value'
        render_header "$#{corporation.share_price.price}", 'Price'
        render_header "$#{corporation.income(tier)}", 'Income'
      end
    end

    def render_price_movement
      div do
        div style: inline(display: 'inline-block', text_align: 'left', margin_right: '25px') do
          div "President: #{corporation.president.name}"
          div "Issued Shares: #{corporation.shares_issued}"
          div "Shares In Bank: #{corporation.bank_shares.size}"
          div "Market Cap: $#{corporation.market_cap}"
        end

        index = corporation.share_price.index
        double_drop = SharePrice::PRICES[index - 2]
        single_drop = SharePrice::PRICES[index - 1]
        current_price =  SharePrice::PRICES[index]
        single_jump = SharePrice::PRICES[index + 1]
        double_jump = SharePrice::PRICES[index + 2]
        num = corporation.shares_issued

        div style: inline(display: 'inline-block', text_align: 'right') do
          div "$#{num * single_jump} jump to $#{double_jump}"
          div "$#{num * current_price}-$#{num * single_jump - 1} jump to $#{single_jump}"
          div "$#{num * single_drop}-$#{num * current_price - 1} drop to $#{single_drop}"
          div "$#{num * single_drop - 1} drop to $#{double_drop}"
        end
      end
    end

  end
end
