require './views/base'
require './views/company'
require './models/company'

module Views
  class Deck < Base
    needs :companies
    needs :pending_companies
    needs :company_deck
    needs :open_deck
    needs :tier


    def content
      div(class: 'heading') { text 'Available Companies' }
      div class: 'wrapper' do
        widget Companies, companies: companies, tier: tier
      end

      div(class: 'heading') { text 'Pending Companies' }
      div class: 'wrapper' do
        widget Companies, companies: pending_companies, tier: tier
      end

      deck_text = String.new 'Deck'
      tiers = ::Company::OWNERSHIP_TIERS[tier]

      if tiers
        deck_text << " (Cost of Ownership for #{tiers.join ', '} $#{::Company::OWNERSHIP_COSTS[tier]})"
      else
        deck_text << ' (No Cost Of Ownership)'
      end

      div(class: 'heading') { text deck_text }

      div class: 'wrapper' do
        open_deck ? render_open_deck : render_deck
      end
    end

    def render_deck
      div do
        company_deck.each do |company|
          div style: inline(
            display: 'inline-block',
            background_color: company.color,
            padding: '4px',
            border: '1px solid black',
            height: '20px',
            margin: '4px',
          )
        end
      end
    end

    def render_open_deck
      widget Companies, {
        companies: company_deck,
        tier: tier,
        sorted: false,
      }
    end

  end
end
