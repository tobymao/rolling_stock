require './views/base'

module Views
  class ForeignInvestor < Base
    needs :foreign_investor

    def content
      div do
        div "Foreign Investor - $#{foreign_investor.cash}"
        widget Companies, companies: foreign_investor.companies
      end
    end
  end
end
