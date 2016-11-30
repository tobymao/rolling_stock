require './models/base'
require './models/share_price'

class Game < Base
  many_to_one :user

  def initialize
    @loaded = false
    @share_prices = SharePrice.initial_market
    @available_corportations = Corporation::CORPORATIONS.dup
    @corporations = []
  end

  def load
  end

  def command
  end

  def issue_share user, corporation
    return unless corporation.can_issue_share? user
    corporation.issue_share
  end

  def form_corporation user, company, share_price, name
    return unless user.companies.include? company
    return unless @available_corportations.include? name
    # check share price is legit
    @available_corportations.remove name
    @corporations << Corporation.new(name, user, company, share_price)
  end

  def buy_share user, corporation
    return unless corporation.can_buy_share?
    corporation.buy_share user
  end

  def sell_share user, corporation
    return unless corporation.can_sell_share? user
    corporation.sell_share user
  end

  def auction_company user, company
  end
end
