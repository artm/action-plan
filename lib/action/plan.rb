require "action/plan/version"

module Action
  class Plan
    attr_reader :root_action

    def initialize root_action_class, &block
      @schedule = []
      @root_action = root_action_class.new(plan: self, &block)
      @root_action.plan
    end

    def run
      @schedule.each do |action_class, saved_config|
        action = action_class.new(plan: self) do |config|
          config.replace(saved_config)
        end
        action.run
      end
    end

    # let action plan itself
    def plan_action action_class
      action_class.new(plan: self).plan
      self
    end

    # schedule action execution at the current point in the plan
    def schedule_action action_class, config
      @schedule << [action_class, config]
      self
    end
  end
end
