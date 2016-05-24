require "action/plan/version"

module Action
  class Plan
    def initialize root_action
      root_action.plan
    end
  end
end
