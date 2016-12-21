require './views/base'

module Views
  class Nav < Base
    needs :links

    def content
      div do
        render_style

        div style: inline(text_align: 'center') do
          links.each do |link|
            a link[0], href: link[1], class: 'nav_link'
          end
        end
      end
    end

    def render_style
      style <<~CSS
        .nav_link {
          display: inline-block;
          line-height: 2em;
          margin: 0;
          width: 35%;
        }

        @media only screen and (min-width: #{MOBILE_W}) {
          .nav_link { width: 18%; }
        }

        @media only screen and (min-width: #{TABLET_W}) {
          .nav_link { width: 8em; }
        }
      CSS
    end
    static :render_style
  end
end
