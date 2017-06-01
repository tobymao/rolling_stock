require './models/company'

class CompanyV2 < Company
  TIERS = [:red, :orange, :yellow, :green, :blue].freeze

  OWNERSHIP_TIERS = {
    green: [:red],
    blue: [:red, :orange],
    purple: [:red, :orange, :yellow],
    penultimate: [:red, :orange, :yellow],
    last_turn: [:red, :orange, :yellow, :green],
  }.freeze

  OWNERSHIP_COSTS = {
    green: 2,
    blue: 4,
    penultimate: 7,
    last_turn: 10,
  }.freeze

  COMPANIES = {
    'BME' => ['Bergisch-Märkische Eisenbahn-Gesellschaft', :red, 1, 1, ['KME', 'BD', 'HE', 'PR']],
    'BSE' => ['Berlin-Stettiner Eisenbahn-Gesellschaft', :red, 2, 1, ['BPM', 'SX', 'MS', 'PR']],
    'KME' => ['Köln-Mindener Eisenbahn-Gesellschaft', :red, 5, 2, ['BME', 'MHE', 'HE', 'OL', 'PR']],
    'AKE' => ['Altona-Kieler Eisenbahn-Gesellschaft', :red, 6, 2, ['BPM', 'MHE', 'OL', 'MS', 'PR']],
    'BPM' => ['Berlin-Potsdam-Magdeburger Eisenbahn', :red, 7, 2, ['BSE', 'AKE', 'MHE', 'SX', 'MS', 'PR']],
    'MHE' => ['Magdeburg-Halberstädter Eisenbahngesellschaft', :red, 8, 2, ['KME', 'AKE', 'BPM', 'OL', 'SX', 'MS', 'PR']],

    'WT' => ['Königlich Württembergische Staats-Eisenbahnen', :orange, 11, 3, ['BY', 'BD', 'SBB', 'DR']],
    'BY' => ['Königlich Bayerische Staatseisenbahnen', :orange, 12, 3, ['WT', 'HE', 'SX', 'KK', 'DR']],
    'BD' => ['Großherzoglich Badische Staatseisenbahnen', :orange, 13, 3, ['BME', 'WT', 'HE', 'SBB', 'SNCF', 'DR']],
    'OL' => ['Großherzoglich Oldenburgische Staatseisenbahnen', :orange, 15, 3, ['KME', 'AKE', 'MHE', 'MS', 'PR', 'DSB', 'NS', 'DR']],
    'HE' => ['Großherzoglich Hessische Staatseisenbahnen', :orange, 14, 3, ['BME', 'KME', 'BY', 'BD', 'PR', 'DR']],
    'SX' => ['Königlich Sächsische Staatseisenbahnen', :orange, 16, 3, ['BSE', 'BPM', 'MHE', 'BY', 'MS', 'PR', 'KK', 'PKP', 'DR']],
    'MS' => ['Großherzoglich Mecklenburgische Friedrich-Franz-Eisenbahn', :orange, 17, 3, ['BSE', 'AKE', 'BPM', 'MHE', 'OL', 'SX', 'PR', 'DSB', 'PKP', 'DR']],
    'PR' => ['Preußische Staatseisenbahnen', :orange, 19, 3, ['BME', 'BSE', 'KME', 'AKE', 'BPM', 'MHE', 'HE', 'OL', 'SX', 'MS', 'DSB', 'NS', 'B', 'PKP', 'DR']],

    'DSB' => ['Danske Statsbaner', :yellow, 20, 5, ['OL', 'MS', 'PR', 'DR', 'BSR', 'HH']],
    'KK' => ['k.k. Österreichische Staatsbahnen', :yellow, 21, 5, ['BY', 'SX', 'SBB', 'PKP', 'DR', 'FS', 'FRA']],
    'NS' => ['Nederlandse Spoorwegen', :yellow, 22, 5, ['OL', 'PR', 'B', 'DR', 'E', 'HA', 'HR']],
    'SBB' => ['Schweizerische Bundesbahnen – Chemins de fer fédéraux ' 'suisses – Ferrovie federali svizzere', :yellow, 23, 5, ['WT', 'BD', 'KK', 'SNCF', 'DR', 'FS', 'FRA', 'CDG']],
    'B' => ['Nationale Maatschappij der Belgische Spoorwegen – Société ' 'Nationale des Chemins de fer Belges', :yellow, 24, 5, ['PR', 'NS', 'SNCF', 'DR', 'E', 'HA', 'HR']],
    'PKP' => ['Polskie Koleje Państwowe', :yellow, 25, 5, ['SX', 'MS', 'PR', 'KK', 'DR', 'SZD', 'BSR', 'HH', 'FRA']],
    'SNCF' => ['Société nationale des chemins de fer français', :yellow, 26, 5, ['BD', 'SBB', 'B', 'DR', 'FS', 'RENFE', 'E', 'HA', 'CDG']],
    'DR' => ['Deutsche Reichsbahn', :yellow, 29, 5, ['WT', 'BY', 'BD', 'HE', 'OL', 'SX', 'MS', 'PR', 'DSB', 'KK', 'NS', 'SBB', 'B', 'PKP', 'SNCF', 'BSR', 'HH', 'HR', 'FRA']],

    'SZD' => ['Советские железные дороги (Sovetskie železnye dorogi)', :green, 30, 7, ['PKP']],
    'SJ' => ['Statens Järnvägar', :green, 31, 7, ['BSR']],
    'FS' => ['Ferrovie dello Stato', :green, 32, 7, ['KK', 'SBB', 'SNCF']],
    'RENFE' => ['Red Nacional de los Ferrocarriles Españoles', :green, 33, 7, ['SNCF', 'MAD']],
    'BR' => ['British Rail', :green, 34, 7, ['E', 'LHR']],
    'BSR' => ['Baltic Sea Rail', :green, 36, 7, ['DSB', 'PKP', 'DR', 'SJ', 'HH']],
    'E' => ['Eurotunnel', :green, 43, 7, ['NS', 'B', 'SNCF', 'BR', 'HA', 'HR', 'LHR', 'CDG']],

    'HH' => ['Hamburger Hafen', :blue, 45, 10, ['DSB', 'PKP', 'DR', 'BSR']],
    'HA' => ['Haven van Antwerpen', :blue, 46, 10, ['NS', 'B', 'SNCF', 'E']],
    'HR' => ['Haven van Rotterdam', :blue, 47, 10, ['NS', 'B', 'DR', 'E']],
    'MAD' => ['Madrid-Barajas Airport', :blue, 50, 10, ['RENFE', 'CDG']],
    'FRA' => ['Flughafen Frankfurt', :blue, 56, 10, ['KK', 'SBB', 'PKP', 'DR', 'LHR', 'CDG']],
    'LHR' => ['London Heathrow Airport', :blue, 58, 10, ['BR', 'E', 'FRA', 'CDG']],
    'CDG' => ['Aéroport Paris-Charles-de-Gaulle', :blue, 60, 10, ['SBB', 'SNCF', 'E', 'MAD', 'FRA', 'LHR']],
  }.freeze

  def initialize owner, name, full_name, tier, value, income, synergies, log = nil
    @name      = name
    @full_name = full_name
    @tier      = tier
    @value     = value
    @income    = income
    @synergies = synergies
    @owner     = owner
    @cash      = 0
    @log       = log || []
  end

  def synergy_by_tier other_tier
    return 0 unless other_tier

    case @tier
    when :red
      1
    when :orange
      other_tier == :red ? 1 : 2
    when :yellow
      other_tier == :orange ? 2 : 4
    when :green
      other_tier == :yellow ? 4 : 8
    when :blue
      case other_tier
      when :yellow then 4
      when :green then 8
      when :blue then 16
      end
    end
  end

  def stars
    case @tier
    when :red
      1
    when :orange
      2
    when :yellow
      3
    when :green
      4
    when :blue
      5
    end
  end

  def can_be_sold?
    super && !(owner.is_a?(Corporation) && owner.receivership?)
  end

  def min_price
    owner.is_a?(ForeignInvestor) ? max_price : (@value / 2.0).ceil
  end

  def max_price
    case @name
    when 'BME'
      2
    when 'BSE'
      3
    when 'KME'
      7
    else
      (@value * 4.0 / 3).floor
    end
  end
end
