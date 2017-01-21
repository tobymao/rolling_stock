require './views/page'

module Views
  class Forgot < Page
    def render_main
      form class: 'wrapper', action: 'forgot', method: 'post' do
        rawtext app.csrf_tag

        div do
          input type: 'text', name: 'email', placeholder: 'Email'
        end

        div do
          input type: 'submit', value: 'Reset Password'
        end

        a 'Login', href: '/login'
        a 'Sign up', href: '/signup', style: inline(margin_left: '5px')
      end
    end
  end
end
