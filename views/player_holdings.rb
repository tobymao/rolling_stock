require './views/base'

module Views
  class PlayerHoldings < Base
    needs :player
    needs :game

    def content
      div do
        div do
          span "*" if game.active_entity == player
          span "#{player.name} - $#{player.cash}"
        end
        player.companies.map  { |c| widget Company, company: c, game: game }
      end
    end
  end
end
