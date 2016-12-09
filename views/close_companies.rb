require './views/base'

module Views
  class CloseCompanies < Base
    needs :current_player
    needs :game

    def content
      h3 'Close Companies'

      game_form do
        div "Companies owned by #{current_player.name}"

        current_player.companies.each do |company|
          label do
            input type: 'checkbox', name: data('company'), value: company.symbol
            text company.symbol
          end
        end

        game.corporations.select { |c| c.owned_by? current_player }.map do |corporation|
          div "Companies owned by #{corporation.name}"

          corporation.companies.each do |company|
            label do
              input type: 'checkbox', name: data('company'), value: company.symbol
              text company.symbol
            end
          end
        end

        input type: 'submit', value: 'Close Companies'
      end

    end
  end
end
