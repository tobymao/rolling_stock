require './models/base'
require './models/share_price'

class Game < Base
  many_to_one :user

  def initialize
    @loaded = false
    @share_prices = SharePrice.initial_market
    @available_corportations = Corporation::CORPORATIONS.dup
    @corporations = []
    @bank_shares = []
  end

  def load
  end

  def command
  end

  def issue_share user, corporation
    return unless corporation.can_issue_share? user
    corporation.issue_share @share_prices, @bank_shares
  end

  def form_corporation user, company, share_price, name
    return unless @user.companies.include? company
    return unless @available_corportations.include? name
    # check share price is legit
    @available_corportations.remove name
    corportation = Corporation.new name, user, company, share_price
    corportation.issue_initial_shares @bank_shares
    @corporations << corporation
  end

  def buy_share user, company
  end

  def sell_share user, company
  end

  def auction_share user, company
  end
end
