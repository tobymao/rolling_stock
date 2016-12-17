require './views/base'
require './views/company'
require './models/company'

module Views
  class Deck < Base
    needs :companies
    needs :pending_companies
    needs :company_deck
    needs :tier


    def content
      div(class: 'heading') { text 'Available Companies' }
      widget Companies, companies: companies, tier: tier

      div(class: 'heading') { text 'Pending Companies' }
      widget Companies, companies: pending_companies, tier: tier

      deck_text = String.new 'Deck'
      tiers = ::Company::OWNERSHIP_TIERS[tier]

      if tiers
        deck_text << " (Cost of Ownership for #{tiers.join ', '} $#{::Company::OWNERSHIP_COSTS[tier]})"
      else
        deck_text << ' (No Cost Of Ownership)'
      end

      div(class: 'heading') { text deck_text }

      render_deck
    end

    def render_deck
      div style: inline(margin: '10px 0 10px 0') do
        company_deck.each do |company|
          span style: inline(
            background_color: company.color,
            padding: '4px',
            border: '0.1em solid black',
            margin: '4px',
          )
        end
      end
    end

  end
end
