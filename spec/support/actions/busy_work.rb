require "action/base"

# an action that only implements #run will be planned as is
class BusyWork < Action::Base
  def run
    broadcast(:progress, 1, 3)
    broadcast(:progress, 2, 3)
    broadcast(:progress, 3, 3)
  end
end
