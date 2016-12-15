require './views/base'
require './views/company'

module Views
  class Deck < Base
    needs :companies
    needs :pending_companies
    needs :company_deck
    needs :tier


    def content
      h3 'Available Companies'
      widget Companies, companies: companies, tier: tier

      h3 'Pending Companies'
      widget Companies, companies: pending_companies, tier: tier

      h3 'Deck'
      render_deck
    end

    def render_deck
      company_deck.each do |company|
        span style: inline(
          background_color: company.color,
          padding: '0.3em',
          border: '0.1em solid black',
          margin: '0.1em',
        )
      end
    end

  end
end
