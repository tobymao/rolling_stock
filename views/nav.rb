require './views/base'

module Views
  class Nav < Base
    needs :links

    def content
      div do
        render_style

        div class: 'wrapper', style: inline(text_align: 'left') do
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
          margin: 0 10px;
        }
      CSS
    end
    static :render_style
  end
end
