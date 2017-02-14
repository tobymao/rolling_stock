require './views/base'

module Views
  class Pass < Base
    needs :game
    needs :current_player

    def content
      return unless current_player

      div do
        render_passes
      end unless game.phase == :dividend

      div do
        render_skips
      end

      render_js
    end

    def render_passes
      entities = game.active_entities
      entities.select! { |entity| entity.owned_by? current_player }
      entities.uniq!

      entities.reject! do |entity|
        entity.respond_to?(:pending_closure?) && entity.pending_closure?
      end if game.phase == :closing

      return if entities.empty?

      solo = entities.size == 1
      can_act = game.can_act? current_player
      bidding = !!game.current_bid

      pass_text = 'Auto Pass (checked entities will pass this phase)'

      if bidding
        pass_text = can_act ? 'Leave auction' : 'Leave auction early'
      elsif can_act
        pass_text = solo ? 'Pass your turn' : 'Select entities to pass'
      end

      div pass_text

      game_form do
        entities.each do |entity|
          active = game.can_act? entity
          autopassed = game.autopasses.include? entity

          checkbox_props = {
            type: 'checkbox',
            checked: active || autopassed,
            onclick: 'Pass.onClick(this)',
            disabled: solo && active,
          }

          div do
            input checkbox_props
            render_input 'action', (active ? 'pass' : 'autopass'), !active
            render_input entity.type, entity.id, !active

            label style: inline(margin_left: '5px') do
              text "#{entity.name}#{autopassed ? ' (passing)' : ''}"
            end
          end
        end

        input type: 'submit', value: (can_act ? 'Pass' : 'Save Pass Setting')
      end
    end

    def render_skips
      div onclick: 'Pass.expand(this)', style: inline(display: 'inline-block', cursor: 'pointer') do
        text 'Automatically skip checked phases (click to expand)'
      end

      negative_count = game
        .held_companies
        .select { |c| c.player == current_player }
        .count { |c| c.income - c.cost_of_ownership < 0 }

      div style: inline(color: 'salmon') do
        text 'WARNING: You have negative income companies and phase 7 skip on.'
        text 'If you wish to close companies, uncheck phase 7 skip.'
      end if game.skips.include?([current_player, 7]) && negative_count > 0

      game_form id: 'skip_form', style: inline(display: 'block') do
        game.phase_descriptions.keys.sort.each do |phase|
          skipped = game.skips.include? [current_player, phase]

          div class: 'skip_row', style: (skipped ? '' : inline(display: 'none')) do
            checkbox_props = {
              type: 'checkbox',
              checked: skipped,
              onclick: 'Pass.onClick(this)',
            }

            input checkbox_props
            render_input 'action', 'skip', true
            render_input 'phase', phase, true
            render_input current_player.type, current_player.id, true

            label style: inline(margin_left: '5px') do
              text "Phase #{phase} - #{game.phase_names[phase]}#{skipped ? ' (skipped)' : ''}"
            end
          end
        end

        input type: 'submit', value: 'Save Skip Settings'
      end
    end

    def render_input name, value, disabled
      input name: data(name), value: value, disabled: disabled, type: 'hidden', class: 'pass_input'
    end

    def render_js
      script <<~JS
        var Pass = {
          onClick: function(el) {
            $(el).siblings('.pass_input').attr('disabled', function(_, attr) {
              return !attr
            });
          },

          expand: function(el) {
            $(el).text('Automatically skip checked phases');
            $('#skip_form .skip_row:hidden').show();
          },
        }
      JS
    end

  end
end
