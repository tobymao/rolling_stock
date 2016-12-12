require './views/base'

module Views
  class BuyShares < Base
    needs :game
    needs :current_player

    def content
      game_form do
        select name: data('corporation') do
          game.corporations.each do |corporation|
            next unless corporation.can_buy_share?
            option(value: corporation.name) { text corporation.name }
          end
        end

        input type: 'hidden', name: data('player'), value: current_player.id

        button type: 'submit', name: data('action'), value: 'buy' do
          text 'Buy'
        end

        button type: 'submit', name: data('action'), value: 'sell' do
          text 'Sell'
        end
      end
    end
  end
end
