require './models/base'
require './models/share_price'

class Game < Base
  #many_to_one :player
  one_to_many :user

  def initialize
    @loaded = false
    @stock_market = SharePrice.initial_market
    @available_corportations = Corporation::CORPORATIONS.dup
    @corporations = []
  end

  def load
  end

  def command
  end

  def issue_share player, corporation
    return unless corporation.can_issue_share? player
    corporation.issue_share
  end

  def form_corporation player, company, share_price, name
    return unless player.companies.include? company
    return unless @available_corportations.include? name
    # check share price is legit
    @available_corportations.remove name
    @corporations << Corporation.new(name, player, company, share_price)
  end

  def buy_share player, corporation
    return unless corporation.can_buy_share?
    corporation.buy_share player
  end

  def sell_share player, corporation
    return unless corporation.can_sell_share? player
    corporation.sell_share player
  end

  def auction_company player, company
  end
end
