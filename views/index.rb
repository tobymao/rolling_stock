require './views/page'

module Views
  class Index < Page
    needs :new_games
    needs :active_games

    def render_main
      render_new_game if app.current_user
      render_join_games
      render_active_games
    end

    def render_new_game
      div 'New Game'

      form action: '/game', method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Create Game'
      end
    end

    def render_join_games
      div 'Join Game'

      new_games.map do |game|
        div do
          span game.id
          span game.user.name
          a 'Join Game', href: app.path(game)
        end
      end
    end

    def render_active_games
      div 'Active Games'

      active_games.map do |game|
        div do
          span game.id
          span game.user.name
          a 'Join Game', href: app.path(game)
        end
      end
    end

  end
end
