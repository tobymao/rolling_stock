require './views/base'

module Views
  class Company < Base
    needs :company
    needs :all_companies

    def content
      container_style = inline(
        display: 'inline-block',
        border: '1px solid black',
        padding: '0.2em',
      )

      div style: container_style do
        company_style = inline(
          background_color: company.tier,
          margin_bottom: '0.2em',
          padding: '0.1em',
          display: 'inline-block',
          cursor: 'pointer',
        )

        div style: company_style do
          render_title 'Face Value', "[$#{company.value}]", font_weight: 'bold'
          render_title 'Price Span', "($#{company.min_price}-$#{company.max_price})", font_size: '0.7em'
          render_title company.name, company.symbol
          render_title 'Base Income', "+$#{company.income}"
        end

        div style: inline(margin_left: '1em', cursor: 'pointer') do
          groups = company
            .synergies
            .map { |sym| all_companies[sym] }
            .group_by { |c| Corporation.calculate_synergy company.tier, c.tier }

          groups.map do |k, v|
            render_title "$#{k} Synergy Income", "+$#{k}", synergy_style(v.first.tier)

            v.map do |synergy|
              render_title synergy.name, "#{synergy.symbol} [#{synergy.value}]", synergy_style(synergy.tier)
            end
          end
        end
      end
    end

    def render_title title, content, extra_style = {}
      default = {
        margin: '0 0.1em 0 0.1em',
        padding: '0 0.3em 0 0.3em',
      }.merge extra_style

      span title: title, style: inline(default) do
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
