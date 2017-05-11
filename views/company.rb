require './views/base'
require './views/purchaser'
require './models/corporation'

module Views
  class Company < Purchaser
    needs :company
    needs show_synergies: false
    needs onclick: false
    needs show_owner: false

    def content
      props = {
        class: 'company',
        data: {
          name: company.name,
          value: company.value,
          min: company.min_price,
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
        div { text "Owned by #{company.owner.name}" } if show_owner
      end
    end

    def render_headers company
      header_style = inline(headers_style.merge(background_color: company.color))

      income = company.income
      coo = company.cost_of_ownership
      income_title = "$#{income} (Base) - $#{coo} (Cost of ownership)"

      div style: header_style do
        render_header company.name, 'Company', company.full_name
        render_header "$#{company.value}", 'Value', 'Base value of the company (min price in company auction)'
        render_header "($#{company.min_price}-$#{company.max_price})", 'Range', 'The min and max price you can sell this company for'
        render_header "$#{income - coo}", 'Income', income_title
      end
    end

    def render_synergies
      groups = company
        .synergies
        .map { |sym| company.class.all[sym] }
        .group_by { |c| company.synergy_by_tier c.tier }

      set = show_synergies ? company.owner.companies.map(&:name) : []

      groups.each do |k, v|
        div style: inline(display: 'flex', text_align: 'left') do
          div style: inline(margin: '2px 2px', display: 'inline-block') do
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
