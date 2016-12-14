require './views/base'
require './views/purchaser'

module Views
  class Corporations < Purchaser
    needs :game

    def content
      div(class: 'heading') { text 'Corporations' }

      div do
        game.corporations.each do |corporation|
          render_corporation corporation
        end
      end
    end

    def render_corporation corporation
      div style: inline(container_style) do
        render_headers corporation
        render_companies corporation
      end
    end

    def render_headers corporation
      div style: inline(headers_style.merge(background_color: 'lightblue')) do
        render_header corporation.name, 'Name'
        render_header "$#{corporation.cash}", 'Cash'
        render_header "$#{corporation.book_value}", 'Value'
        render_header "$#{corporation.share_price.price}", 'Share Price'
        render_header "$#{corporation.income(game.cost_of_ownership_tier)}", 'Income'
      end
    end

  end
end
