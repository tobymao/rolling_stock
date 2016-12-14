module Views
  class Base < Fortitude::Widget
    TABLET_W = '1000px'
    MOBILE_W = '600px'
    MAX_W    = '950px'

    needs :app

    doctype :html5

    def self.inline hash
      array = hash.map do |k, v|
        "#{k.to_s.gsub '_', '-'}:#{v}"
      end

      array.join(';').freeze
    end

    def inline hash
      self.class.inline hash
    end

    def game_form hash = {}
      default_style = {
        display: 'inline-block',
      }

      default = {
        action: app.path(game, 'action'),
        method: 'post',
        style: inline(default_style),
      }

      form default.merge(hash) do
        rawtext app.csrf_tag
        input type: 'hidden', name: 'data[round]', value: game.round
        input type: 'hidden', name: 'data[phase]', value: game.phase
        yield
      end
    end

    def data key
      "data[actions][][#{key}]"
    end

    # override
    def widget w, hash = nil, &block
      hash ||= {}
      hash[:app] ||= app

      super w, hash, &block
    end

    def params
      app.request&.params || {}
    end

    def current_path
      app.request&.path || ''
    end
  end
end
