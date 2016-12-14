require './views/base'
require './views/purchaser'

module Views
  class ForeignInvestor < Purchaser
    needs :game

    def content
      div(class: 'heading') { text 'Foreign Investor' }

      investor = game.foreign_investor

      div style: inline(container_style) do
        render_headers investor
        render_companies investor
      end
    end

    def render_headers investor
      div style: inline(headers_style.merge(background_color: 'lightgreen')) do
        render_header "$#{investor.cash}", 'Cash'
        render_header "$#{investor.income game.cost_of_ownership_tier}", 'Income'
      end
    end
  end
end
