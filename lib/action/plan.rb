require "action/plan/version"
require "action/state"

module Action
  class Plan
    def initialize &block
      @schedule = []
      yield DSL.new(self)
    end

    def run
      @schedule.each do |state|
        action = state.create_action(plan: self)
        run_action action, state
      end
    end

    def run_action action, state
      state.status = :running
      action.run
      state.status = :done
    end

    def action_states
      @schedule.dup
    end

    # let action plan itself
    def plan_action action_class, &block
      action_class.new(plan: self, &block).plan
      self
    end

    # schedule action execution at the current point in the plan
    def schedule_action action_class, config
      new_state = Action::State.new(action_class: action_class, config: config)
      @schedule << new_state
      new_state.status = :planned
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
