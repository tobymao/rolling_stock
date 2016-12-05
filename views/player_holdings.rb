require './views/base'

module Views
  class PlayerHoldings < Base
    needs :player

    def content
      div do
        div "#{player.name} - $#{player.cash}"
        player.companies.map  { |c| widget Company, company: c, all_companies: all_companies }
      end
    end
  end
end
