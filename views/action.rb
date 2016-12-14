require './views/base'

module Views
  class Action < Base
    needs :game
    needs :current_player

    def content
      div class: 'heading' do
        text "Round: #{game.round} Phase: #{game.phase} (#{game.phase_name})"
      end

      default = {
        display: 'inline-block',
        vertical_align: 'top',
        padding: '5px',
        min_width: '360px',
      }

      div style: inline(default) do
        render_action
        widget Pass, game: game, current_player: current_player
      end
    end
  end
end
