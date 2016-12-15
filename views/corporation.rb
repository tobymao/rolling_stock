require './views/base'
require './views/purchaser'

module Views
  class Corporation < Purchaser
    needs :game
    needs :corporation

    def content
      div style: inline(container_style) do
        render_headers corporation
        render_companies corporation
      end
    end

    def render_headers corporation
      div style: inline(headers_style.merge(background_color: 'lightblue')) do
        render_header corporation.name, 'Corp'
        render_header "$#{corporation.cash}", 'Cash'
        render_header "$#{corporation.book_value}", 'Value'
        render_header "$#{corporation.share_price.price}", 'Share Price'
        render_header "$#{corporation.income(game.cost_of_ownership_tier)}", 'Income'
      end
    end

  end
end
