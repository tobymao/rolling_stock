require './views/base'

module Views
  class Log < Base
    needs :log

    def content
      log_style = inline(
        overflow_y: 'scroll',
        height: '200px',
        background_color: 'lightgray',
      )

      div style: log_style do
        log.reverse.each { |line| div line }
      end

    end

  end
end
