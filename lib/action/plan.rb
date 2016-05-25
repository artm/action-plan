require "action/plan/version"
require "action/state"

module Action
  class Plan
    def initialize
      @schedule = []
      yield DSL.new(self) if block_given?
    end

    def run
      schedule.each do |state|
        action = state.create_action(plan: self)
        run_action action, state
        break unless state.status == :done
      end
    end

    def run_action action, state
      state.status = :running
      action.run
      state.status = :done
    rescue
      state.status = :failed
    end

    def action_states
      schedule.dup
    end

    def status
      case
      when schedule.empty?
        :empty
      when schedule.all? { |state| state.status == :planned }
        :planned
      when schedule.all? { |state| state.status == :done }
        :done
      else
        :invalid
      end
    end

    # let action plan itself
    def plan_action action_class, &block
      action_class.new(plan: self, &block).plan
      self
    end

    # schedule action execution at the current point in the plan
    def schedule_action action_class, config
      new_state = Action::State.new(action_class: action_class, config: config)
      schedule << new_state
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

    private

    attr_reader :schedule
  end
end
