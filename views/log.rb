require './views/base'

module Views
  class Log < Base
    needs :active
    needs :log

    def content
      log_style = inline(
        overflow_y: 'scroll',
        height: '200px',
        background_color: 'lightgray',
      )

      div style: log_style do
        div class: 'wrapper' do
          div style: inline(font_weight: 'bold') do
            text 'Your Turn'
          end if active

          log.reverse.each { |line| div line }
        end
      end
    end

  end
end
