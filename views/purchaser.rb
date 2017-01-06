require './views/base'

module Views
  class Purchaser < Base
    needs :tier

    def container_style
      {
        display: 'inline-block',
        width: '350px',
        border: 'solid thin rgba(0,0,0,0.66)',
        margin: '2px',
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
        font_size: '18px',
      }
    end

    def render_header values, label_text = nil, bold = false
      header_style = inline(
        display: 'inline-block',
        text_align: 'right',
        margin: '0 5px',
      )

      value_style = {
        max_width: '130px',
        white_space: 'nowrap',
        overflow: 'hidden',
        text_overflow: 'ellipsis',
      }

      value_style[:font_weight] = 'bold' if bold

      div style: header_style do
        Array(values).each do |v|
          div(style: inline(value_style)) { text v }
        end

        div(style: inline(font_size: '11px')) { text label_text }
      end
    end

    def render_companies entity, show_synergies = false
      widget Companies, companies: entity.companies, tier: tier, show_synergies: show_synergies
    end

  end
end
