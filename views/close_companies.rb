require './views/action'

module Views
  class CloseCompanies < Action
    needs :current_player
    needs :game

    def render_action
      widget EntityOrder, game: game
      render_controls if game.can_act? current_player
    end

    def render_controls
      div do
        companies = game
          .active_entities
          .select { |c| c.owned_by? current_player }

        return if companies.empty?

        game_form do
          companies.each { |company| render_check_box company }
          input type: 'submit', value: 'Close Companies'
        end
      end
    end

    def render_check_box company
      div style: inline(margin_right: '5px') do
        input type: 'checkbox', name: data('company'), value: company.name
        text company.name
      end
    end

  end
end
