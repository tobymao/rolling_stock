require './models/engine'
require './models/company_v2'

class EngineV2 < Engine
  PHASE_TO_ID = {
    investment:  1,
    upkeep:      2,
    acquisition: 3,
    closing:     4,
    income:      5,
    dividend:    6,
    end:         7,
    issue:       8,
    ipo:         9,
  }

  PHASE_NAME = {
    investment:  'Auctions And Share Trading',
    upkeep:      'Upkeep',
    acquisition: 'Corporations Buys Companies',
    closing:     'Close Companies',
    income:      'Collect Income',
    dividend:    'Pay Dividends And Adjust Share Prices',
    end:         'Check Game End',
    issue:       'Issue New Shares',
    ipo:         'Form Corporations',
  }.freeze

  VERSION = '2.0'.freeze

  def company_class
    CompanyV2
  end

  def corporation_class
    CorporationV2
  end

  def share_price_class
    SharePriceV2
  end

  def active_entities
    entities = super.reject { |e| e.player.nil? }

    orion = @corporations.find { |c| c.name == 'Orion' } if phase_sym == :acquisition

    if orion && orion.active?
      min_price = @foreign_investor.companies.map(&:value).min
      (entities << orion).uniq if min_price && orion.cash >= min_price
    end

    entities
  end

  private
  def process_buy data
    super
  end

  def check_price corporation, company, price
    valid =
      if corporation.name == 'Orion' && company.owner.is_a?(ForeignInvestor)
        price == company.value
      else
        company.valid_price? price
      end

    raise GameException, 'Not a valid price' unless valid
  end

  def get_suitors corporation, owner, company, price
    return nil if corporation.name == 'Orion' || !owner.is_a?(ForeignInvestor)

    @corporations.select do |c|
      (c.name == 'Orion' && c.cash >= company.value) ||
        (c.price > corporation.price &&
         c.owner != corporation.owner &&
         c.cash >= price)
    end
  end

  def step
    case phase_sym
    when :issue
      if entity = acting_receivership
        process_issue('corporation' => entity.name) if entity.can_issue_share?
      end
    when :acquisition
      corporations = active_receivership
      receivership_buy corporations unless corporations.empty?
    when :closing
      active_receivership.each do |corporation|
        case ownership_tier
        when :blue
          corporation.companies.dup.each { |c| corporation.close_company c if c.tier == :red && c.cost_of_ownership >= 4 }
        when :penultimate, :last_turn
          corporation.companies.dup.each { |c| corporation.close_company c if [:red, :orange].include? c.tier && c.cost_of_ownership >= 7 }
        end

      end
    when :dividends
      if entity = acting_receivership
        pass_entity entity
      end
    end

    super
  end

  def receivership_buy corporations
    companies = @foreign_investor.companies.sort_by(&:value).reverse

    orion = corporations.find { |c| c.name == 'Orion' }

    if orion
      corporations.delete orion
      corporations.unshift orion
    end

    corporations.each do |corporation|
      cash = corporation.cash

      companies.dup.each do |company|
        price = corporation == orion ? company.value : company.max_price

        if cash >= price
          offer = @offers.any? { |o| o.company == company && (corporation.price > o.corporation.price) }
          #accepttheoffer --if offer
          cash -= price
          try_to_buy corporation, @foreign_investor, company, price
          companies.delete company
        end
      end
    end
  end

  def reject_suitors offer, corporation
    corporation.name == 'Horse' ? offer.suitors.clear : super
  end

  def acting_receivership
    entity = active_receivership.first
    entity if entity.is_a?(Corporation) && entity.receivership?
  end

  def active_receivership
    @corporations
      .select { |c| c.active? && c.is_a?(Corporation) && c.receivership? }
      .sort_by(&:price)
      .reverse
  end

end
