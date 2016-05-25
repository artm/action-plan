require "action/base"
require "actions/just_do_it"

# plans other actions doesn't do anything itself
class DelegateWork < Action::Base
  def plan
    plan_action JustDoIt
  end
end
