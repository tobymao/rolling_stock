require './views/base'

module Views
  class Pass < Base
    needs :game
    needs :current_player

    def content
      entities = game.active_entities
      entities << current_player if game.phase == 3
      entities.select! { |entity| entity.owned_by? current_player }
      entities.uniq!

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
          'Auto Pass (checked entities will pass this phase)'
        end

      div pass_text

      game_form do
        entities.each do |entity|
          active = game.can_act? entity
          autopassed = game.passes.include? entity

          checkbox_props = {
            type: 'checkbox',
            checked: (active || autopassed),
            onclick: 'Pass.onClick(this)',
            disabled: (solo && active),
            data: {
              autopassed: autopassed,
            }
          }

          pass_type_props = {
            name: data('action'),
            value: (active ? 'pass' : 'autopass'),
            type: 'hidden',
            class: 'pass_input',
            disabled: !active,
          }

          entity_props = {
            name: data(entity.type),
            value: entity.id,
            type: 'hidden',
            class: 'pass_input',
            disabled: !active,
          }

          div do
            input checkbox_props
            input pass_type_props
            input entity_props

            label style: inline(margin_left: '5px') do
              text "#{entity.name}#{autopassed ? ' (passing)' : ''}"
            end
          end
        end

        input type: 'submit', value: (can_act ? 'Pass' : 'Save Pass Setting')
      end

      render_js
    end

    def render_js
      script <<~JS
        var Pass = {
          onClick: function(el) {
            $(el).siblings('.pass_input').attr('disabled', function(_, attr) {
              return !attr
            });
          }
        }
      JS
    end

  end
end
