require './views/base'

module Views
  class Corporations < Base
    needs :game
    needs header: true

    def content
      div(class: 'heading') { text 'Corporations' } if header

      div do
        game.corporations.each do |corporation|
          widget Corporation, game: game, corporation: corporation
        end
      end
    end

  end
end
