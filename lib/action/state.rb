module Action
  class State
    attr_accessor :status

    def initialize action_class:, config:
      @action_class = action_class
      @config = config.dup
      @status = :initial
    end

    def create_action
      @action_class.new.configure do |config|
        config.replace(@config)
        config.freeze
      end
    end
  end
end
require "action/state/class_methods"
