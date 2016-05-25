module Action
  class State
    attr_accessor :status

    def initialize action_class:, config:
      @action_class = action_class
      @config = config.dup
      @status = :initial
    end

    def create_action plan:
      @action_class.new(plan: plan) do |config|
        config.replace(@config)
        config.freeze
      end
    end
  end
end
