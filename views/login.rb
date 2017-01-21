require './views/page'

module Views
  class Login < Page
    needs create: nil

    def render_main
      path = create ? '/user' : '/login'

      form class: 'wrapper', action: path, method: 'post' do
        rawtext app.csrf_tag

        div do
          input type: 'text', name: 'name', placeholder: 'Name'
        end if create

        div do
          input type: 'text', name: 'email', placeholder: 'Email'
        end

        div do
          input type: 'password', name: 'password', placeholder: 'Password'
        end

        div do
          input type: 'submit', value: create ? 'Create Account' : 'Login'
        end

        if create
          a 'Login', href: '/login'
        else
          a 'Sign up', href: '/signup'
        end

        a 'Forgot Password', href: '/forgot', style: inline(margin_left: '5px')
      end
    end
  end
end
