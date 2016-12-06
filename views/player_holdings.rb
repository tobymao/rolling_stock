require './views/base'

module Views
  class PlayerHoldings < Base
    needs :player
    needs :game

    def content
      div do
        div "#{player.name} - $#{player.cash}"
        player.companies.map  { |c| widget Company, company: c, game: game }
      end
    end
  end
end
