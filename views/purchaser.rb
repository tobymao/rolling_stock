require './views/base'

module Views
  class Purchaser < Base
    needs :tier

    def container_style
      {
        display: 'inline-block',
        min_height: '200px',
        width: '350px',
        border: 'solid thin rgba(0,0,0,0.66)',
        margin: '10px 10px',
        vertical_align: 'top',
        text_align: 'center',
        position: 'relative',
      }
    end

    def headers_style
      {
        background_color: 'lightgrey',
        padding: '5px',
        text_align: 'center',
      }
    end

    def render_header values, label_text = nil, bold = false
      header_style = inline(
        display: 'inline-block',
        text_align: 'right',
        margin: '0 10px',
      )

      div style: header_style do
        Array(values).each do |v|
          if bold == true
            div style: inline('font-weight': 'bold') do
              text v
            end
          else
            div { text v }
          end
        end

        div { text label_text }
      end
    end

    def render_companies entity, show_synergies = false
      widget Companies, companies: entity.companies, tier: tier, show_synergies: show_synergies
    end

  end
end
