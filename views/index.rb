require './views/page'

module Views
  class Index < Page
    needs :new_games
    needs :active_games

    def render_main
      div class: 'wrapper' do
        block_style = inline(
          border_top: '1px solid black',
          padding_top: '10px',
          margin_bottom: '10px',
        )

        div style: block_style do
          render_new_game
        end if app.current_user

        yours, active = active_games.partition { |g| g.users.include? app.current_user&.id }

        div style: block_style do
          render_games 'Your Games', yours
        end unless yours.empty?

        div style: block_style do
          render_games 'New Games', new_games
        end unless new_games.empty?

        div style: block_style do
          render_games 'Active Games', active
        end unless active.empty?
      end
    end

    def render_new_game
      div class: 'heading' do
        text 'Create Game'
      end

      form action: '/game', method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Create Game'
      end
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

      if game.can_act? game.player_by_user(app.current_user)
        game_style[:background_color] = 'lightsalmon'
      end if game.active? && app.current_user

      div style: inline(game_style) do
        join_text = game.active? ? 'Enter Game' : 'Join Game'
        a "#{join_text} #{game.id}", href: app.path(game)
        div "Owner: #{game.user.name}"
        div "Created At: #{game.created_at} "
        div "Last Move: #{game.updated_at}"
        div style: inline(white_space: 'nowrap', overflow: 'hidden', text_overflow: 'ellipsis') do
          text "Players: #{game.players.map(&:name).join(', ')}"
        end

        if game.active?
          div "Round: #{game.round} Phase: #{game.phase}"
          acting = game.players.select { |p| game.can_act? p }
          div "Acting: #{acting.map(&:name).join(', ')}"
        end
      end
    end

  end
end
