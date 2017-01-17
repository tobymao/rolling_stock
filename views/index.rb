require './views/page'

module Views
  class Index < Page
    needs :games
    needs :messages

    def render_main
      @current_user = app.current_user
      new_games      = games.select &:new_game?
      active_games   = games.select &:active?
      finished_games = games.select &:finished?

      div class: 'wrapper' do
        widget Chat, current_user: @current_user, messages: messages

        block_style = inline(
          border_top: '1px solid black',
          padding_top: '10px',
          margin_bottom: '10px',
        )

        div style: block_style do
          render_new_game
        end if @current_user

        yours, active = active_games.partition { |g| g.users.include? @current_user&.id }

        div style: block_style do
          render_games 'Your Games', yours
        end unless yours.empty?

        div style: block_style do
          render_games 'New Games', new_games
        end unless new_games.empty?

        div style: block_style do
          render_games 'Finished Games', finished_games
        end unless finished_games.empty?

        div style: block_style do
          render_games 'Active Games', active
        end unless active.empty?
      end
    end

    def render_new_game
      div class: 'heading' do
        text 'Create Game'
      end

      widget NewGame
    end

    def render_games heading, games
      div class: 'heading' do
        text heading
      end

      games.each do |game|
        render_game game
      end
    end

    def render_game game
      game_style = {
        margin: '5px',
        display: 'inline-block',
        padding: '5px',
        border: 'solid thin lightgrey',
        max_width: '320px',
        vertical_align: 'top',
      }

      if game.state['acting'].include? @current_user.id
        game_style[:background_color] = 'lightsalmon'
      end if game.active? && @current_user

      div style: inline(game_style) do
        join_text = game.active? ? 'Enter Game' : 'Join Game'
        a "#{join_text} #{game.id}", href: app.path(game)
        div "Owner: #{game.user.name}"
        div "Created At: #{game.created_at} "
        div "Last Move: #{game.updated_at}"
        div "Variants: Open Deck" if game.settings['open_deck']
        overflow_style = inline(
          white_space: 'nowrap',
          overflow: 'hidden',
          text_overflow: 'ellipsis',
        )
        div style: overflow_style do
          text "Players: #{game.players.map(&:name).join(', ')}"
        end

        if game.active?
          div "Round: #{game.state['round']} Phase: #{game.state['phase']}"
          names = game.state['acting'].map { |id| game.player_by_id(id).name }
          div "Acting: #{names.join(', ')}"
        elsif game.finished?
          result = game
            .state['result']
            .to_a
            .sort_by! { |_, v| -v }
            .map! { |id, value| "#{game.player_by_id(id).name} ($#{value})"}

          div style: overflow_style do
            text "Result: #{result.join(', ')}"
          end
        end
      end
    end

  end
end
