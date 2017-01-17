require './views/page'

module Views
  class Tutorial < Page
    def render_main
      div class: 'wrapper', style: inline(max_width: '720px') do
        div(class: 'heading') { text 'Introduction' }
        render_intro
        div(class: 'heading') { text 'How To Play' }
        render_how_to_play
        div(class: 'heading') { text "Phase 3 (#{::Game::PHASE_NAME[3]})" }
        render_phase_3
        div(class: 'heading') { text "Phase 2 (#{::Game::PHASE_NAME[2]})" }
        render_phase_2
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
        widget Company, company: company, tier: :red
        br
        text 'A company has a symbol, value, range, and income. You can hover over for more information.'
        text ' The value is the minimum price you must bid for the company in phase 3.'
        text ' The range represents the minimum and maximum amount the company can be'
        text ' sold to corporations for.'
        text ' The income is how much money the company collects each ronud in phase 8.'
        text ' To start an auction, click on the company you wish to purchase and enter the price you want to bid'
        text ' If someone leaves the auction, they cannot come back in.'
        text ' If you do not want to purchase anything, simply press pass.'
        text ' If everyone passes in order or there are no companies available for purchase, the round ends.'
        text ' Buying and selling shares of corporations will be explained later.'
      end
    end

    def render_phase_2
      render_segment do
        text 'In phase 2 you have the option to form a corporation.'
        text ' Corporations are public entities which are made up of subsidary companies.'
        div { widget Corporation, corporation: corporation, tier: :red }
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
