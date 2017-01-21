require './views/base'

module Views
  class ResetMail < Base
    needs :user
    needs :hash

    def content
      div "Hello #{user.name},"
      br
      div "You've requested a password reset at #{Time.now}"
      br
      div "Here is your temporary password: #{hash}"
      text "Please "
      a 'click here', href: "#{app.request.base_url}/reset?id=#{user.id}"
      text ' to reset your password'

    end

  end
end
