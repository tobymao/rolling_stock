require './views/base'

module Views
  class Shares < Base
    needs :shares

    def content
      div do
        shares.group_by(&:corporation).each do |corporation, shares|
          span "#{corporation.name} #{shares.size}"
          span " -President" if shares.any? &:president?
        end
      end
    end
  end
end
