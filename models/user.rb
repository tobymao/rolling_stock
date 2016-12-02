require './models/base'
require 'bcrypt'

class User < Base
  one_to_many :games
  one_to_many :session

  def validate
    super
    validates_presence [:name, :email, :password]
    validates_unique :name, :email
  end

  def password
    BCrypt::Password.new super
  end

  def password= new_password
    return if new_password.empty?
    super BCrypt::Password.create new_password
  end
end
