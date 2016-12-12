require './views/base'

module Views
  class Game < Base
    needs :game
    needs :current_user

    def content
      render_new if game.new_game?
      render_game
    end

    def render_new
      div do
        game.players.each do |player|
          div player.name
        end

        render_join_button if !game.players.include?(current_user.id) && game.new_game?
        render_start_button if game.user == current_user
      end
    end

    def render_game
      h3 "Round: #{game.round} Phase: #{game.phase} (#{game.phase_name})"

      widget Bid, bid: game.current_bid if game.current_bid
      current_player = game.player_by_id current_user&.id
      widget Action, game: game, current_player: current_player

      game.players_in_order.each do |player|
        widget PlayerHoldings, player: player, acting: game.can_act?(player)
      end

      widget ForeignInvestor, foreign_investor: game.foreign_investor

      widget Corporations, corporations: game.corporations

      widget Deck, game: game
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
