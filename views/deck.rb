require './views/base'
require './views/company'

module Views
  class Deck < Base
    needs :game

    def content
      render_js

      h3 'Available Companies'
      render_companies game.companies
      render_bid_box

      h3 'Pending Companies'
      render_companies game.pending_companies

      h3 'Deck'
      game.company_deck.map do |company|
        span style: inline(
          background_color: company.tier,
          padding: '0.3em',
          border: '0.1em solid black',
          margin: '0.1em',
        )
      end
    end

    def render_js
      script <<~JS
        var Deck = {
          onCompanyClick: function(el) {
            var box = document.getElementById('bid_box');
            var price = box.elements['bid_price'];
            var company = box.elements['bid_company'];
            var data = el.dataset;

            if (company.value != data.company) {
              box.style.display = 'block';
              price.setAttribute('min', data.value);
              price.setAttribute('value', data.value);
              company.value = data.company;
            } else {
              box.style.display = 'none';
              company.value = '';
            }
          }
        };
      JS
    end

    def render_companies companies
      companies.map { |c| widget Company, company: c, game: game }
    end

    def render_bid_box
      s = inline(
        display: 'none',
        margin_top: '1em',
      )

      props = {
        id: 'bid_box',
        action: app.path(game, 'action'),
        method: 'post',
        style: s,
      }

      form props do
        rawtext app.csrf_tag
        span 'Price'
        input id: 'bid_price', type: 'number', name: 'data[price]', placeholder: 'Price'
        span 'Symbol'
        input id: 'bid_company', type: 'text', name: 'data[company]', placeholder: 'Company'
        input type: 'hidden', name: 'data[player]', value: app.current_user.id
        input type: 'hidden', name: 'data[action]', value: 'bid'
        input type: 'submit', value: 'Make Bid'
      end
    end
  end
end
