require './views/page'

module Views
  class Reset < Page
    needs :user_id

    def render_main
      form class: 'wrapper', action: 'reset', method: 'post' do
        rawtext app.csrf_tag

        input type: 'hidden', name: 'id', value: user_id

        div do
          input type: 'password', name: 'hash', placeholder: 'Temporary Password'
        end

        div do
          input type: 'password', name: 'password', placeholder: 'New Password'
        end

        div do
          input type: 'submit', value: 'Reset Password'
        end
      end
    end
  end
end
