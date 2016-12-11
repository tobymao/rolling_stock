require './views/page'

module Views
  class GamePage < Page
    needs :game

    def render_main
      render_js

      div id: 'game_container' do
        widget Game, game: game, current_user: app.current_user
      end
    end

    def render_js
      script <<~JS
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

          _onOpen: function() {
            this.open = true;
            console.log("Websocket open");
            this.ping();
          },

          _onClose: function() {
            this.open = false;
            console.log("Websocket closed");
          },

          _onError: function() {
            console.error("Websocket error");
          },

          _onMessage: function(msg) {
            document.getElementById('game_container').innerHTML = msg;
            this._replaceCsrf();
            console.log("Updating");
          },

          _replaceCsrf: function() {
            var array = document.getElementsByName("_csrf");

            for (var i = 0; i < array.length; i++) {
              var el = array[i];
              el.value = "#{app.csrf_token}";
            }
          },

          ping: function() {
            this.send({"kind": "ping"});
            setTimeout(this.ping.bind(this), 20000);
          },

          send: function(obj) {
            if (!this.open) {
                return;
            }
            console.log("Sending to game server:", obj);
            this.socket.send(JSON.stringify(obj));
          },
        }

        GameConnection.start(
          ["ws://", window.location.hostname, ":", window.location.port, "#{app.path(game)}"].join('')
        );
      JS
    end
  end
end
