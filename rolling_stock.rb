PRODUCTION = ENV['RACK_ENV'] == 'production'

require 'roda'
require 'fortitude'
require './models.rb'

FOLDERS = %w[views models]

FOLDERS.each do |folder|
  Dir["./#{folder}/**/*.rb" ].each { |file| require file }
end

unless PRODUCTION
  require 'better_errors'
  require 'ruby-prof'
end

class RollingStock < Roda
  unless PRODUCTION
    opts[:root] = Dir.pwd
    plugin :static, %w[/html /vendor /images]
    use BetterErrors::Middleware
    BetterErrors.application_root = __dir__
  end

  use Rack::Session::Cookie, key: '_App_session', secret: ENV['SECRET']

  plugin :default_headers, {
    'Content-Type' => 'text/html',
    'X-Frame-Options' => 'sameorigin',
    'X-Content-Type-Options' => 'nosniff',
    'X-XSS-Protection' => '1; mode=block',
  }

  plugin :csrf
  plugin :basic_auth
  plugin :cookies
  plugin :status_handler
  plugin :halt
  plugin :path
  plugin :flash
  plugin :websockets, adapter: :thin

  status_handler 403 do
    'You are forbidden from seeing that!'
  end

  status_handler 404 do
    "Uh oh, there doesn't seem to be anything here."
  end

  path Game do |game, *paths|
    "/game/#{game.id}/#{paths.join('/')}"
  end

  MUTEX    = Mutex.new
  ROOMS    = Hash.new { |h, k| h[k] = [] }
  MESSAGES = []
  NOTIFIED = {}

  PAGE_LIMIT = 10

  def sync
    MUTEX.synchronize { yield }
  end

  route do |r|
    r.root do
      games = []

      new_query = Sequel.pg_jsonb_op(:state).contains('status' => 'new')
      active_query = Sequel.pg_jsonb_op(:state).contains('status' => 'active') &
        (Sequel.pg_array_op(:users).length(1) > 2)

      if current_user
        active_query &= Sequel.~(Sequel.pg_array_op(:users).contains([current_user.id]))
        finished_query = Sequel.pg_array_op(:users).contains([current_user.id]) &
          Sequel.pg_jsonb_op(:state).contains('status' => 'finished')
        your_query = Sequel.pg_jsonb_op(:state).contains('status' => 'active') &
          Sequel.pg_array_op(:users).contains([current_user.id])

        games.concat(query_games 'finished', finished_query)
        games.concat(query_games 'yours', your_query)
      end

      games.concat(query_games 'new', new_query)
      games.concat(query_games 'active', active_query)

      users = User.where(id: games.flat_map(&:users).uniq).all
      games.each { |game| game.players users }
      widget Views::Index, games: games, limit: PAGE_LIMIT, messages: sync { MESSAGES.dup }
    end

    r.on 'tutorial' do
      widget Views::Tutorial
    end

    r.on 'chat' do
      room = sync { ROOMS['main'] }

      r.websocket do |ws|
        ws.on :message do |event|
          next unless current_user

          data = JSON.parse event.data

          if data['kind'] == 'message'
            message = data['payload']
            sync do
              MESSAGES << [current_user, message]
              MESSAGES.shift(MESSAGES.size - 20) if MESSAGES.size > 20
            end
            html = widget Views::ChatLine, user: current_user, message: message
            sync { room.dup }.each { |socket| socket.send html }
          end
        end

        ws.on :close do |event|
          sync { room.delete ws }
        end

        sync { room << ws }
      end
    end

    r.on 'game' do
      r.is method: 'post' do
        r.halt 403 unless current_user
        settings = {}
        settings['default_close'] = true if r['default_close']
        settings['open_deck'] = true if r['open_deck']
        settings['description'] = r['description'] if r['description'].present?

        max = r['max_players'].to_i
        settings['max_players'] = max.between?(1, 6) ? max : Game::DEFAULT_MAX_PLAYERS

        game = Game.empty_game current_user, settings
        r.redirect path(game)
      end

      r.on ':id' do |id|
        id = id.to_i
        room = sync { ROOMS[id] }

        r.on 'ws' do
          r.websocket do |ws|
            ws.on :message do |event|
            end

            ws.on :close do |event|
              sync do
                room.delete [ws, current_user]
                ROOMS[id].delete id if room.empty?
              end
            end

            sync { room << [ws, current_user] }
          end
        end

        game = Game[id]
        game.load r['round'], r['phase']

        r.get do
          widget Views::GamePage, game: game
        end

        r.post do
          authenticate r.path unless current_user

          r.is 'join' do
            if game.users.size < game.max_players
               game.users << current_user.id
               game.save
               notify_game game
             end

            r.redirect path(game)
          end

          r.halt 403 unless game.users.to_a.include? current_user.id

          r.is 'action' do
            sync { NOTIFIED.delete [game.id, current_user.id] }

            action = Action.find_or_create(
              game_id: id,
              round: game.round,
              phase: game.phase,
            )

            data = r['data']
            actions = data['actions']

            begin
              if game.round == data['round'].to_i &&
                  game.phase == data['phase'].to_i &&
                  actions.present?
                contains_message = false

                actions.each do |action|
                  action.each do |k, v|
                    raise GameException, "Can't process blank fields" if k.blank? || v.blank?
                    contains_message = true if k == 'message'
                  end
                end

                actions.each { |action_data| game.process_action_data action_data }
                actions.each { |action_data| action.append_turn action_data }

                update_game_state game
                notify_game game, contains_message
              end
            rescue GameException => error
              flash[:error] = error.message
            end

            r.redirect path(game)
          end

          r.is 'leave' do
            r.halt 403 if !game.new_game? || game.user == current_user
            game.users.delete current_user.id
            game.save
            notify_game game
            r.redirect path(game)
          end

          r.halt 403 unless game.user == current_user

          r.is 'start' do
            game.update users: game.users.shuffle
            game.start_game
            update_game_state game, 'status' => 'active'
            notify_game game
            r.redirect path(game)
          end

          r.is 'remove' do
            game.users.delete r['player'].to_i
            game.save
            notify_game game
            r.redirect path(game)
          end

          r.is 'delete' do
            game.destroy
            r.redirect '/'
          end
        end
      end
    end

    r.is 'signup' do
      widget Views::Login, create: true
    end

    r.on 'login' do
      r.get do
        widget Views::Login
      end

      r.post do
        user = User.by_email r['email']

        if user && user.password == r['password']
          login_user user
        else
          flash[:error] = 'Wrong email or password'
          r.redirect '/login'
        end
      end
    end

    r.is 'logout' do
      request.response.set_cookie 'auth_token', nil
      r.redirect '/'
    end

    r.on 'forgot' do
      r.get do
        widget Views::Forgot
      end

      r.post do
        user = User.by_email r['email']
        if user
          flash[:flash] = 'Password reset sent'
          html = widget Views::ResetMail, user: user, hash: user.reset_hashes.first
          send_mail user, 'RollingStock.net Password Reset', html
          r.redirect '/'
        else
          flash[:error] = 'Invalid email address'
          r.redirect '/forgot'
        end
      end
    end

    r.on 'reset' do
      r.get do
        widget Views::Reset, user_id: r['id']
      end

      r.post do
        user = User[r['id']]

        if user.reset_hashes.include? r['hash']
          user.update password: r['password']
          flash[:flash] = 'Password Reset'
          login_user user
        else
          flash[:error] = 'Invalid code'
          r.redirect '/'
        end
      end
    end

    r.on 'user' do
      r.post do
        params = {
          name: r['name'],
          email: r['email'],
          password: r['password'],
        }

        flash[:flash] = "Welcome #{r['name']}"

        login_user User.create(params)
      end
    end

  end

  def return_to
    url = session[:return_to] || '/'
    session[:return_to] = nil
    request.redirect url
  end

  def current_user
    unless defined?(@current_user)
      token = request.cookies['auth_token']
      session = Session.find token: token
      @current_user = session&.valid? ? session.user : nil
    end

    @current_user
  end

  def login_user user
    s = Session.create token: SecureRandom.hex, user: user

    request.response.set_cookie 'auth_token', {
      value: s.token,
      expires: Time.now + Session::EXPIRE_TIME,
      domain: nil,
    }

    return_to
  end

  def authenticate path
    unless current_user
      session[:return_to] = path
      request.redirect '/login'
    end
  end

  def update_game_state game, hash = {}
    state = {
      'round'  => game.round,
      'phase'  => game.phase,
      'acting' => game.acting_players.map(&:id),
    }.merge(hash)

    game.update_state state
  end

  def notify_game o_game, contains_message = false
    Thread.new o_game do |game|
      games = {}
      room = sync { ROOMS[game.id].dup }
      room.each do |connection, user|
        next if user&.id == current_user.id
        html = games[user&.id || 0] ||= widget(Views::Game, game: game, current_user: user)
        connection.send html
      end

      unnotified = game.users - room.map { |_, user| user.id }

      User.where(id: unnotified).all.each do |user|
        key = [game.id, user.id]
        last_notified = sync { NOTIFIED[key] }
        html = widget Views::GameMail, game: game, current_user: user
        if contains_message
          send_mail user, game_subject(game, 'New Message'), html
        elsif game.state['acting'].include?(user.id) && !last_notified
          sync { NOTIFIED[key] = Time.now }
          send_mail user, game_subject(game,'Your Turn'), html
        end
      end
    end
  end

  def widget klass, needs = {}
    needs[:app] = self
    klass.new(**needs).to_html
  end

  def query_games page, query
    p = request[page].to_i
    p = p <= 0 ? 1 : p

    Game
      .eager(:user)
      .reverse_order(:id)
      .limit(PAGE_LIMIT + 1)
      .offset((p - 1) * PAGE_LIMIT)
      .where(query)
      .all
  end

  def send_mail user, subject, html
    return unless PRODUCTION

    uri = URI.parse("https://api.sparkpost.com/api/v1/transmissions")
    req = Net::HTTP::Post.new uri
    req.content_type = 'application/json'
    req['Authorization'] = ENV['SPARK_POST_KEY']
    req.body = JSON.dump(
      'content' => {
        'from' => 'no-reply@rollingstock.net',
        'subject' => subject,
        'html' => html,
      },
      'recipients' => [
        { address: user.email }
      ]
    )

    Net::HTTP.start uri.hostname, uri.port, use_ssl: true do |http|
      http.request req
    end
  end

  def game_subject game, msg
    "Rolling Stock Game #{game.id} - Round #{game.round} - Phase #{game.phase} - #{msg}"
  end

end
