class Company
  COMPANIES = [
    new('BME', 'Bergisch-Märkische Eisenbahn-Gesellschaft', :red, 1, 1, []),
    new('BSE', 'Berlin-Stettiner Eisenbahn-Gesellschaft', :red, 2, 1, []),
    new('KME', 'Köln-Mindener Eisenbahn-Gesellschaft', :red, 5, 2, []),
    new('AKE', 'Altona-Kieler Eisenbahn-Gesellschaft', :red, 6, 2, []),
    new('BPM', 'Berlin-Potsdam-Magdeburger Eisenbahn', :red, 7, 2, []),
    new('MHE', 'Magdeburg-Halberstädter Eisenbahngesellschaft', :red, 8, 2, []),

    new('WT', 'Königlich Württembergische Staats-Eisenbahnen', :orange, 11, 3, []),
    new('BD', 'Großherzoglich Badische Staatseisenbahnen', :orange, 12, 3, []),
    new('BY', 'Königlich Bayerische Staatseisenbahnen', :orange, 13, 3, []),
    new('OL', 'Großherzoglich Oldenburgische Staatseisenbahnen', :orange, 14, 3, []),
    new('HE', 'Großherzoglich Hessische Staatseisenbahnen', :orange, 15, 3, []),
    new('SX', 'Königlich Sächsische Staatseisenbahnen', :orange, 16, 3, []),
    new('MS', 'Großherzoglich Mecklenburgische Friedrich-Franz-Eisenbahn', :orange, 17, 3, []),
    new('PR', 'Preußische Staatseisenbahnen', :orange, 19, 3, []),

    new('DSB', 'Danske Statsbaner', :yellow, 20, 6, []),
    new('NS', 'Nederlandse Spoorwegen', :yellow, 21, 6, []),
    new('B', 'Nationale Maatschappij der Belgische Spoorwegen – Société ' 'Nationale des Chemins de fer Belges', :yellow, 22, 6, []),
    new('PKP', 'Polskie Koleje Państwowe', :yellow, 23, 6, []),
    new('SNCF', 'Société nationale des chemins de fer français', :yellow, 24, 6, []),
    new('KK', 'k.k. Österreichische Staatsbahnen', :yellow, 25, 6, []),
    new('SBB', 'Schweizerische Bundesbahnen – Chemins de fer fédéraux ' 'suisses – Ferrovie federali svizzere', :yellow, 26, 6, []),
    new('DR', 'Deutsche Reichsbahn', :yellow, 29, 6, []),

    new('SJ', 'Statens Järnvägar', :green, 30, 12, []),
    new('SŽD', 'Советские железные дороги (Sovetskie železnye dorogi)', :green, 31, 12, []),
    new('RENFE', 'Red Nacional de los Ferrocarriles Españoles', :green, 32, 12, []),
    new('BR', 'British Rail', :green, 33, 12, []),
    new('FS', 'Ferrovie dello Stato', :green, 37, 10, []),
    new('BSR', 'Baltic Sea Rail', :green, 40, 10, []),
    new('E', 'Eurotunnel', :green, 43, 10, []),

    new('MAD', 'Madrid-Barajas Airport', :blue, 1, []),
    new('HA', 'Haven van Antwerpen', :blue, 1, []),
    new('HH', 'Hamburger Hafen', :blue, 1, []),
    new('HR', 'Haven van Rotterdam', :blue, 1, []),
    new('LHR', 'London Heathrow Airport', :blue, 1, []),
    new('CDG', 'Aéroport Paris-Charles-de-Gaulle', :blue, 1, []),
    new('FRA', 'Flughafen Frankfurt', :blue, 1, []),
    new('FR', 'Ryanair', :blue, 1, []),

    new('OPC', 'Outer Planet Consortium', :purple, 1, []),
    new('RCC', 'Ring Construction Corporation', :purple, 1, []),
    new('MM', 'Mars Mining Associates', :purple, 1, []),
    new('VP', 'Venus Prospectors', :purple, 1, []),
    new('RU', 'Resources Unlimited', :purple, 1, []),
    new('AL', 'Asteroid League', :purple, 1, []),
    new('LE', 'Lunar Enterprises', :purple, 1, []),
    new('TSI', 'Trans-Space Inc.', :purple, 1, []),
  ]

  def initialize symbol, name, tier, value, income, synergies
    @symbol    = symbol
    @name      = name
    @tier      = tier
    @value     = value
    @income    = income
    @synergies = synergies
    @name      = name
    @price     = price
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
