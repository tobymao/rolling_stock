require './models/base'
require 'bcrypt'

class User < Base
  one_to_many :games
  one_to_many :session

  RESET_WINDOW = 60 * 15 # 15 minutes

  def self.by_email email
    self[Sequel.function(:lower, :email) => email.downcase]
  end

  def validate
    super
    validates_presence [:name, :email, :password]
    validates_unique :name, :email
  end

  def reset_hashes
    now = Time.now.to_i / RESET_WINDOW
    (0..1).map { |i| Digest::MD5.hexdigest "#{password}#{now + i}" }
  end

  def password
    BCrypt::Password.new super
  end

  def password= new_password
    raise if new_password.empty?
    super BCrypt::Password.create new_password
  end
end
