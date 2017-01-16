require './views/page'

module Views
  class Index < Page
    needs :new_games
    needs :active_games
    needs :messages

    def render_main
      @current_user = app.current_user

      div class: 'wrapper' do
        div style: inline(font_size: '20px') do
          div "I'm going to reset the database after I finish game 2"
          div "All games will be lost after that... sorry!"
          br
        end

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

      if game.can_act? game.player_by_user(@current_user)
        game_style[:background_color] = 'lightsalmon'
      end if game.active? && @current_user

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
          div "Round: #{game.state['round']} Phase: #{game.state['phase']}"
          div "Acting: #{game.state['acting'].join(', ')}"
        end
      end
    end

  end
end
