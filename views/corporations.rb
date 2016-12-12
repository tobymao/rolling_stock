require './views/base'

module Views
  class Corporations < Base
    needs :corporations

    def content
      div do
        h3 'Corporations'
        render_corporations
      end
    end

    def render_corporations
      corporations.each do |corporation|
        div "#{corporation.name} - $#{corporation.cash}"
        div "Share Price $#{corporation.share_price.price}"
        div "Shares Issued #{corporation.shares_issued}"
        widget Companies, companies: corporation.companies
      end
    end
  end
end
