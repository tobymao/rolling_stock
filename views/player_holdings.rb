require './views/base'

module Views
  class PlayerHoldings < Base
    needs :player

    def content
      div do
        text "#{player.name} [#{player.value}]Cash: $#{player.cash} Value: #{player.value}"
      end
      div player.companies
    end
  end
end
