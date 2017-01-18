
require './views/base'

module Views
  class Pager < Base
    needs more: true
    needs :page_name

    def content
      page = (params[page_name] || 1).to_i

      div style: inline(margin: '5px') do
        link_style = inline margin_right: '5px'
        path = current_path + "?#{page_name}="
        a 'Prev', href: path + "#{page - 1}", style: link_style if page > 1
        a 'Next', href: path + "#{page + 1}", style: link_style if more
      end
    end
  end
end
