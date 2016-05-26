require "active_support/configurable"

module Action
  class Base
    include ActiveSupport::Configurable

    def initialize run_time_state: nil
      @run_time_state = run_time_state
    end

    def configure
      yield config if block_given?
      self
    end

    # default implementation
    # plan arg is a planning DSL
    def plan plan
      plan.myself if respond_to?(:run)
    end

    # plan arg is an Action::Plan instance
    def expand_into plan:
      plan PlanningDSL.new(plan: plan, action: self)
    end

    class PlanningDSL
      def initialize plan:, action:
        @plan = plan
        @action = action
      end

      def myself
        @plan.schedule_action(@action.class, @action.config)
      end

      def action action_class, &block
        @plan.plan_action(action_class, &block)
      end
    end

    protected

    def todo= total
      run_time_state[:todo] = total
    end

    def done= count
      run_time_state[:done] = count
    end

    def run_time_state
      @run_time_state or raise NoRuntimeState
    end
  end

  class Error < RuntimeError ; end
  class NoRuntimeState < Error ; end
end
