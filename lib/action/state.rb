require "wisper"
require "active_support/ordered_hash"
require "active_support/core_ext/hash"
require "active_support/core_ext/string/inflections"

module Action
  class State
    include Wisper::Publisher
    attr_accessor :status

    def initialize options = {}
      options = options.symbolize_keys
      @action_class = options[:action_class]
      @action_class = @action_class.constantize if String === @action_class
      @config = options.fetch(:config, ActiveSupport::OrderedHash.new)
      @status = options.fetch(:status, :initial).to_sym
    end

    def create_action
      @action_class.new.configure do |config|
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
      }
    end

    def == other
      self.class == other.class && self.to_h == other.to_h
    end

    def status= new_status
      old_status = @status
      @status = new_status
      broadcast :status_changed, self, new_status, old_status
      @status
    end
  end
end
require "action/state/class_methods"
