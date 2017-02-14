require './views/base'

module Views
  class BuyShares < Base
    needs :game
    needs :current_player

    def content
      game_form do
        label(style: inline(margin_right: '5px')) { text 'Buy or Sell Shares:' }

        select name: data('corporation') do
          option ''

          game.corporations.each do |corporation|
            next if !corporation.can_buy_share? &&
              current_player.shares.none? { |s| s.corporation == corporation }
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
