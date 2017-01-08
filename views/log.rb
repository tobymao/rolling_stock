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
    end

  end
end
