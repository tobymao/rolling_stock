require './views/base'

module Views
  class GameMail < Base
    needs :game
    needs :current_user

    def content
      current_player = game.player_by_id current_user.id
      tier = game.ownership_tier

      a "Go To Game #{game.id}", href: current_path
      br
      widget Log, game: game, current_player: current_player
      widget Players, players: game.players, tier: tier, current_player: current_player
    end

  end
end
