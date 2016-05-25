module Action
  class Base
    def initialize plan:
      @plan = plan
    end

    def plan
      plan_itself if respond_to?(:run)
    end

    def plan_itself
      @plan.plan_action(self.class)
    end

    def plan_action action_class
      action_class.new(plan: @plan).plan
    end
  end
end
