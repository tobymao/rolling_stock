require './views/base'

module Views
  class FormCorporations < Action
    needs :current_player
    needs :game

    def render_action
      company = game.acting.first
      widget EntityOrder, game: game, entities: game.player_companies
      widget Companies, companies: game.acting, tier: game.ownership_tier

      game_form do
        select name: data('corporation') do
          game.available_corporations.each do |corporation|
            option(value: corporation) { text corporation }
          end
        end

        select name: data('price') do
          game.stock_market.reject(&:corporation).each do |share_price|
            next unless company.valid_share_price? share_price
            price = share_price.price
            option(value: price) { text price }
          end
        end

        input id: 'form_company', type: 'hidden', name: data('company'), value: company.name
        input id: 'form_submit', type: 'submit', value: 'Form Corporation'
      end if game.can_act? current_player
    end

  end
end
