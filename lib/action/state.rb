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

    def self.sequence_status sequence
      chunks = sequence.chunk{|status|status}
      statuses = chunks.map(&:first)
      chunks = chunks.map(&:last)
      current = nil
      case chunks.count
      when 0
        return :empty
      when 1
        status = statuses.first
        return status if [:done, :planned].include?(status)
        current = 0
      when 2
        current = if statuses.first == :done
                    1
                  elsif statuses.last == :planned
                    0
                  end
      when 3
        current = 1 if statuses.first == :done && statuses.last == :planned
      end
      if current
        status = statuses[current]
        if [:failed, :running].include?(status) && chunks[current].length == 1
          return status
        end
      end
      :invalid
    end
  end
end
