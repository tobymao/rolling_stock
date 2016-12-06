require './views/base'

module Views
  class PassButton < Base
    needs :game
    needs :entity

    def content
      form action: app.path(game, 'action'), method: 'post' do
        rawtext app.csrf_tag
        input type: 'hidden', name: "data[#{entity.type}]", value: entity.id
        input type: 'hidden', name: "data[action]", value: 'pass'
        input type: 'submit', value: 'Pass'
      end
    end
  end
end
