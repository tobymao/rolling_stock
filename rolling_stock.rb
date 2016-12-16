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

  MUTEX = Mutex.new
  ROOMS = Hash.new { |h, k| h[k] = [] }

  def sync
    MUTEX.synchronize { yield }
  end

  #Thread.new do
  #  DB.listen 'game', loop: true do |_, _, msg|
  #    puts "** received notification #{msg}"
  #  end
  #end

  route do |r|
    r.root do
      games = Game.eager(:user).where(state: ['new', 'active']).all

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
        room = sync { ROOMS[id] }
        game = Game[id]
        game.load

        r.get do
           r.websocket do |ws|
             ws.on :message do |event|
               puts "received ping"
               #sync{ room.dup }.each do |connection|
               #  puts "** sending data ** "
               #end
             end

             ws.on :close do |event|
               sync do
                 room.delete [ws, current_user]
                 ROOMS[id].delete id if room.empty?
               end
             end

             sync { room << [ws, current_user] }
           end

          widget Views::GamePage, game: game
        end

        r.post do
          r.is 'join' do
            game.users << current_user.id
            game.save
            update_connections room, game
            r.redirect path(game)
          end

          r.halt 403 unless game.users.to_a.include? current_user.id

          r.is 'action' do
            action = Action.find_or_create(
              game_id: id,
              round: game.round,
              phase: game.phase,
            )

            data = r['data']

            r.halt 403 if game.round != data['round'].to_i || game.phase != data['phase'].to_i

            data['actions'].each do |action_data|
              # maybe check round and phase here
              game.process_action_data action_data
              action.append_turn action_data
            end

            update_connections room, game

            r.redirect path(game)
          end

          r.halt 403 unless game.user == current_user

          r.is 'start' do
            game.update state: 'active', users: game.users.shuffle
            game.start_game
            update_connections room, game
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
        user = User.where(email: r['email']).first
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
    @current_user ||=
      begin
        token = request.cookies['auth_token']
        session = Session.find token: token
        session.user if session&.valid?
      end
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

  def update_connections room, game
    games = {}

    sync { room.dup }.each do |connection, user|
      next if user == current_user
      html = games[user || 'none'] ||= widget(Views::Game, game: game, current_user: user)
      connection.send html
    end
  end

  def widget klass, needs = {}
    needs[:app] = self
    klass.new(**needs).to_html
  end
end
