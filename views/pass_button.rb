require './views/base'

module Views
  class Passbutton < Base
    needs :game

    def content
      s = inline(
        display: 'none',
        margin_top: '1em',
      )

      form_props = {
        action: app.path(game, 'action'),
        method: 'post',
        style: s,
      }

      form form_props do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Pass'
      end
    end
  end
end
