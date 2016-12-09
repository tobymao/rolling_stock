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
        render_action FormCorporations
      when 3
        render_action AuctionCompanies
      when 6
        render_action BuyCompanies
      when 7
        render_action CloseCompanies
      end
    end

    def render_action klass
      widget klass, game: game, current_player: current_player
    end
  end
end
