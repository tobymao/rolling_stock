require './models/corporation'

class CorporationV2 < Corporation
  CORPORATIONS = %w(Bear Eagle Horse Jupiter Orion Saturn Ship Star).freeze

  def self.starting_shares name
    case name
    when 'Jupiter', 'Saturn'
      4
    when 'Horse', 'Bear'
      5
    when 'Eagle', 'Orion'
      6
    when 'Ship', 'Star'
      7
    end
  end

  def self.super_power name
    case name
    when 'Jupiter'
      '+$1 income per company'
    when 'Saturn'
      'Double income for best company'
    when 'Horse'
      '+$1 income for ever two synergy markers'
    when 'Bear'
      'Total cost of ownership reduced by up to $10 (min $0)'
    when 'Eagle'
      'Issue share: no price change, get current share price'
    when 'Orion'
      'Buys from foreign investor for face value and with 1st priority'
    when 'Ship'
      'Close company: receive 2x income for closing company'
    when 'Star'
      '★ ★'
    end
  end

  def initial_share_deck
    [Share.president(self)].concat 9.times.map { Share.normal(self) }
  end

  def can_sell_share? player
    @shares_count[player] > 0
  end

  def sell_share player
    super

    if @bank_shares.size == shares_issued
      @president = nil
      @log << "#{@name} goes into receivership"
    end
  end

  def receivership?
    !@president
  end

  def issue_share_price
    @name == 'Eagle' ? @share_price : super
  end

  def close_company company
    super

    if @name == 'Ship'
      bonus = company.income * 2
      @cash += bonus
      @log << "Ship receives $#{bonus} income"
    end
  end

  def set_income old_owner = nil
    super
    @income += @companies.size if @name == 'Jupiter'
    @income += count_synergy_markers / 2 if @name == 'Horse'
    @income += @companies.map(&:income).max if @name == 'Saturn'
  end

  def count_synergy_markers
    count = 0
    synergies = @companies.map(&:name).to_set

    @companies.each do |company|
      company.synergies.each do |synergy|
        count += 1 if synergies.include? synergy
      end
    end

    count / 2
  end

  def stars offset = 0
    total = @companies.map(&:stars).reduce(&:+) + (@cash - offset) / 10
    total += 2 if @name == 'Star'
    total
  end

  def calculate_cost_of_ownership
    @name == 'Bear' ?  [super - 10, 0].max : super
  end

  def starting_shares
    self.class.starting_shares @name
  end

  def buy_company company, price
    if @name == 'Orion' && company.owner.is_a?(ForeignInvestor)
      price = company.value
    end

    super company, price
  end

  private
  def adjust_share_price
    old_index = index

    diff = stars - @share_price.stars(shares_issued)

    if diff >= 2
      swap_share_price next_share_price 2
    elsif diff == 1
      swap_share_price next_share_price
    elsif diff == -1
      swap_share_price prev_share_price
    elsif diff <= -2
      swap_share_price prev_share_price 2
    end
  end
end
