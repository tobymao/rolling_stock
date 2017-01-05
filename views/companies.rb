require './views/base'

module Views
  class Companies < Base
    needs :companies
    needs :tier
    needs show_synergies: false
    needs onclick: nil
    needs js_block: nil

    def content
      div do
        script js_block if js_block

        companies.sort_by(&:value).reverse.each do |c|
          widget Company, {
            company: c,
            tier: tier,
            onclick: onclick,
            show_synergies: show_synergies,
          }
        end
      end
    end

  end
end
