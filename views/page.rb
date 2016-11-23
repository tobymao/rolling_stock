require './views/base'

module Views
  class Page < Base
    needs page_title: nil

    DEFAULT_LINKS = [
      ['Home', '/'],
      ['Games', '/games'],
      ['About Us', '/about'],
      ['Contact', '/contact'],
    ].freeze

    def content
      html do
        head do
          link rel: 'stylesheet', type: 'text/css', href: 'https://fonts.googleapis.com/css?family=Open+Sans:400,400italic,700'
          link rel: 'shortcut icon', type: 'image/png', href: '/images/favicon.ico'
          render_head
          render_style
          render_analytics
          meta name: 'viewport', content: 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0'
          meta name: 'apple-mobile-web-app-capable', content: 'yes'
          meta charset: 'UTF-8'
        end

        div style: inline(min_height: '95%') do
          render_nav

          div class: 'bgb_container main' do
            render_main
          end
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
        font-family: 'Open Sans';
        width: 100%;
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
      widget Nav, links: DEFAULT_LINKS
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
