require './views/base'

module Views
  class BuyCompanies < Action
    needs :current_player
    needs :game

    def render_action
      widget EntityOrder, game: game, entities: game.active_entities
      render_offers
      render_corporations
      render_all_companies
      render_controls if game.can_act? current_player
    end

    def render_corporations
      corporations = game.corporations.select { |c| c.owned_by? current_player }
      widget Corporations, corporations: corporations, tier: game.ownership_tier, header: false
    end

    def render_offers
      offers = game.offers.select { |o| o.company.owner == current_player }

      offers.each do |offer|
        game_form do
          div "#{offer.corporation.name} offers to buy #{offer.company.name} for #{offer.price}"
          input type: 'hidden', name: data('corporation'), value: offer.corporation.name
          input type: 'hidden', name: data('company'), value: offer.company.name
          input type: 'submit', name: data('action'), value: 'accept'
          input type: 'submit', name: data('action'), value: 'decline'
        end
      end
    end

    def render_all_companies
      game.corporations.each do |corporation|
        next if corporation.companies.size == 1
        div "#{corporation.name}'s companies"
        render_companies corporation.companies
      end

      game.players.each do |player|
        next if player.companies.empty?
        div "#{player.name}'s companies"
        render_companies player.companies
      end

      foreign_companies = game.foreign_investor.companies

      unless foreign_companies.empty?
        div "Foreign Investor's companies"
        render_companies foreign_companies
      end
    end

    def render_companies companies
      widget Companies, {
        companies: companies,
        tier: game.ownership_tier,
        onclick: 'BuyCompanies.onClick(this)',
        js_block: js_block,
      }
    end

    def render_controls
      corporations = (current_player&.shares || [])
        .select(&:president?)
        .map(&:corporation)

      game_form do
        select name: data('corporation') do
          corporations.each do |corporation|
            name = corporation.name
            option(value: name) { text name }
          end
        end unless corporations.empty?

        span 'Price'

        price_props = {
          id: 'bid_price',
          type: 'number',
          name: data('price'),
          placeholder: 'Price',
        }

        input price_props

        span 'Symbol'

        company_props = {
          id: 'bid_company',
          type: 'text',
          name: data('company'),
          placeholder: 'Company',
        }

        input company_props
        input type: 'submit', value: 'Make Offer'
      end unless corporations.empty?
    end

    def js_block
      <<~JS
        var BuyCompanies = {
          onClick: function(el) {
            var data = el.dataset;
            $('#bid_price').attr({'min': data.min, 'max': data.max, 'value': data.value});
            $('#bid_company').attr('value', data.company);
          }
        };
      JS
    end
  end
end
