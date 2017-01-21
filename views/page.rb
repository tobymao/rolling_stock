require './views/base'

module Views
  class Page < Base
    needs page_title: nil

    def content
      html do
        head do
          link rel: 'shortcut icon', type: 'image/png', href: '/images/favicon.ico'
          link rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Inconsolata:400,700|Raleway:400,700'
          script src: 'https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js'
          render_head
          render_style
          render_analytics
          render_global_js
          meta name: 'viewport', content: 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0'
          meta name: 'apple-mobile-web-app-capable', content: 'yes'
          meta charset: 'UTF-8'
        end

        div style: inline(min_height: '95%') do
          render_nav
          div(class: 'flash') { text app.flash[:flash] } if app.flash[:flash]
          div(class: 'error') { text app.flash[:error] } if app.flash[:error]
          render_main
        end

        render_footer
      end
    end

    def render_head
      if page_title
        title "#{page_title} | Rolling Stock Online"
      else
        title 'Rolling Stock Online'
        meta name: 'description', content: 'Online implementation of the board game Rolling Stock by Björn Rabenstein'
      end
    end

    def render_style
      style <<~CSS
        body {
          font-family: 'Raleway', sans-serif;
          font-weight: lighter;
          font-size: 14px;
          width: 100%;
          margin: 0;
        }

        .wrapper {
          position: relative;
          margin: 0 10px;
          padding: 5px;
        }

        .heading {
          font-weight: bold;
          font-size: 1.3em;
          margin: 0 5px;
          text-decoration: underline;
        }

        .selected {
          background-color: lightblue;
        }

        .error {
          background-color: lightsalmon;
          text-align: center;
          font-weight: bold;
          font-size: 18px;
          padding: 5px;
        }

        .flash {
          background-color: lightgreen;
          text-align: center;
          font-weight: bold;
          font-size: 18px;
          padding: 5px;
        }
      CSS
    end
    static :render_style

    def render_global_js
      script <<~JS
        var Connection = function(url) {
          this.url = url;
          this.open = false;
          this.handler = null;
          this.start();
        };

        Connection.prototype.start = function() {
          var self = this;
          this.socket = new WebSocket(this.url);
          this.socket.addEventListener('message', function(event){ return self._onMessage(event.data); });
          this.socket.addEventListener('open', function(event){ return self._onOpen(); });
          this.socket.addEventListener('close', function(event){ return self._onClose(); });
          this.socket.addEventListener('error', function(event){ return self._onError(); });
        }

        Connection.prototype._onOpen = function() {
          this.open = true;
          this.ping();
        };

        Connection.prototype._onClose = function() {
          var self = this;
          this.open = false;
          setTimeout(function() { self.start() }, 5000);
          console.log("Websocket closed");
        };

        Connection.prototype._onError = function() {
          console.error("Websocket error");
        };

        Connection.prototype._onMessage = function(msg) {
          this.handler(msg);
        };

        Connection.prototype.ping = function() {
          this.send({"kind": "ping"});
          setTimeout(this.ping.bind(this), 20000);
        };

        Connection.prototype.send = function(obj) {
          if (!this.open) { return; }
          this.socket.send(JSON.stringify(obj));
        };

        var BaseSocketURL = "ws://" + window.location.hostname;

        if (window.location.port > 0) {
          BaseSocketURL += ":" + window.location.port;
        }
      JS
    end
    static :render_global_js

    def render_analytics
      script <<~JS
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

        ga('create', 'UA-90466781-1', 'auto');
        ga('send', 'pageview');
      JS
    end
    static :render_analytics

    def render_nav
      links = [
        ['Home', '/'],
        ['Tutorial', '/tutorial'],
      ]

      if app.current_user
        links << ["Logout", '/logout']
      else
        links.concat [['Login', '/login'], ['Sign Up', '/signup']]
      end

      widget Nav, links: links
    end

    def render_main
      text 'This page intentionally left blank.'
    end

    def render_footer
      footer_style = inline(
        bottom: '0',
        font_size: '80%',
        text_align: 'center',
      )

      div style: footer_style do
        rawtext '&copy; Toby Mao 2017.'

        ls = inline(
          margin: '0.5em',
          text_decoration: 'none',
        )

        div do
          a 'Github', href: 'https://github.com/tobymao/rolling_stock', style: ls
          a 'Issues', href: 'https://github.com/tobymao/rolling_stock/issues', style: ls
        end
      end
    end

  end
end
