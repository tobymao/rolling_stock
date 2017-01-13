require './views/base'

module Views
  class ChatLine < Base
    needs :user
    needs :message

    def content
      div "#{user.name}: #{message}"
    end

  end
end
