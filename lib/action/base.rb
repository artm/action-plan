require "active_support/configurable"

module Action
  class Base
    include ActiveSupport::Configurable

    def initialize plan:, &block
      @plan = plan
      yield config if block_given?
    end

    def plan
      plan_itself if respond_to?(:run)
    end

    def plan_itself
      @plan.schedule_action(self.class)
    end

    def plan_action action_class
      @plan.plan_action(action_class)
    end
  end
end
