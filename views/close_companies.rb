require './views/base'

module Views
  class CloseCompanies < Action
    needs :current_player
    needs :game

    def render_action
      widget EntityOrder, game: game, entities: game.active_entities
      render_controls if game.can_act? current_player
    end

    def render_controls
      div do
        corporations = game.corporations.select { |c| c.owned_by?(current_player) }
        companies = current_player&.companies || []
        return if corporations.empty? && companies.empty?

        game_form do
          div "Companies owned by #{current_player.name}"

          companies.each do |company|
            label do
              input type: 'checkbox', name: data('company'), value: company.name
              text company.name
            end
          end

          corporations.select { |c| c.owned_by? current_player }.each do |corporation|
            div "Companies owned by #{corporation.name}"

            corporation.companies.select(&:active?).each do |company|
              label do
                input type: 'checkbox', name: data('company'), value: company.name
                text company.name
              end
            end
          end

          div do
            input type: 'submit', value: 'Close Companies'
          end
        end
      end
    end

  end
end
