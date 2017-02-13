require './views/base'

module Views
  class PayDividends < Action
    needs :current_player
    needs :game

    def render_action
      widget EntityOrder, game: game, entities: game.corporations

      corporation = game.acting.first

      widget Corporations, corporations: [corporation]

      div do
        game_form do
          divided_props = {
            type: 'number',
            style: inline(width: '50px', margin: '0 5px 0 5px'),
            min: 0,
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

      render_info_table corporation
    end

    def render_info_table corporation
      table_style = inline(
        display: 'table',
        width: '160px',
        margin: '5px 0 5px',
      )

      div style: table_style do
        div style: inline(display: 'table-row', font_weight: 'bold') do
          render_column 'Dividend'
          render_column 'Cash'
          render_column 'Value'
        end

        (0..corporation.max_dividend).each do |dividend|
          div style: inline(display: 'table-row') do
            total = dividend * corporation.shares_issued
            render_column "$#{dividend}"
            render_column "$#{corporation.cash - total}"
            render_column "$#{corporation.book_value - total}"
          end
        end
      end
    end

    def render_column data
      col_style = inline(
        margin: '5px',
        display: 'table-cell',
        text_align: 'right',
      )
      div(style: col_style) { text data }
    end
  end
end
