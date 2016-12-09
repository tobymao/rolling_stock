require './views/base'

module Views
  class FormCorporations < Base
    needs :current_player
    needs :game

    def content
      game_form do
        select name: data('corporation') do
          game.available_corporations.each do |corporation|
            option(value: corporation) { text corporation }
          end
        end

        select name: data('price') do
          game.stock_market.each do |share_price|
            price = share_price.price
            option(value: price) { text price }
          end
        end

        input id: 'form_company', type: 'text', name: data('company'), placeholder: 'Company'

        widget Companies, {
          companies: current_player.companies,
          onclick: 'FormCorporations.onClick(this)',
          js_block: js_block,
        }

        input type: 'submit', value: 'Form Corporation'
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
