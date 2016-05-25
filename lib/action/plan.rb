require "action/plan/version"

module Action
  class Plan
    attr_reader :root_action

    def initialize root_action_class
      @actions = []
      @root_action = root_action_class.new(plan: self)
      @root_action.plan
    end

    def run
      @actions.each do |action_class|
        action = action_class.new(plan: self)
        action.run
      end
    end

    # let action plan itself
    def plan_action action_class
      action_class.new(plan: self).plan
      self
    end

    # schedule action execution at the current point in the plan
    def schedule_action action_class
      @actions << action_class
      self
    end
  end
end
