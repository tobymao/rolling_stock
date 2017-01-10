require './views/base'

module Views
  class Companies < Base
    needs :companies
    needs :tier
    needs show_synergies: false
    needs onclick: nil
    needs js_block: nil
    needs show_owner: false

    def content
      div do
        companies.sort_by(&:value).reverse.each do |c|
          widget Company, {
            company: c,
            tier: tier,
            onclick: onclick,
            show_synergies: show_synergies,
            show_owner: show_owner,
          }
        end

        script js_block if js_block
      end
    end

  end
end
