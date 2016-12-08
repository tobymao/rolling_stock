require './views/base'

module Views
  class Companies < Base
    needs :companies
    needs onclick: nil
    needs js_block: nil

    def content
      div do
        script js_block if js_block

        companies.each do |c|
          widget Company, company: c, onclick: onclick
        end
      end
    end
  end
end
