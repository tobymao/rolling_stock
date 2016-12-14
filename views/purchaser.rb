require './views/base'

module Views
  class Purchaser < Base
    def container_style
      {
        display: 'inline-block',
        min_height: '200px',
        min_width: '300px',
        border: 'solid thin rgba(0,0,0,0.66)',
        margin: '10px 10px',
        vertical_align: 'top',
        position: 'relative',
      }
    end

    def headers_style
      {
        background_color: 'lightgrey',
        text_align: 'center',
      }
    end

    def render_header values, label_text = nil
      header_style = inline(
        display: 'inline-block',
        font_weight: 'lighter',
        text_align: 'right',
        margin: '0 10px',
      )

      div style: header_style do
        Array(values).each do |v|
          div { text v }
        end

        div { text label_text }
      end
    end

    def render_companies entity
      widget Companies, companies: entity.companies
    end

  end
end
