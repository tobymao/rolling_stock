require './views/base'

module Views
  class BuyCompanies < Base
    needs :current_player
    needs :game

    def content
      offers = game.offers.select { |o| o.company.owner == current_player }

      offers.each do |offer|
        game_form do
          div "#{offer.corporation.name} offers to buy #{offer.company.symbol} for #{offer.price}"
          input type: 'hidden', name: data('corporation'), value: offer.corporation.name
          input type: 'hidden', name: data('company'), value: offer.company.symbol
          input type: 'submit', name: data('action'), value: 'accept'
          input type: 'submit', name: data('action'), value: 'decline'
        end
      end

      game_form do
        select name: data('corporation') do
          current_player.shares.select(&:president?).each do |share|
            name = share.corporation.name
            option(value: name) { text name }
          end
        end

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
      end

      game.corporations.each do |corporation|
        next if corporation.companies.size == 1
        div "#{corporation.name}'s companies"
        widget Companies, {
          companies: corporation.companies,
          onclick: 'FormCorporations.onClick(this)',
          js_block: js_block,
        }
      end

      game.players.each do |player|
        next if player.companies.empty?
        div "#{player.name}'s companies"
        widget Companies, {
          companies: player.companies,
          onclick: 'FormCorporations.onClick(this)',
          js_block: js_block,
        }
      end

      foreign_companies = game.foreign_investor.companies

      unless foreign_companies.empty?
        div "Foreign Investor's companies"
        widget Companies, {
          companies: companies,
          onclick: 'FormCorporations.onClick(this)',
          js_block: js_block,
        }
      end
    end

    def js_block
      <<~JS
        var FormCorporations = {
          onClick: function(el) {
            var company = document.getElementById('form_company');
            var data = el.dataset;

            if (company.value != data.company) {
              company.value = data.company;
            }
          }
        };
      JS
    end
  end
end
