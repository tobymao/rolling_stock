require './models/base'

class GameException < Exception
end

class Game < Base
  extend Forwardable

  many_to_one :user
  one_to_many :actions

  DEFAULT_MAX_PLAYERS = 5.freeze

  def self.empty_game user, settings
    create(
      user: user,
      users: [user.id],
      settings: settings,
      state: { status: 'new' },
    )
  end

  # if sequel converts the dataset to a result, update doesn't save
  def update_settings hash
    update settings: settings.merge(hash)
    save
  end

  def update_state hash
    update state: state.merge(hash)
    save
  end

  def new_game?
    state['status'] == 'new'
  end

  def active?
    state['status'] == 'active'
  end

  def finished?
    state['status'] == 'finished'
  end

  def v2?
    settings['version'].to_f >= 2.0
  end

  def max_players
    settings['max_players'] || DEFAULT_MAX_PLAYERS
  end

  def load round = nil, phase = nil
    klass = v2? ? EngineV2 : Engine
    @engine = klass.new self, round, phase
    @engine.start_game unless new_game?
  end

  def players preloaded = nil
    @_players ||=
      begin
        ids = users.to_a
        user_models = preloaded.select { |u| ids.include? u.id } if preloaded
        user_models = User.where(id: ids) unless user_models
        user_models
          .map { |user| Player.new(user.id, user.name) }
          .each{ |player| player.order = ids.find_index(player.id) + 1 }
          .sort_by(&:order)
      end
  end

  def player_by_user user
    player_by_id user.id
  end

  def player_by_id id
    id = id.to_i
    players.find { |p| p.id == id }
  end

  def method_missing(method, *args)
    if @engine.respond_to? method
      @engine.send(method, *args)
    else
      super
    end
  end

  def phase_descriptions
    @engine.class::PHASE_DESCRIPTION
  end

  def phase_names
    @engine.class::PHASE_NAME
  end
end
