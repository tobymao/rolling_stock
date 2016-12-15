require './views/base'

module Views
  class AuctionCompanies < Action
    needs :game
    needs :current_player

    def render_action
      widget EntityOrder, game: game, entities: game.players

      widget Companies, {
        companies: game.companies,
        js_block: js_block,
        onclick: 'CompanyAuction.onClick(this)',
        tier: game.ownership_tier,
      } unless game.current_bid

      render_controls if game.can_act? current_player
    end

    def render_controls
      widget BidBox, game: game, current_player: current_player

      if game.corporations.any? &:can_buy_share?
        widget BuyShares, game: game, current_player: current_player
      end
    end

    def js_block
      <<~JS
        var CompanyAuction = {
          onClick: function(el) {
            var box = document.getElementById('bid_box');
            var price = box.elements['bid_price'];
            var company = box.elements['bid_company'];
            var data = el.dataset;

            if (company.value != data.company) {
              price.setAttribute('min', data.value);
              price.setAttribute('value', data.value);
              company.value = data.company;
            }
          }
        };
      JS
    end
  end
end
