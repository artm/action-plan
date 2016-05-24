require "action/base"

# an action that only implements #run will be planned as is
class JustDoIt < Action::Base
  def run
  end
end
