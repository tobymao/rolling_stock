require './views/base'

module Views
  class Action < Base
    needs :game
    needs :current_player

    def content
      div class: 'heading' do
        text "Round: #{game.round} Phase: #{game.phase} (#{game.phase_name})"
      end

      widget Log, log: game.log, active: game.can_act?(current_player)

      default = {
        display: 'inline-block',
        vertical_align: 'top',
        min_width: '360px',
      }

      div style: inline(default), class: 'wrapper' do
        render_action

        div do
          widget Pass, game: game, current_player: current_player
        end unless game.phase == 9
      end
    end
  end
end
