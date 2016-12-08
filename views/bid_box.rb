require './views/base'

module Views
  class BidBox < Base
    needs :current_player
    needs :game

    def content
      props = {
        id: 'bid_box',
        style: inline(margin_top: '1em'),
      }

      bid = game.current_bid

      game_form props do
        span 'Price'
        price_props = {
          id: 'bid_price',
          type: 'number',
          name: data('price'),
          placeholder: 'Price',
        }
        price_props[:value] = bid.price + 1 if bid
        input price_props

        span 'Symbol'
        company_props = {
          id: 'bid_company',
          type: 'text',
          name: data('company'),
          placeholder: 'Company',
        }
        company_props[:value] = bid.company.symbol if bid
        input company_props

        input type: 'hidden', name: data('player'), value: current_player.id
        input type: 'hidden', name: data('action'), value: 'bid'
        input type: 'submit', value: 'Make Bid'
      end
    end
  end
end
