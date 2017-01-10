require './views/base'
require './views/purchaser'

module Views
  class Players < Purchaser
    needs :players

    def content
      div do
        players.each do |player|
          render_player player
        end
      end
    end

    def render_player player
      div style: inline(container_style) do
        render_headers player
        render_companies player
        render_shares player unless player.shares.empty?
      end
    end

    def render_headers player
      div style: inline(headers_style) do
        render_header player.name.upcase, 'Player', truncate: true
        render_header player.pp_cash, 'Cash', 'Amount of cash the player has'
        render_header "$#{player.value}", 'Value', 'Total value of the player (company values + stocks + cash)'
        render_header "$#{player.income(tier)}", 'Income', "$#{player.base_income} (Base) - $#{player.cost_of_ownership tier} (Cost of ownership)"
        render_header player.order, 'Order', 'Order in phase 3 (Auction companies)'
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

      div do
        render_header names, 'Corp'
        render_header num_shares, 'Shares'
        render_header prices, 'Price'
        render_header values, 'Value'
      end
    end
  end

end
