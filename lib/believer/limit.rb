module Believer

  class Limit
    attr_reader :size

    def initialize(l)
      raise "Invalid limit: #{l}" if !l.is_a?(Numeric) || l <= 0
      @size = l.to_i
    end

    def to_cql
      "LIMIT #{@size}"
    end

    def to_i
      @size
    end

  end
  
end