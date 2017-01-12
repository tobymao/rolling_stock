require './views/base'

module Views
  class Pass < Base
    needs :game
    needs :current_player

    def content
      entities = game.active_entities.select do |entity|
        entity.owned_by?(current_player) && !game.passes.include?(entity)
      end

      entities.reject! do |entity|
        entity.respond_to?(:pending_closure?) && entity.pending_closure?(game.ownership_tier)
      end if game.phase == 7

      return if entities.empty?
      solo = entities.size == 1
      can_act = game.can_act? current_player

      pass_text =
        if can_act
          if solo
            game.current_bid ? 'Leave auction' : 'Pass your turn'
          else
            'Select entities to pass'
          end
        else
          solo ? 'Pass your turn early' : 'Select entities to pass early'
        end

      div pass_text

      render_js

      game_form do
        entities.each do |entity|
          entity_active = game.can_act? entity

          pass_props = {
            name: data(entity.type),
            value: entity.id,
            onclick: 'Pass.onClick(this)',
          }

          if solo
            pass_props[:type] = 'hidden'
          else
            pass_props[:type] = 'checkbox'
            pass_props[:checked] = 'true' if entity_active
          end

          div do
            input pass_props
            input type: 'hidden', name: data('action'), value: 'pass', disabled: !(solo || entity_active)
            label(style: inline(margin_right: '5px')) { text entity.name } unless solo
          end
        end

        submit_props = {
          type: 'submit',
          value: can_act ? 'Pass' : 'Pass Out Of Order',
        }

        div do
          input submit_props
        end
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
