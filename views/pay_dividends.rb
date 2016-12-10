require './views/base'

module Views
  class PayDividends < Base
    needs :current_player
    needs :game

    def content
      game_form do
        corporation = game.acting.first

        div corporation.name

        max_dividend = corporation.cash / corporation.shares_issued

        input type: 'hidden', name: data('corporation'), value: corporation.name
        input type: 'number', max: max_dividend, name: data('amount'), value: 0

        input type: 'submit', value: 'Pay Dividends'
      end
    end
  end
end
