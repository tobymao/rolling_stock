require './models/base'
require 'json'

class Action < Base
  def turns
    JSON.parse super
  end

  def turns= data
    super data.to_json
  end

  def append_turn data
    update turns: (turns + [data])
  end
end
