require './views/base'

module Views
  class EntityOrder < Base
    needs :game
    needs :entities

    def content
      entities.each_with_index do |entity, index|
        s = {
          display: 'inline-block',
          margin_right: '5px',
          padding_left: '5px',
        }

        s[:text_decoration] = 'underline' if game.acting.include? entity
        s[:border_left] = 'black solid thin' if index > 0

        div style: inline(s) do
          str = String.new entity.name
          str << " (#{entity.owner.name})" unless entity.is_a? Player
          text str
        end
      end
    end

  end
end
