require './views/base'

module Views
  class FormCorporations < Base
    needs :current_player
    needs :game

    def content
      game_form do
        select do
          game.available_corporations.each do |corporation|
            option(value: corporation) { text corporation }
          end
        end

        widget Companies, companies: current_player.companies

        input type: 'hidden', name: data('player'), value: current_player.id
        input type: 'submit', value: 'Form Corporation'
      end
    end
  end
end
