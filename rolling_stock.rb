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

  MUTEX            = Mutex.new
  ROOMS            = Hash.new { |h, k| h[k] = [] }
  NOTIFIED         = {}
  NOTIFY_THRESHOLD = 60 * 60 * 2 # 2 hours

  def sync
    MUTEX.synchronize { yield }
  end

  route do |r|
    r.root do
      games = Game
        .eager([:user, :actions])
        .where(state: ['new', 'active'])
        .order(:id)
        .all

      users = User.where(id: games.flat_map(&:users).uniq).all

      games.each do |game|
        game.players users
      end

      games.select(&:active?).each &:load

      data = {
        new_games: games.select(&:new_game?),
        active_games: games.select(&:active?),
      }

      widget Views::Index, data
    end

    r.on 'game' do
      r.is method: 'post' do
        r.halt 403 unless current_user
        game = Game.empty_game current_user
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
        game.load

        r.get do
          widget Views::GamePage, game: game, error: flash[:game_error]
        end

        r.post do
          authenticate r.path unless current_user

          r.is 'join' do
            game.users << current_user.id
            game.save
            notify_game game
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

            begin
              if game.round == data['round'].to_i && game.phase == data['phase'].to_i
                actions = data['actions']
                raise GameException, "Can't process empty actions" unless actions

                actions.each do |action|
                  action.each do |k, v|
                    raise GameException, "Can't process blank fields" if k.blank? || v.blank?
                  end
                end

                actions.each { |action_data| game.process_action_data action_data }
                actions.each { |action_data| action.append_turn action_data }

                notify_game game
                game.touch
              else
                raise GameException, "Round and phase don't match"
              end
            rescue GameException => error
              flash[:game_error] = error.message
            end

            r.redirect path(game)
          end

          r.halt 403 unless game.user == current_user

          r.is 'start' do
            game.update state: 'active', users: game.users.shuffle
            game.start_game
            notify_game game
            r.redirect path(game)
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
        user = User[Sequel.function(:lower, :email) => r['email'].downcase]
        r.redirect '/login' unless user
        login_user user
      end
    end

    r.is 'logout' do
      request.response.set_cookie 'auth_token', nil
      r.redirect '/'
    end

    r.on 'user' do
      r.post do
        params = {
          name: r['name'],
          email: r['email'],
          password: r['password'],
        }

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

  def notify_game game
    Thread.new do
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

        if game.can_act?(game.player_by_user(user)) &&
            (!last_notified || (Time.now - last_notified) > NOTIFY_THRESHOLD)
          sync { NOTIFIED[key] = Time.now }
          send_mail game, user
        end
      end
    end
  end

  def widget klass, needs = {}
    needs[:app] = self
    klass.new(**needs).to_html
  end

  def send_mail game, user
    return unless PRODUCTION

    uri = URI.parse("https://api.sparkpost.com/api/v1/transmissions")
    req = Net::HTTP::Post.new uri
    req.content_type = 'application/json'
    req['Authorization'] = ENV['SPARK_POST_KEY']
    req.body = JSON.dump(
      'content' => {
        'from' => 'no-reply@rollingstock.net',
        'subject' => "Rolling Stock Game #{game.id} - Round #{game.round} - Phase #{game.phase} - Your Turn",
        'html' => widget(Views::GameMail, game: game, current_user: user),
      },
      'recipients' => [
        { address: user.email }
      ]
    )

    Net::HTTP.start uri.hostname, uri.port, use_ssl: true do |http|
      http.request req
    end
  end

end
