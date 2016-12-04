require './models/base'

class Action < Base
  # phase 1
  def self.issue_share corporation, pass
    { corporation: corporation, pass: pass }
  end

  # phase 2
  def self.form_corporation company, pass, price = nil, corporation = nil
    { company: company, pass: pass, price: price, corpation: corporation }
  end

  # phase 3
  def self.buy_share player, corporation
    { player: player, corpation: corporation, action: 'buy' }
  end

  def self.sell_share player, corporation
    { player: player, corpation: corporation, action: 'sell' }
  end

  def self.auction_company player, company, price
    { player: player, company: company, price: price, action: 'auction' }
  end

  def self.pass player, pass
    { player: player, action: 'pass' }
  end

  # phase 6
  def self.buy_company corporation, pass, company = nil
    { corpation: corporation, pass: pass, company: company }
  end

  # phase 7
  def self.close_company corporation, pass, company = nil
    { corpation: corporation, pass: pass, company: company }
  end

  # phase 9
  def self.pay_dividend corporation, amount
    { corpation: corporation, amount: amount }
  end

  def append_action
  end
end
