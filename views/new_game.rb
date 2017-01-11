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
          input type: 'checkbox', name: 'open_deck'
          text 'Open Deck (not implemented yet)'
        end

        div do
          input type: 'submit', value: 'Create Game'
        end
      end
    end
  end

end
