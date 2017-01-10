require './views/base'

module Views
  class Log < Base
    needs :game
    needs :current_player
    needs email: false

    def content
      log_style = inline(
        overflow_y: 'scroll',
        height: '200px',
        background_color: 'lightgray',
        font_family: "'Inconsolata', monospace",
        margin: '5px 0',
      ) unless email

      div id: 'log', style: log_style do
        div class: 'wrapper' do
          lines = game.log
          lines = lines.last 10 if email
          lines.each { |line| div line }
          div { text '-- Your Turn --' } if game.can_act? current_player
        end
      end

      script <<~JS
        $('#log').scrollTop($('#log')[0].scrollHeight);
      JS
    end

  end
end
