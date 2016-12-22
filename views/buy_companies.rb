require './views/base'

module Views
  class BuyCompanies < Action
    needs :current_player
    needs :game

    def render_action
      widget EntityOrder, game: game
      @corporations = game.corporations.select { |c| c.owned_by? current_player }

      render_offers
      render_corporations
      render_companies
      render_controls if game.can_act? current_player
    end

    def render_corporations
      widget Corporations, corporations: @corporations, tier: game.ownership_tier, header: false
    end

    def render_offers
      offers = game.offers.select do |offer|
        offer.company.owned_by?(current_player) || offer.suitor?(current_player)
      end

      offers.each { |offer| render_offer offer }
    end

    def render_offer offer
      corporation = offer.corporation
      company = offer.company
      div do
        text "#{corporation.name} offers to buy #{company.name} from #{company.owner.name} for #{offer.price}"
      end

      game_form do
        if offer.suitor? current_player
          div 'You can purchase this company from the Foreign Investor instead.'
          div 'Click Accept to make the purchase and Decline to pass on the purchase.'

          select name: data('corporation') do
            @corporations.select { |c| offer.suitor? current_player }.each do |corporation|
              option(value: corporation.name) { text corporation.name }
            end
          end
        else
          input type: 'hidden', name: data('corporation'), value: corporation.name
        end

        input type: 'hidden', name: data('company'), value: company.name
        input type: 'submit', name: data('action'), value: 'accept'
        input type: 'submit', name: data('action'), value: 'decline'
      end
    end

    def render_companies
      companies = (game.held_companies + game.foreign_investor.companies).select &:can_be_sold?

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

        price_props = {
          id: 'bid_price',
          type: 'number',
          name: data('price'),
          min: 1,
          style: inline(width: '50px', margin: '0 5px 0 5px'),
          placeholder: 'Price',
        }
        label(style: inline(margin_left: '5px')) { text 'Price:' }
        input price_props
        input type: 'hidden', id: 'bid_company', name: data('company')
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
            $('#bid_submit').attr('disabled', false);
            $('.selected').removeClass('selected');
            $(el).toggleClass('selected');
          }
        };
      JS
    end
  end
end
