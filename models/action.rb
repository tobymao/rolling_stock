require './models/base'

class Action < Base
  def self.issue_share corporation, pass
    { corporation: corporation, pass: pass }
  end

  def self.form_corporation company, pass, price = nil, corporation = nil
    { company: company, pass: pass, price: price, corpation: corporation }
  end

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

  def self.buy_company corporation, company
  end

  def append_action
  end
end
