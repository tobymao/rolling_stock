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
        price_props = {
          id: 'bid_price',
          type: 'number',
          name: data('price'),
          min: 1,
          style: inline(width: '50px', margin: '0 5px'),
          placeholder: 'Price',
        }
        price_props[:value] = bid.price + 1 if bid
        label 'Price:'
        input price_props
        input type: 'hidden', id: 'bid_company', name: data('company')
        input type: 'hidden', name: data('player'), value: current_player.id
        input type: 'hidden', name: data('action'), value: 'bid'
        label(title: 'Automatically increments bid until max price is reached') { text 'Max Bid' }
        input type: 'checkbox', name: data('max')
        input id: 'bid_submit', type: 'submit', value: 'Make Bid', disabled: true
      end
    end
  end
end
