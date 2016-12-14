require './views/base'
require './views/purchaser'

module Views
  class Players < Purchaser
    needs :game
    needs :current_player

    def content
      div class: 'heading' do
        text 'Players'
      end

      div do
        game.players.rotate(current_player.order).each do |player|
          render_player player
        end
      end
    end

    def render_player player
      div style: inline(container_style) do
        render_headers player
        render_companies player
        render_shares player
      end
    end

    def render_headers player
      div style: inline(headers_style) do
        render_header player.name, 'Name'
        render_header "$#{player.cash}", 'Cash'
        render_header "$#{player.value}", 'Value'
        render_header "$#{player.income(game.cost_of_ownership_tier)}", 'Income'
        render_header player.order, 'Order'
      end
    end

    def render_shares player
      names = []
      num_shares = []
      prices = []
      values = []

      player.shares.group_by(&:corporation).each do |corporation, shares|
        num = shares.size
        price = corporation.share_price.price
        names << corporation.name
        num_shares << "#{corporation.owner == player ? '*': ''} #{num}"
        prices << "$#{price}"
        values << "$#{num * price}"
      end

      shares_style = inline(
        position: 'absolute',
        bottom: 0,
      )

      div style: shares_style do
        render_header names, 'Corporation'
        render_header num_shares, 'Shares'
        render_header prices, 'Price'
        render_header values, 'Value'
      end
    end
  end

end
