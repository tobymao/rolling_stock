require './views/page'

module Views
  class Game < Page
    needs :game

    def render_main
      render_new if game.new_game?
      render_game
    end

    def render_new
      div do
        game.players.map do |player|
          div player.name
        end

        render_join_button if !game.players.include?(app.current_user.id) && game.new_game?
        render_start_button if game.user == app.current_user
      end
    end

    def render_game
      h3 "Round: #{game.round} Phase: #{game.phase} (#{game.phase_name})"
      entity = game.active_entity
      name = entity.respond_to?(:symbol) ? entity.symbol : entity.name

      render_current_action

      game.players.map do |player|
        widget PlayerHoldings, player: player
      end

      widget Deck, game: game
    end

    def render_current_action
    end

    def render_join_button
      form action: app.path(game, 'join'), method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Join As Player'
      end
    end

    def render_start_button
      form action: app.path(game, 'start'), method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Start Game'
      end
    end
  end
end
