require './views/base'

module Views
  class PlayerHoldings < Base
    needs :player
    needs :game

    def content
      div do
        div do
          span "#{player.name} - $#{player.cash}"
        end
        widget Shares, shares: player.shares
        widget Companies, companies: player.companies
      end
    end
  end
end
