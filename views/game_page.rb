require './views/page'

module Views
  class GamePage < Page
    needs :game
    needs error: nil

    def render_main
      render_js

      error_style = inline(
        background_color: 'lightsalmon',
        text_align: 'center',
        font_weight: 'bold',
        font_size: '18px',
        padding: '5px',
      )

      div style: error_style do
        text error
      end if error

      update_style = inline(
        background_color: 'lightgreen',
        text_align: 'center',
        font_weight: 'bold',
        font_size: '18px',
        padding: '5px',
        cursor: 'pointer',
        display: 'none',
      )

      div id: 'update', style: update_style, onclick: 'GamePage.update()' do
        text 'Game Updated (click to refresh)'
      end

      div id: 'game_container' do
        widget Game, game: game, current_user: app.current_user
      end
    end

    def render_js
      script <<~JS
        var init = function() {
          GamePage.watch();
          $('form').submit(function() {
            $('input[type=submit]', this).attr('disabled', 'disabled');
          });
        }

        $(document).ready(init);

        var GamePage = {
          html: "",
          changed: false,

          update: function() {
            $('#game_container').html(this.html);
            $("[name='_csrf']").attr('value', "#{app.csrf_token}");
            $('#update').hide();
            this.changed = false;
            this.html = "";
            this.watch();
          },

          watch: function() {
            $('form').change(function() { GamePage.changed = true; });
          },
        }

        var GameConnection = {
          start: function(url) {
            console.log(url);
            var self = this;
            this.socket = new WebSocket(url);
            this.messageHandlers = {};
            this.open = false;
            this.socket.addEventListener('message', function(event){ return self._onMessage(event.data); });
            this.socket.addEventListener('open', function(event){ return self._onOpen(); });
            this.socket.addEventListener('close', function(event){ return self._onClose(); });
            this.socket.addEventListener('error', function(event){ return self._onError(); });
          },

          default: function() {
            this.start([
              "ws://",
              window.location.hostname,
              ":",
              window.location.port,
              "#{app.path(game)}",
              'ws'
            ].join(''));
          },

          _onOpen: function() {
            this.open = true;
            console.log("Websocket open");
            this.ping();
          },

          _onClose: function() {
            var self = this;
            this.open = false;
            setTimeout(function() { self.default() }, 10000);
            console.log("Websocket closed");
          },

          _onError: function() {
            console.error("Websocket error");
          },

          _onMessage: function(msg) {
            GamePage.html = msg;
            GamePage.changed ? $('#update').show() : GamePage.update();
          },

          ping: function() {
            this.send({"kind": "ping"});
            setTimeout(this.ping.bind(this), 20000);
          },

          send: function(obj) {
            if (!this.open) {
                return;
            }
            this.socket.send(JSON.stringify(obj));
          },
        }

        GameConnection.default();
      JS
    end
  end
end
