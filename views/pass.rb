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
        solo = entities.size == 1
        entities.each do |entity|
          pass_props = { name: data(entity.type), value: entity.id }

          if solo
            pass_props[:type] = 'hidden'
          else
            pass_props[:type] = 'checkbox'
            pass_props[:checked] = 'true'
          end

          input pass_props
          input type: 'hidden', name: data('action'), value: 'pass'
          label(style: inline(margin_right: '5px')) { text entity.name } unless solo
        end

        submit_props = {
          type: 'submit',
          value: game.can_act?(current_player) ? 'Pass' : 'Pass Out Of Order',
        }

        input submit_props
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
