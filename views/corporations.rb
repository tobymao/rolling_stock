require './views/base'

module Views
  class Corporations < Base
    needs :corporations

    def content
      div do
        corporations.sort_by(&:price).reverse.each do |corporation|
          widget Corporation, corporation: corporation
        end
      end
    end

  end
end
