require './views/base'

module Views
  class AuctionCompanies < Base
    needs :game
    needs :current_player

    def content
      widget Companies, {
        companies: game.companies,
        js_block: js_block,
        onclick: 'CompanyAuction.onClick(this)'
      } unless game.current_bid
      widget BidBox, game: game, current_player: current_player

      game_form do
        select name: data('corporation') do
          game.corporations.each do |corporation|
            next if corporation.bank_shares.empty?
            option(value: corporation.name) { text corporation.name }
          end
        end

        button name: 'action', type: 'submit', value: 'buy' do
          text 'Buy'
        end

        button name: 'action', type: 'submit', value: 'sell' do
          text 'Sell'
        end
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
