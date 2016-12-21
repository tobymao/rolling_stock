require './views/base'

module Views
  class Page < Base
    needs page_title: nil

    def content
      html do
        head do
          link rel: 'shortcut icon', type: 'image/png', href: '/images/favicon.ico'
          script src: 'https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js'
          render_head
          render_style
          render_analytics
          meta name: 'viewport', content: 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0'
          meta name: 'apple-mobile-web-app-capable', content: 'yes'
          meta charset: 'UTF-8'
        end

        div style: inline(min_height: '95%') do
          render_nav
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
          font-family: Helvetica;
          font-weight: lighter;
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
          font-size: 1.1em;
          margin: 0 5px;
        }

        .selected {
          background-color: lightblue;
        }
      CSS
    end
    static :render_style

    def render_analytics
      #script <<~JS
      #  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      #    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      #  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      #  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
      #  ga('create', '', 'auto');
      #  ga('send', 'pageview');
      #JS
    end
    static :render_analytics

    def render_nav
      links = [
        ['Home', '/'],
      ]

      if app.current_user
        links.concat [[app.current_user.name, '/'], ['Logout', '/logout']]
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
        rawtext '&copy; Toby Mao 2016.'

        ls = inline(
          margin: '0.5em',
          text_decoration: 'none',
        )

        div do
          a 'About', href: '/about', style: ls
          a 'Contact', href: '/contact', style: ls
        end
      end
    end

  end
end
