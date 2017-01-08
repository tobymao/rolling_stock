require './views/base'

module Views
  class LogChat < Base
    needs :game
    needs :current_player

    def content
      return unless current_player

      game_form style: inline(width: 'calc(100% - 20px)'), class: 'wrapper' do
        input type: 'text', name: data('message'), style: inline(width: 'calc(100% - 65px)', margin_right: '5px')
        input type: 'hidden', name: data('player'), value: current_player.id
        input type: 'submit', value: 'Send'
      end
    end

  end
end
