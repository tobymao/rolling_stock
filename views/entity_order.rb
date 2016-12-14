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
        }

        s[:text_decoration] = 'underline' if game.acting.include? entity

        div style: inline(s) do
          str = String.new
          str << ' | ' if index > 0
          str << entity.name
          str << " (#{entity.owner.name})" unless entity.is_a? Player
          text str
        end
      end
    end

  end
end
