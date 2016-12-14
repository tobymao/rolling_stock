require './views/base'

module Views
  class CloseCompanies < Action
    needs :current_player
    needs :game

    def render_action
      h3 'Close Companies'

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
      end

    end
  end
end
