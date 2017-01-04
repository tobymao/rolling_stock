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

        div style: block_style do
          render_table new_games, 'New Games'
        end unless new_games.empty?

        div style: block_style do
          render_table active_games, 'Active Games'
        end unless active_games.empty?
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

    def render_table games, heading
      div class: 'heading' do
        text heading
      end

      table_style = inline(
        padding: '3px',
        width: '320px',
        text_align: 'right',
      )

      table style: table_style do
        tr do
          th 'Game Id'
          th 'Creator'
          th 'Players'
          th 'Join'
        end

        games.each do |game|
          td game.id
          td game.user.name
          td game.users.size
          td { a 'Join Game', href: app.path(game) }
        end
      end
    end

  end
end
