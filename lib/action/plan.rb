require "action/plan/version"

module Action
  class Plan
    def initialize &block
      @schedule = []
      yield DSL.new(self)
    end

    def run
      @schedule.each do |action_class, saved_config|
        action = action_class.new(plan: self) do |config|
          config.replace(saved_config)
          config.freeze
        end
        action.run
      end
    end

    # let action plan itself
    def plan_action action_class, &block
      action_class.new(plan: self, &block).plan
      self
    end

    # schedule action execution at the current point in the plan
    def schedule_action action_class, config
      @schedule << [action_class, config.dup]
      self
    end

    class DSL
      def initialize plan
        @plan = plan
      end

      def action *args, &block
        @plan.plan_action *args, &block
      end
    end
  end
end
