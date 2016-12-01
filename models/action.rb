require './models/base'

class Action < Base
  def self.issue_share player, corporation, pass
    { player: player, corporation: corporation, pass: pass }
  end

  def self.form_corporation player, company, pass, price = nil, corporation = nil
    { player: player, company: company, pass: pass, price: price, corp: corp }
  end

  def append_action
  end
end
