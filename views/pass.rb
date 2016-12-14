require './views/base'

module Views
  class Pass < Base
    needs :game
    needs :current_player

    def content
      entities = game.active_entities.select {|e| e.owned_by? current_player }
      return if entities.empty?

      game_form do
        entities.each do |entity|
          input type: 'hidden', name: data(entity.type), value: entity.id
        end

        input type: 'hidden', name: data('action'), value: 'pass'
        button_text = game.can_act?(current_player) ? "Pass" : "Pass Out Of Order"
        input type: 'submit', value: button_text
      end
    end
  end
end
