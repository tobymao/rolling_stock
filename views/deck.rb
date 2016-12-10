require './views/base'
require './views/company'

module Views
  class Deck < Base
    needs :game

    def content
      h3 'Available Companies'
      widget Companies, companies: game.companies

      h3 'Pending Companies'
      widget Companies, companies: game.pending_companies

      h3 'Deck'
      render_deck
    end

    def render_deck
      game.company_deck.each do |company|
        span style: inline(
          background_color: company.tier,
          padding: '0.3em',
          border: '0.1em solid black',
          margin: '0.1em',
        )
      end
    end

  end
end
