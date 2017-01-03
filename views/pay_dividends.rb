require './views/base'

module Views
  class PayDividends < Action
    needs :current_player
    needs :game

    def render_action
      widget EntityOrder, game: game, entities: game.corporations

      corporation = game.acting.first

      widget Corporations, corporations: [corporation], tier: game.ownership_tier, header: false

      div do
        game_form do
          divided_props = {
            type: 'number',
            style: inline(width: '50px', margin: '0 5px 0 5px'),
            max: corporation.max_dividend,
            name: data('amount'),
            value: 0,
          }

          label 'Pay Dividends to Share Holders'
          input divided_props
          input type: 'hidden', name: data('corporation'), value: corporation.name
          input type: 'submit', value: 'Pay Dividends'
        end if game.can_act? current_player
      end
    end
  end
end
