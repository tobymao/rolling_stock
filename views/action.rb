require './views/base'

module Views
  class Action < Base
    needs :game
    needs :current_player

    def content
      action_widget if game.can_act? current_player
      widget Pass, game: game, current_player: current_player
    end

    def action_widget
      case game.phase
      when 2
        widget FormCorporations, game: game, current_player: current_player
      when 3
        widget CompanyAuction, game: game, current_player: current_player
      when 7
        widget CloseCompanies, game: game, current_player: current_player
      end
    end
  end
end
