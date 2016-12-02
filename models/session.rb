require './models/base'

class Session < Base
  many_to_one :user

  EXPIRE_TIME = 30.days

  def validate
    super
    validates_presence [:token, :user_id]
  end

  def valid?
    created_at > EXPIRE_TIME.ago
  end
end
