require './views/base'

module Views
  class Corporations < Base
    needs :corporations
    needs :tier
    needs header: true

    def content
      div(class: 'heading') { text 'Corporations' } if header

      div do
        corporations.each do |corporation|
          widget Corporation, corporation: corporation, tier: tier
        end
      end
    end

  end
end
