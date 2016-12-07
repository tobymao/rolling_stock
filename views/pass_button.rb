require './views/base'

module Views
  class PassButton < Base
    needs :game
    needs :current_player

    def content
      props = {
        action: app.path(game, 'action'),
        method: 'post',
      }

      active = game.active_entities.select { |e| e.owner == current_player }

      form props do
        rawtext app.csrf_tag
        active.map do |entity|
          input type: 'hidden', name: "data[#{entity.type}][]", value: entity.id
        end
        input type: 'hidden', name: "data[action]", value: 'pass'
        input type: 'submit', value: 'Pass'
      end unless active.empty?
    end
  end
end
