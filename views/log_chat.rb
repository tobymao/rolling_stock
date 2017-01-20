require './views/base'

module Views
  class LogChat < Base
    needs :game
    needs :current_player

    def content
      return unless current_player

      text_input_props = {
        id: 'log_chat_input',
        type: 'text',
        name: data('message'),
        style: inline(
          width: 'calc(100% - 65px)',
          margin_right: '5px',
        ),
      }

      game_form style: inline(width: 'calc(100% - 20px)'), class: 'wrapper' do
        input text_input_props
        input type: 'hidden', name: data('player'), value: current_player.id
        input type: 'submit', value: 'Send'
      end
    end

  end
end
