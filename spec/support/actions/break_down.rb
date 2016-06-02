require "action/base"

# an action that only implements #run will be planned as is
class BreakDown < Action::Base
  def run
    raise Break, "Amen Brother!"
  end

  class Break < RuntimeError ; end
end
