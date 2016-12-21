require './views/action'

module Views
  class AuctionCompanies < Action
    needs :game
    needs :current_player

    def render_action
      widget EntityOrder, game: game, entities: game.players_in_order

      company_props = {
        companies: game.companies,
        tier: game.ownership_tier,
      }

      unless game.current_bid
        company_props[:js_block] = js_block
        company_props[:onclick] = 'CompanyAuction.onClick(this)'
      end

      widget Companies, company_props

      render_controls if game.can_act? current_player
      render_js if game.current_bid
    end

    def render_controls
      widget BidBox, game: game, current_player: current_player

      if (game.corporations.any?(&:can_buy_share?) || !current_player.shares.empty?) && !game.current_bid
        widget BuyShares, game: game, current_player: current_player
      end
    end

    def render_js
      name = game.current_bid.company.name
      script <<~JS
        $('[data-company="#{name}"]').addClass('selected')
        $('#bid_company').attr('value', '#{name}');
        $('#bid_submit').attr('disabled', false);
      JS
    end

    def js_block
      <<~JS
        var CompanyAuction = {
          onClick: function(el) {
            var data = el.dataset;
            $('#bid_price').attr({'min': data.value, 'value': data.value});
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
