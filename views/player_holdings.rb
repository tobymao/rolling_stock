require './views/base'

module Views
  class PlayerHoldings < Base
    needs :player

    def content
      div player.name
      div "Cash: #{player.cash}, Value: #{player.value}"
      div player.companies
    end
  end
end
