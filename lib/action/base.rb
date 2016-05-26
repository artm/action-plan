require "active_support/configurable"

module Action
  class Base
    include ActiveSupport::Configurable

    def initialize plan:, &block
      @plan = plan
      yield config if block_given?
    end

    def plan
      plan_myself if respond_to?(:run)
    end

    def plan_myself
      @plan.schedule_action(self.class, config)
    end

    def plan_action action_class, &block
      @plan.plan_action(action_class, &block)
    end
  end
end
