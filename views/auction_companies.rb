require './views/action'

module Views
  class AuctionCompanies < Action
    needs :game
    needs :current_player

    def render_action
      widget EntityOrder, game: game, entities: game.players_in_order
      widget Bid, bid: game.current_bid, tier: game.ownership_tier if game.current_bid

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

      if (game.corporations.any?(&:can_buy_share?) || !current_player.shares.empty?) &&
          !game.current_bid
        widget BuyShares, game: game, current_player: current_player
      end
    end

    def js_block
      <<~JS
        var CompanyAuction = {
          onClick: function(el) {
            var data = el.dataset;
            $('#bid_price').attr({'min': data.value, 'value': data.value});
            $('#bid_company').attr('value', data.company);
          }
        };
      JS
    end
  end
end
