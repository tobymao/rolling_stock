require './views/base'

module Views
  class CloseCompanies < Action
    needs :current_player
    needs :game

    def render_action
      widget EntityOrder, game: game, entities: game.active_entities

      render_controls
    end

    def render_controls
      div do
        companies = current_player&.companies || []

        game_form do
          div "Companies owned by #{current_player.name}"

          current_player.companies.each do |company|
            label do
              input type: 'checkbox', name: data('company'), value: company.name
              text company.name
            end
          end

          game.corporations.select { |c| c.owned_by? current_player }.each do |corporation|
            div "Companies owned by #{corporation.name}"

            corporation.companies.each do |company|
              label do
                input type: 'checkbox', name: data('company'), value: company.name
                text company.name
              end
            end
          end

          input type: 'submit', value: 'Close Companies'
        end unless companies.empty?
      end
    end

  end
end
