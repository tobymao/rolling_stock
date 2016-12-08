require './views/base'

module Views
  class Pass < Base
    needs :game
    needs :current_player

    def content
      render_js

      entities = game.active_entities.select { |e| e.owner == current_player }
      active_entity = game.acting.first if game.acting.size == 1

      game_form do
        single_pass active_entity
        input type: 'submit', value: "Pass"
      end if active_entity&.owner == current_player

      game_form do
        entities.size == 1 ? single_pass(entities.first) : multi_pass(entities)
        input type: 'submit', value: 'Auto Pass'
      end unless entities.empty?
    end

    def render_js
      script <<~JS
        var Pass = {
          toggle: function(el) {
            el.nextSibling.disabled = !el.checked;
          },

          selectAll: function(el) {
            var inputs = el.parentNode.getElementsByTagName('input');
            for (var i = 0; i < inputs.length; i++) {
              var input = inputs[i];
              if (input.type == "checkbox") {
                input.checked = true;
                this.toggle(input);
              }
            }
            return false;
          },
        }
      JS
    end

    def single_pass entity
      input type: 'hidden', name: data(entity.type), value: entity.id
      input type: 'hidden', name: data('action'), value: 'pass'
    end

    def multi_pass entities
      button type: 'button', onclick: 'Pass.selectAll(this)' do
        text 'Select All'
      end

      entities.each do |entity|
        label do
          input type: 'checkbox', onclick: 'Pass.toggle(this)', name: data(entity.type), value: entity.id
          input type: 'hidden', name: data('action'), value: 'pass', disabled: true
          text entity.id
        end
      end
    end

  end
end
