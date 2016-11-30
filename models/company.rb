class Company
  COMPANIES = [
    ['BME', 'Bergisch-Märkische Eisenbahn-Gesellschaft', :red, 1, 1, []],
    ['BSE', 'Berlin-Stettiner Eisenbahn-Gesellschaft', :red, 2, 1, []],
    ['KME', 'Köln-Mindener Eisenbahn-Gesellschaft', :red, 5, 2, []],
    ['AKE', 'Altona-Kieler Eisenbahn-Gesellschaft', :red, 6, 2, []],
    ['BPM', 'Berlin-Potsdam-Magdeburger Eisenbahn', :red, 7, 2, []],
    ['MHE', 'Magdeburg-Halberstädter Eisenbahngesellschaft', :red, 8, 2, []],

    ['WT', 'Königlich Württembergische Staats-Eisenbahnen', :orange, 11, 3, []],
    ['BD', 'Großherzoglich Badische Staatseisenbahnen', :orange, 12, 3, []],
    ['BY', 'Königlich Bayerische Staatseisenbahnen', :orange, 13, 3, []],
    ['OL', 'Großherzoglich Oldenburgische Staatseisenbahnen', :orange, 14, 3, []],
    ['HE', 'Großherzoglich Hessische Staatseisenbahnen', :orange, 15, 3, []],
    ['SX', 'Königlich Sächsische Staatseisenbahnen', :orange, 16, 3, []],
    ['MS', 'Großherzoglich Mecklenburgische Friedrich-Franz-Eisenbahn', :orange, 17, 3, []],
    ['PR', 'Preußische Staatseisenbahnen', :orange, 19, 3, []],

    ['DSB', 'Danske Statsbaner', :yellow, 20, 6, []],
    ['NS', 'Nederlandse Spoorwegen', :yellow, 21, 6, []],
    ['B', 'Nationale Maatschappij der Belgische Spoorwegen – Société ' 'Nationale des Chemins de fer Belges', :yellow, 22, 6, []],
    ['PKP', 'Polskie Koleje Państwowe', :yellow, 23, 6, []],
    ['SNCF', 'Société nationale des chemins de fer français', :yellow, 24, 6, []],
    ['KK', 'k.k. Österreichische Staatsbahnen', :yellow, 25, 6, []],
    ['SBB', 'Schweizerische Bundesbahnen – Chemins de fer fédéraux ' 'suisses – Ferrovie federali svizzere', :yellow, 26, 6, []],
    ['DR', 'Deutsche Reichsbahn', :yellow, 29, 6, []],

    ['SJ', 'Statens Järnvägar', :green, 30, 12, []],
    ['SŽD', 'Советские железные дороги (Sovetskie železnye dorogi)', :green, 31, 12, []],
    ['RENFE', 'Red Nacional de los Ferrocarriles Españoles', :green, 32, 12, []],
    ['BR', 'British Rail', :green, 33, 12, []],
    ['FS', 'Ferrovie dello Stato', :green, 37, 10, []],
    ['BSR', 'Baltic Sea Rail', :green, 40, 10, []],
    ['E', 'Eurotunnel', :green, 43, 10, []],

    ['MAD', 'Madrid-Barajas Airport', :blue, 45, 15, []],
    ['HA', 'Haven van Antwerpen', :blue, 47, 15, []],
    ['HH', 'Hamburger Hafen', :blue, 48, 15, []],
    ['HR', 'Haven van Rotterdam', :blue, 49, 15, []],
    ['LHR', 'London Heathrow Airport', :blue, 54, 15, []],
    ['CDG', 'Aéroport Paris-Charles-de-Gaulle', :blue, 56, 15, []],
    ['FRA', 'Flughafen Frankfurt', :blue, 58, 15, []],
    ['FR', 'Ryanair', :blue, 60, 15, []],

    ['OPC', 'Outer Planet Consortium', :purple, 1, []],
    ['RCC', 'Ring Construction Corporation', :purple, 1, []],
    ['MM', 'Mars Mining Associates', :purple, 1, []],
    ['VP', 'Venus Prospectors', :purple, 1, []],
    ['RU', 'Resources Unlimited', :purple, 1, []],
    ['AL', 'Asteroid League', :purple, 1, []],
    ['LE', 'Lunar Enterprises', :purple, 1, []],
    ['TSI', 'Trans-Space Inc.', :purple, 1, []],
  ]

  attr_reader :symbor, :name, :tier, :value, :income, :synergies

  def initialize symbol, name, tier, value, income, synergies
    @symbol    = symbol
    @name      = name
    @tier      = tier
    @value     = value
    @income    = income
    @synergies = synergies
    @name      = name
    @cash      = 0
  end

  def valid_price? price
    price.between?(min_price, max_price)
  end

  def min_price
    @income / 2
  end

  def max_price
    case @tier
    when :red
      @income + @value
    when :orange
      @value * 1.22 + 1
    when :yellow
      @value * 1.20 + 2
    when :green
      @value * 1.19 + 7
    when :blue
      @value * 1.14 + 16
    when :purple
      @value * 1.10 + 30
    end.floor
  end
end
