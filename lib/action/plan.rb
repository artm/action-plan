require "json"
require "action/plan/version"
require "action/state"

module Action
  class Plan
    def initialize
      @schedule = []
      yield DSL.new(self) if block_given?
    end

    def run
      raise NotRunnable, "#{status} plan can't be run" unless runnable?
      schedule.each do |state|
        next if state.status == :done
        action = state.create_action
        run_action action, state
        break unless state.status == :done
      end
    end

    def action_states
      schedule.dup
    end

    def status
      Action::State.sequence_status(schedule.map(&:status))
    end

    RunnableStatuses = [:planned, :failed, :empty]
    def runnable?
      RunnableStatuses.include?(status)
    end

    def to_json *options
      {
        JSON.create_id => self.class.name,
        schedule: schedule
      }.to_json(*options)
    end

    def self.json_create hash_plan
      schedule = hash_plan["schedule"].map{|h| Action::State.new(h)}
      Action::Plan.new.tap{ |plan|
        plan.instance_variable_set(:@schedule, schedule)
      }
    end

    def == other
      self.class == other.class && schedule == other.action_states
    end

    class DSL
      def initialize plan
        @plan = plan
      end

      def action *args, &block
        @plan.plan_action *args, &block
        self
      end
    end

    class Error < RuntimeError ; end
    class NotRunnable < Error ; end

    # let action plan itself
    def plan_action action_class, &block
      action_class.new.configure(&block).expand_into(plan: self)
    end

    # schedule action execution at the current point in the plan
    def schedule_action action_class, config
      new_state = Action::State.new(action_class: action_class, config: config)
      schedule << new_state
      new_state.status = :planned
    end

    private

    attr_reader :schedule

    def run_action action, state
      state.status = :running
      action.run
      state.status = :done
    rescue
      state.status = :failed
    end
  end
end
