require './models/base'

class Game < Base
  many_to_one :user

  def initialize
    @loaded = false
    @user_corporations = {}
    @corportation_shares = {}
  end

  def load
  end

  def command
  end

  def issue_share user, corporation
    return false unless @user_corporations[user.id].include? corporation
    @corportation_shares[corporation] -= 1
  end

  def form_corporation user, company, corporation
  end

  def buy_share user, company
  end

  def sell_share user, company
  end

  def auction_share user, company
  end
end
