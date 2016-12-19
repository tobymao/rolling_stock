require './views/base'

module Views
  class IssueShares < Action
    needs :game
    needs :current_player

    def render_action
      widget EntityOrder, game: game, entities: game.corporations.select(&:can_issue_share?)
      corporation = game.acting.first

      widget Corporations,
        game: game,
        corporations: [corporation],
        tier: game.ownership_tier,
        header: false

      game_form do
        span "Issue Share for #{corporation.name}"
        input type: 'hidden', name: data('corporation'), value: corporation.name
        input type: 'submit', value: 'Issue a Share'
      end if game.can_act? current_player
    end
  end
end