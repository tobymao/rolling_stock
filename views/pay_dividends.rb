require './views/base'

module Views
  class PayDividends < Action
    needs :current_player
    needs :game

    def render_action
      widget EntityOrder, game: game, entities: game.corporations

      corporation = game.acting.first

      div do
        game_form do
          div corporation.name

          max_dividend = corporation.cash / corporation.shares_issued

          input type: 'hidden', name: data('corporation'), value: corporation.name
          input type: 'number', max: max_dividend, name: data('amount'), value: 0

          input type: 'submit', value: 'Pay Dividends'
        end if game.can_act? current_player
      end
    end
  end
end
