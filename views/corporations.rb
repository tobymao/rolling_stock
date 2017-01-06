require './views/base'

module Views
  class Corporations < Base
    needs :corporations
    needs :tier

    def content
      div do
        corporations.each do |corporation|
          widget Corporation, corporation: corporation, tier: tier
        end
      end
    end

  end
end
