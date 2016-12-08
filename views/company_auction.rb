require './views/base'

module Views
  class CompanyAuction < Base
    needs :game
    needs :current_player

    def content
      widget Companies, {
        companies: game.companies,
        js_block: js_block,
        onclick: 'CompanyAuction.onClick(this)'
      } unless game.current_bid
      widget BidBox, game: game, current_player: current_player
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
