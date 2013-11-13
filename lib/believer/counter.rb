module Believer

  class Counter

    def initialize(v = 0, initial_val = nil)
      @value = v
      @initial_value = initial_val.nil? ? @value : initial_val
    end

    def reset!
      @value = 0
      self
    end

    def undo_changes!
      @value = initial_value
      self
    end

    def adopt_value(v)
      if v.nil?
        @value = 0
        return self
      end
      @value = v.to_i
      self
    end

    def incr(val = 1)
      @value = @value + val
      self
    end

    def incremented?
      @value > initial_value
    end

    def decr(val = 1)
      @value = @value - val
      self
    end

    def decremented?
      initial_value > @value
    end

    def diff
      (@value - initial_value).abs
    end

    def changed?
      diff > 0
    end

    def value
      @value
    end
    alias :to_i :value

    def initial_value
      if @initial_value.nil?
        @initial_value = self.to_i
      end
      @initial_value
    end

  end

end