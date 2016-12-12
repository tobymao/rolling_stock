require './views/base'

module Views
  class IssueShares < Base
    needs :game

    def content
      corporation = game.acting.first

      div do
        game_form do
          span "Issue Share for #{corporation.name}"
          input type: 'hidden', name: data('corporation'), value: corporation.name
          input type: 'submit', value: 'Issue a Share'
        end
      end
    end
  end
end
