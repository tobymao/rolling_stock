require './models/base'

class Action < Base
  def append_turn data
    update turns: (turns + [data])
  end
end
