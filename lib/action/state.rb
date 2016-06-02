require "active_support/ordered_hash"
require "active_support/core_ext/hash"
require "active_support/core_ext/string/inflections"

module Action
  class State
    attr_accessor :status

    def initialize options = {}
      options = options.symbolize_keys
      @action_class = options[:action_class]
      @action_class = @action_class.constantize if String === @action_class
      @config = options.fetch(:config, ActiveSupport::OrderedHash.new)
      @status = options.fetch(:status, :initial).to_sym
      @run_time = options.fetch(:run_time, ActiveSupport::OrderedHash.new)
    end

    def create_action
      @action_class.new(run_time_state: @run_time).configure do |config|
        config.replace(@config)
        config.freeze
      end
    end

    def to_json *options
      to_h.to_json(*options)
    end

    def to_h
      {
        action_class: @action_class.name,
        config: @config,
        status: @status,
        run_time: @run_time
      }
    end

    def == other
      self.class == other.class && self.to_h == other.to_h
    end
  end
end
require "action/state/class_methods"
