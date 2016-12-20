require './views/base'

module Views
  class Pass < Base
    needs :game
    needs :current_player

    def content
      entities = game.active_entities.select { |e| e.owned_by? current_player }
      return if entities.empty?

      render_js

      game_form do
        entities.each do |entity|
          input type: 'checkbox', name: data(entity.type), value: entity.id, checked: true, onclick: 'Pass.onClick(this)'
          input type: 'hidden', name: data('action'), value: 'pass'
          label entity.name
        end
        button_text = game.can_act?(current_player) ? 'Pass' : 'Pass Out Of Order'
        input type: 'submit', value: button_text
      end
    end

    def render_js
      script <<~JS
        var Pass = {
          onClick: function(el) {
            $(el).next().attr('disabled', !el.checked);
          }
        }
      JS
    end
  end

end
