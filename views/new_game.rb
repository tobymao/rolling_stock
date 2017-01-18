require './views/base'

module Views
  class NewGame < Base

    def content
      form_style = inline(
        margin: '10px 0 10px 0'
      )
      form style: form_style, action: '/game', method: 'post' do
        rawtext app.csrf_tag

        label do
          num_players_props = {
            type: 'number',
            name: 'max_players',
            min: 1,
            max: 6,
            value: 5,
            style: inline(margin_right: '5px'),
          }
          input num_players_props
          text 'Max players'
        end

        br

        label do
          input type: 'checkbox', name: 'open_deck'
          text 'Open Deck'
        end

        br

        label do
          input type: 'checkbox', name: 'default_close', checked: true
          text 'Default auto skip phase 7 (close companies)'
        end

        div do
          input type: 'submit', value: 'Create Game'
        end
      end
    end
  end

end
