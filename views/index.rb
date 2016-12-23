require './views/page'

module Views
  class Index < Page
    needs :new_games
    needs :active_games

    def render_main
      div class: 'wrapper' do
        render_new_game if app.current_user
        render_join_games
        render_active_games
      end
    end

    def render_new_game
      hr
      div style: inline(table_style.merge('font-weight': 'bold', 'width': '200px')) do
        text 'New Game'
      end

      form action: '/game', method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Create Game'
      end
    end

    def render_join_games
      hr
      div style: inline(table_style.merge('font-weight': 'bold', 'width': '200px')) do
        text 'Current Games'
      end

      div do
        span style: inline(table_style.merge('font-weight': 'bold')) do
          text "Game Id"
        end

        span style: inline(table_style.merge('font-weight': 'bold')) do
          text 'Name'
        end

        span style: inline(table_style) do
          text ''
        end
      end

      new_games.each do |game|
        div do
          span style: inline(table_style) do
            text game.id.to_s
          end

          span style: inline(table_style) do
            text game.user.name
          end

          span style: inline(table_style) do
            a 'Join Game', href: app.path(game)
          end
        end
      end
    end

    def table_style
      {
        padding: '3px',
        width: '100px',
        display: 'inline-block',
      }
    end

    def render_active_games
      hr
      div style: inline(table_style.merge('font-weight': 'bold', 'width': '200px')) do
        text 'Active Games'
      end

      div do
        span style: inline(table_style.merge('font-weight': 'bold')) do
          text "Game Id"
        end

        span style: inline(table_style.merge('font-weight': 'bold')) do
          text 'Name'
        end

        span style: inline(table_style) do
          text ''
        end
      end

      active_games.each do |game|
        div do
          span style: inline(table_style) do
            text game.id.to_s
          end

          span style: inline(table_style) do
            text game.user.name
          end

          span style: inline(table_style) do
            a 'Join Game', href: app.path(game)
          end
        end
      end

    end
  end
end
