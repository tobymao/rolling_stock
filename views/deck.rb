require './views/base'
require './views/company'

module Views
  class Deck < Base
    needs :available_companies
    needs :all_companies
    needs :pending_companies
    needs :company_deck
    needs :cost_of_ownership

    def content
      h3 'Available Companies'
      render_companies available_companies

      h3 'Pending Companies'
      render_companies pending_companies

      h3 'Deck'
      company_deck.map do |company|
        span style: inline(
          background_color: company.tier,
          padding: '0.3em',
          border: '0.1em solid black',
          margin: '0.1em',
        )
      end
    end

    def render_companies companies
      companies.map { |c| widget Company, company: c, all_companies: all_companies }
    end
  end
end
