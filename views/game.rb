require './views/base'

module Views
  class Game < Base
    needs :game
    needs :current_user

    def content
      @current_player = game.player_by_id current_user&.id unless game.check_point
      game.new_game? ? render_new : render_game
    end

    def render_new
      div class: 'wrapper' do
        div(class: 'heading') { text "Game #{game.id} Waiting for players..." }

        render_players

        if !game.players.include?(@current_player) &&
            game.new_game? &&
            game.users.size < game.max_players
          render_join_button
        end

        if game.user == current_user
          render_start_button
          render_delete_button
        elsif game.users.include? current_user&.id
          render_leave_button
        end
      end
    end

    def render_players
      remove_props = {
        action: app.path(game, 'remove'),
        style: inline(display: 'inline-block', margin_left: '5px'),
        method: 'post',
      }

      div style: inline(margin: '5px') do
        game.players.each do |player|
          div do
            div style: inline(display: 'inline-block') do
              text player.name
            end

            form remove_props do
              rawtext app.csrf_tag
              input type: 'hidden', name: 'player', value: player.id
              input type: 'submit', value: 'Remove'
            end if game.user == current_user && player != @current_player
          end
        end
      end
    end

    def render_game
      flash_title if game.can_act? @current_player

      render_check_point

      div class: 'heading' do
        text "Round: #{game.round} Phase: #{game.phase} (#{game.phase_name})"
      end

      widget Log, game: game, current_player: @current_player
      widget LogChat, game: game, current_player: @current_player

      render_action_widget

      div(class: 'heading') { text 'Players' }

      div class: 'wrapper' do
        widget Players, players: game.players, current_player: @current_player
      end

      div(class: 'heading') { text 'Corporations' }

      div class: 'wrapper' do
        widget Corporations, corporations: game.corporations
      end

      widget ForeignInvestor, investor: game.foreign_investor

      widget Deck, {
        company_class: game.company_class,
        companies: game.companies,
        pending_companies: game.pending_companies,
        company_deck: game.company_deck,
        open_deck: game.settings['open_deck'],
        tier: game.ownership_tier,
      }

      widget SharePrices, share_prices: game.share_prices, company_class: game.company_class

      render_email_settings
    end

    def render_check_point
      div class: 'wrapper' do
        if !(game.round == 1 && game.phase == :investment)
          check_point_link 'Beginning', "#{app.path(game)}?round=1&phase=3"
        end

        if p = game.prev
          check_point_link 'Prev Phase', "#{app.path(game)}?round=#{p[0]}&phase=#{p[1]}"
        end

        if n = game.next
          check_point_link 'Next Phase', "#{app.path(game)}?round=#{n[0]}&phase=#{n[1]}"
        end

        if game.check_point
          check_point_link 'Current', app.path(game)
        end

        check_point_link 'Stats', app.path(game, 'stats')
      end
    end

    def check_point_link str, path
      a str, href: path, style: inline(margin_left: '10px')
    end

    def render_join_button
      form action: app.path(game, 'join'), method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Join As Player'
      end
    end

    def render_start_button
      form style: inline(margin_top: '10px'), action: app.path(game, 'start'), method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Start Playing'
      end
    end

    def render_delete_button
      form action: app.path(game, 'delete'), method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Delete Game'
      end
    end

    def render_leave_button
      form action: app.path(game, 'leave'), method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: 'Leave Game'
      end
    end

    def render_action_widget
      case game.phase_sym
      when :issue
        render_action IssueShares
      when :ipo
        render_action FormCorporations
      when :investment
        render_action AuctionCompanies
      when :acquisition
        render_action BuyCompanies
      when :closing
        render_action CloseCompanies
      when :dividend
        render_action PayDividends
      end
    end

    def render_action klass
      widget klass, game: game, current_player: @current_player
    end

    def render_email_settings
      return unless @current_player
      id = @current_player.id
      btn_text = String.new 'Turn Email Notifications '
      blocked_messages = game.blocked_messages? id

      if blocked_messages
        btn_text = 'Currently blocking only messages'
      else
        btn_text << (game.blocks[id] ? 'On' : 'Off')
      end

      form class: 'wrapper', action: app.path(game, 'block'), method: 'post' do
        rawtext app.csrf_tag
        input type: 'submit', value: btn_text
        br
        label 'Only block messages'
        input type: 'checkbox', name: 'messages', checked: blocked_messages
      end
    end

    def flash_title
      script <<~JS
        var Game = {
          flash: function() {
            var self = this;

            setTimeout(function(){
              document.title = "Your Turn - #{game.phase_name}";

              setTimeout(function(){
                document.title = self.title;
                self.flash();
              }, 2000);
            }, 2000);
          }
        }

        Game.title = document.title;
        Game.flash();
      JS
    end
  end
end
