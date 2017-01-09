require './views/base'
require './views/purchaser'
require './models/corporation'

module Views
  class Company < Purchaser
    needs :company
    needs :tier
    needs show_synergies: false
    needs onclick: false

    def content
      props = {
        data: {
          company: company.name,
          value: company.value,
          min: company.owner.is_a?(::ForeignInvestor) ? company.max_price : company.min_price,
          max: company.max_price,
        }
      }

      company_style = container_style.merge(
        width: '300px',
        font_size: '0.8em',
      )

      if onclick
        props[:style] = inline(company_style.merge cursor: 'pointer')
        props[:onclick] = onclick if onclick
      else
        props[:style] = inline(company_style)
      end

      div props do
        render_headers company
        render_synergies
      end
    end

    def render_headers company
      header_style = inline(headers_style.merge(background_color: company.color))

      synergies = company.owner.companies.map { |c| [c.name, c] }.to_h
      income = company.income
      coo = company.cost_of_ownership tier
      synergy_income = company.synergy_income synergies
      true_income = income - coo + synergy_income
      income_title = "$#{income} (Base) + $#{synergy_income} (Synergies) - $#{coo} (Cost of ownership)"

      div style: header_style do
        render_header company.name, 'Company', company.full_name
        render_header "$#{company.value}", 'Value'
        render_header "($#{company.min_price}-$#{company.max_price})", 'Range'
        render_header "$#{true_income}", 'Income', income_title
      end
    end

    def render_synergies
      groups = company
        .synergies
        .map { |sym| ::Company.all[sym] }
        .group_by { |c| company.synergy_by_tier c.tier }

      set = show_synergies ? company.owner.companies.map(&:name) : []

      groups.each do |k, v|
        div style: inline(display: 'flex', text_align: 'left') do
          income_style = inline(
            margin: '2px 2px',
            display: 'inline-block',
            font_weight: 'bold',
          )

          div style: income_style do
            text "+$#{k}"
          end

          div style: inline(display: 'inline-block') do
            v.each do |synergy|
              syn_style = inline(
                background_color: synergy.color,
                padding: '1px 5px',
                font_size: '0.8em',
                display: 'inline-block',
                margin: '2px 2px',
                border_radius: '3px',
                border: set.include?(synergy.name) ? 'solid 2px rgba(0,0,0,1.0)' : 'solid 1px rgba(0,0,0,0.2)',
              )

              div style: syn_style do
                text "#{synergy.name} [#{synergy.value}]"
              end
            end
          end
        end
      end
    end

  end
end
