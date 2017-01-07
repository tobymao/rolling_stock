require './views/base'

module Views
  class Log < Base
    needs :game
    needs :current_player

    def content
      log_style = inline(
        overflow_y: 'scroll',
        height: '200px',
        background_color: 'lightgray',
        font_family: "'Inconsolata', monospace",
        margin: '5px 0',
      )

      div style: log_style do
        div class: 'wrapper' do
          div style: inline(font_weight: 'bold') do
            text 'Your Turn'
          end if game.can_act? current_player

          game.log.reverse.each { |line| div line }
        end
      end

      game_form style: inline(width: 'calc(100% - 20px)'), class: 'wrapper' do
        input type: 'text', name: data('message'), style: inline(width: 'calc(100% - 65px)', margin_right: '5px')
        input type: 'hidden', name: data('player'), value: current_player.id
        input type: 'submit', value: 'Send'
      end if current_player
    end

  end
end
