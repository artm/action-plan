module Action
  class State
    def initialize action_class:, config:
      @action_class = action_class
      @config = config.dup
      @status = :initial
    end

    def instance plan:
      @action_class.new(plan: plan) do |config|
        config.replace(@config)
        config.freeze
      end
    end
  end
end
