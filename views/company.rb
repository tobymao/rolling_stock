require './views/base'
require './models/corporation'

module Views
  class Company < Base
    needs :company
    needs onclick: false

    def content
      container_style = {
        display: 'inline-block',
        border: '1px solid black',
        padding: '0.2em',
        margin: '0.2em',
        max_width: '20em',
        vertical_align: 'top',
      }

      container_style[:cursor] = 'pointer' if onclick

      props = {
        style: inline(container_style),
        data: {
          company: company.name,
          value: company.value,
        },
      }

      props[:onclick] = onclick if onclick

      div props do
        company_style = inline(
          background_color: company.tier,
          margin_bottom: '0.2em',
          padding: '0.1em',
          display: 'inline-block',
        )

        div style: company_style do
          render_title 'Face Value', "[$#{company.value}]", font_weight: 'bold'
          render_title 'Price Span', "($#{company.min_price}-$#{company.max_price})", font_size: '0.7em'
          render_title company.full_name, company.name
          render_title 'Base Income', "+$#{company.income}"
        end

        div style: inline(margin_left: '1em') do
          groups = company
            .synergies
            .map { |sym| ::Company.all[sym] }
            .group_by { |c| ::Corporation.calculate_synergy company.tier, c.tier }

          groups.each do |k, v|
            div do
              render_title "$#{k} Synergy Income", "+$#{k}", synergy_style(v.first.tier)

              v.each do |synergy|
                render_title synergy.name, "#{synergy.name} [#{synergy.value}]", synergy_style(synergy.tier)
              end
            end
          end
        end
      end
    end

    def render_title title, content, extra_style = {}
      default = {
        margin: '0 0.1em 0 0.1em',
        padding: '0 0.3em 0 0.3em',
        display: 'inline-block',
      }.merge extra_style

      div title: title, style: inline(default) do
        text content
      end
    end

    def synergy_style tier
      syn_style = {
        background_color: tier,
        font_size: '0.7em',
      }
    end
  end
end
