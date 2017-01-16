require './views/base'

module Views
  class Action < Base
    needs :game
    needs :current_player

    def content
      default = {
        display: 'inline-block',
        vertical_align: 'top',
      }

      div(class: 'heading') { text game.phase_description }

      div style: inline(default), class: 'wrapper' do
        render_action

        widget Pass, game: game, current_player: current_player
      end
    end
  end
end
