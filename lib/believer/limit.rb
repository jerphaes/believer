module Believer

  class Limit
    attr_reader :size

    def initialize(l)
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