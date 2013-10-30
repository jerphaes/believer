module Believer

  class Counter

    def initialize(v = 0, initial_val = nil)
      @value = v
      @initial_value = initial_val.nil? ? @value : initial_val
    end

    def reset!
      @value = initial_value
      self
    end

    def adopt_value(v)
      @value = 0 if v.nil?
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

    def to_i
      @value
    end

    def initial_value
      if @initial_value.nil?
        @initial_value = self.to_i
      end
      @initial_value
    end

  end

end