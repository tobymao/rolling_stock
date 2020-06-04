require './views/page'

module Views
  class Tutorial < Page
    def render_main
      div class: 'wrapper', style: inline(max_width: '720px') do
        div(class: 'heading') { text 'Introduction' }
        render_intro
        div(class: 'heading') { text 'How To Play' }
        render_how_to_play
        div(class: 'heading') { text "Phase 3 (#{::Engine::PHASE_NAME[:investment]})" }
        render_phase_3
        div(class: 'heading') { text "Phase 4 (#{::Engine::PHASE_NAME[:foreign]})" }
        render_phase_4
        div(class: 'heading') { text "Phase 5 (#{::Engine::PHASE_NAME[:order]})" }
        render_phase_5
        div(class: 'heading') { text "Phase 7 (#{::Engine::PHASE_NAME[:closing]})" }
        render_phase_7
        div(class: 'heading') { text "Phase 8 (#{::Engine::PHASE_NAME[:income]})" }
        render_phase_8
        div(class: 'heading') { text "Phase 2 (#{::Engine::PHASE_NAME[:ipo]})" }
        render_phase_2
        div(class: 'heading') { text "Phase 3 (#{::Engine::PHASE_NAME[:ipo]}) - continued" }
        render_phase_3_2
        div(class: 'heading') { text "Phase 6 (#{::Engine::PHASE_NAME[:acquisition]})" }
        render_phase_6
        div(class: 'heading') { text "Phase 8 (#{::Engine::PHASE_NAME[:income]}) - continued" }
        render_phase_8_2
        div(class: 'heading') { text "Phase 9 (#{::Engine::PHASE_NAME[:dividend]})" }
        render_phase_9
        div(class: 'heading') { text "Phase 10 (#{::Engine::PHASE_NAME[:end]})" }
        render_phase_10
      end
    end

    def render_intro
      render_segment do
        text 'Welcome to '
        a 'Rolling Stock', href: 'https://boardgamegeek.com/boardgame/99630/rolling-stock'
        text ' - a website dedicated to the economic card game designed by '
        a 'Björn Rabenstein.', href: 'http://rabenste.in/rollingstock/'
        text ' This tutorial is a work in progress. Check out the '
        a 'rules here.', href: 'http://rabenste.in/rollingstock/learning_the_game.pdf'
        text ' Rolling Stock is a card game about stock and company trading.'
        text ' Players are investors buying private companies in auctions,'
        text ' which they may later use for an IPO (to turn them into corporations)'
        text ' or sell to already existing corporations'
        text '  (to turn them into subsidiaries of that corporation).'
        text ' The majority share holder of a corporation controls its actions:'
        text ' issuing new shares, paying dividends, and buying more subsidiaries'
        text '  from other corporations, players, or an ominous foreign investor.'
        text ' Rolling Stock is vaguely inspired by the 18xx series of games but is very different.'
      end
    end

    def render_how_to_play
      render_segment do
        text 'To play, first create an account and then join a game.'
        text ' You can play live or receive email notifications and play asynchronously.'
        text ' Each game consists of many rounds. Each round consists of phases.'
        text ' Phases are sequential, but in the early stages of the game, some'
        text ' phases will be skipped because there is nothing to do.'
        text ' The game ends when either a corporation reaches the $100 share value'
        text ' or one round after all the companies have been purchased.'
      end
    end

    def render_phase_3
      render_segment do
        text 'The game always starts in phase 3. Each player starts with $30 ($25 in a 6 player game)'
        text ' and takes turn auctioning off companies and/or buying and selling shares of public corporations.'
        widget Company, company: company
        br
        text 'A company has a symbol, value, range, and income. You can hover over for more information.'
        text ' The value is the minimum price you must bid for the company in phase 3.'
        text ' The range represents the minimum and maximum amount the company can be'
        text ' sold to corporations for.'
        text ' The income is how much money the company collects each round in phase 8.'
        text ' To start an auction, click on the company you wish to purchase and enter the price you want to bid'
        text ' If someone leaves the auction, they cannot come back in.'
        text ' If you do not want to purchase anything, simply press pass.'
        text ' If everyone passes in order or there are no companies available for purchase, the round ends.'
        text ' Buying and selling shares of corporations will be explained later.'
      end
    end

    def render_phase_4
      render_segment do
        text 'Turn order is determined now by remaining cash. If tied, relative turn order is maintained'
      end
    end

    def render_phase_5
      render_segment do
        text 'The foreign investor will purchase the cheapest company if available for face value.'
        text 'This keeps the game moving in case no one buys anything.'
      end
    end

    def render_phase_7
      render_segment do
        text 'As the game progress, the cost of lower tier companies go up'
        text ' When the last yellow company is drawn, red companies cost $1. The last green causes '
        text ' reds and oranges to cost $3 to own. Blue - adds yellow at $6. Purple - green at $10.'
        text ' Last turn of the game red, orange, yellow, green will all cost $16. Although you are'
        text ' never forced to close a company, they become prohibitevly expensive maintain.'
        text " You can close them in this phase by checking the companies you don't want anymore."
      end
    end

    def render_phase_8
      render_segment do
        text 'Companies collect income for their owenrs (players or corporations)'
        text ' Players always collect base income (MHE has $2) minus the cost of ownership'
      end
    end

    def render_phase_2
      render_segment do
        text 'In phase 2 you have the option to form a corporation.'
        text ' Corporations are public entities which are made up of subsidary companies.'
        text ' In face value order, each player will have the chance to choose a company to IPO.'
        text ' You choose any corportion name and a share price. Each tier of company can be formed'
        text ' only at the appropriate share value. This range is shown in the stock market.'
        text ' Only one corporation can be at each share price at a time. If you choose MHE[8] to form'
        text ' at $11, then you need to pay $3 of your own money to make up for the difference. You receive'
        text ' 1 share of the company. The corporation then sells 1 share to the bank for $11. In total, the'
        text ' corporation receive $11 + $3 = $14 with 2 shares issued.'
        div { widget Corporation, corporation: corporation }
      end
    end

    def render_phase_3_2
      render_segment do
        text 'Now you can buy and sell shares of public corporations. Whenevr you buy a share, you always'
        text ' pay the next higher price. If there is another company at that price, you need to go higher.'
        text ' The share price of the company changes to this new price. Whenever you sell a share,'
        text ' you similarly receive the next empty lower price and the share price of the company falls.'
        text ' You can never leave a corporation without a president. If you buy or sell a share of and '
        text ' there is a new majority share holder, that person becomes the president. The president makes'
        text ' all the decisions for the corporation.'
      end
    end

    def render_phase_6
      render_segment do
        text 'Now corporations can purchase companies from other corporations or players.'
        text ' The president offers a price within the range ie ($4 - $10) to purchase any company.'
        text ' If the seller agrees, the company is sold. Corporations must always have at least 1 company.'
        text ' Money and companies cannot be exchanged more than once each round. Cash in parenthesis means '
        text ' It is pending and cannot be used.'
      end
    end

    def render_phase_8_2
      render_segment do
        text 'Corporations have the added bonus of synergies. If a corporation owns companies'
        text ' That have a synergy, they get that bonus. For example if a corporation owned MHE and'
        text ' OL and SX, it would get an extra $2 in income. Thus corporations have a higher'
        text ' earning potentialthan players.'
      end
    end

    def render_phase_9
      render_segment do
        text 'Corporations can now choose to pay dividends. This is done in descending share price order.'
        text ' The maximum dividend is the share price / 3.'
        text ' The corporation must have cash available to pay out all dividends. Bear could choose to dividend '
        text ' $3 per share. Toby would receive $3 and the bank would receive $3, Bear would have $8 left.'
        text ' After dividends are paid the corporation changes share price. The company will move up or down'
        text " depending on where the corporation's value is on the chart. If Bear has a value of $22 with 2 "
        text ' shares issued, it will move from $11 to $12. To calculate this without the chart, the book value'
        text ' of a company is the share price * shares issued. If the value of the company is between that and'
        text ' the book value of the next share price, it will go up, etc'
      end
    end

    def render_phase_10
      render_segment do
        text 'The game ends when a corporation reaches $100 or one more turn after every company is bought'
        text ' The winner is determined by value, which is cash + private company values + corporation share values'
        text ' These rules were typed in 10 minutes, so if you want to help make it better, please do!'
      end
    end

    def company
      company = ::Company.all['MHE'].dup
      company.owner = ::Player.new 1, 'Toby'
      company
    end

    def corporation
      share_prices = ::SharePrice.initial_market
      ::Corporation.new 'Bear', company, share_prices[7], share_prices
    end

    def render_segment
      div style: inline(line_height: '20px', margin: '5px', text_align: 'justify') do
        yield
      end
    end

  end
end
