require './views/base'

module Views
  class GameMail < Base
    needs :game
    needs :current_user

    def content
      current_player = game.player_by_id current_user.id

      a "Go To Game #{game.id}", href: "#{app.request.base_url}#{app.path(game)}"

      log_style = inline(
        background_color: 'lightgray',
        padding: '5px',
        margin: '10px 0',
      )

      div style: log_style do
        widget Log, game: game, current_player: current_player, email: true
      end

      widget Players, players: game.players, current_player: current_player
    end

  end
end
