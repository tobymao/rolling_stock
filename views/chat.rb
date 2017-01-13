require './views/base'

module Views
  class Chat < Base
    needs :current_user

    def content
      chat_style = inline(
        overflow_y: 'scroll',
        height: '250px',
        background_color: 'lightgray',
        font_family: "'Inconsolata', monospace",
        margin: '5px 0',
      )

      div id: 'chat', style: chat_style do
        div class: 'wrapper' do
          div id: 'messages'
        end
      end

      form id: 'chat_form', class: 'wrapper' do
        input id: 'message', type: 'text', style: inline(width: 'calc(100% - 65px)', margin_right: '5px')
        input type: 'submit', value: 'Send'
      end if current_user

      render_js
    end

    def render_js
      script <<~JS
        var connection = new Connection(BaseSocketURL + '/chat');

        connection.handler = function(msg) {
          $('#messages').append(msg);
          $('#chat').scrollTop($('#chat')[0].scrollHeight);
        };

        $("#chat_form").submit(function(e) {
          e.preventDefault();
          var message = $('#message').val();
          if (message != "") {
            connection.send({ "kind": "message", "payload": message });
          }
          $('#message').val('');
        });


        $('#chat').scrollTop($('#chat')[0].scrollHeight);
      JS
    end

  end
end
