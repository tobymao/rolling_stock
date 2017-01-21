require './views/page'

module Views
  class Index < Page
    needs :games
    needs :messages
    needs :limit

    def render_main
      @current_user             = app.current_user
      new_games                 = games.select &:new_game?
      finished_games            = games.select &:finished?
      active                    = games.select &:active?
      your_games, active_games  = active.partition { |g| g.users.include? @current_user&.id }

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

        div style: block_style do
          render_games 'Your Games', your_games, 'yours'
        end unless your_games.empty?

        div style: block_style do
          render_games 'New Games', new_games, 'new'
        end unless new_games.empty?

        div style: block_style do
          render_games 'Active Games', active_games, 'active'
        end unless active_games.empty?

        div style: block_style do
          render_games 'Finished Games', finished_games, 'finished'
        end unless finished_games.empty?
      end
    end

    def render_new_game
      div class: 'heading' do
        text 'Create Game'
      end

      widget NewGame
    end

    def render_games heading, games, page_name
      div class: 'heading' do
        text heading
      end

      widget Pager, more: games.size > limit, page_name: page_name

      games.take(limit).each do |game|
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
        elsif game.new_game?
          div "Max Players: #{game.max_players}"
          description = game.settings['description']
          div "Description: #{description}" if description.present?
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
