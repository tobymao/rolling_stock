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
      props = { data: { company: company.name, value: company.value } }
      company_style = container_style.merge(
        width: '300px',
        min_height: '100px',
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

      div style: header_style do
        render_header company.name, 'Company', true
        render_header "$#{company.value}", 'Value'
        render_header "($#{company.min_price}-$#{company.max_price})", 'Range'
        render_header "$#{company.income}", 'Income'
      end
    end

    def render_synergies
      groups = company
        .synergies
        .map { |sym| ::Company.all[sym] }
        .group_by { |c| ::Corporation.calculate_synergy company.tier, c.tier }

      set = show_synergies ? company.owner.companies.map(&:name) : []

      groups.each do |k, v|
        div style: inline(text_align: 'left') do
          income_style = inline(
            margin: '0 5px',
            display: 'inline-block',
            font_weight: 'bold',
          )

          div style: income_style do
            text "+$#{k}"
          end

          v.each do |synergy|
            syn_style = inline(
              background_color: synergy.color,
              padding: '1px 5px',
              font_size: '0.8em',
              display: 'inline-block',
              margin: '4px 2px',
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
