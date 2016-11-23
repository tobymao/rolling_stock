require './views/page'

module Views
  class Index < Page
    def render_main
      div 'hello'
    end
  end
end
