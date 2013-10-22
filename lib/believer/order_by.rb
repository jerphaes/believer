module Believer

  # Encapsulates the CQL ORDER BY clause
  class OrderBy

    attr_reader :field, :dir

    # @param field [Symbol] the field to order by
    # @param dir [Symbol] the order direction. Can be :asc or :desc. Default is :asc
    def initialize(field, dir = :asc)
      raise "Invalid field: #{field}" unless field.is_a?(Symbol) || field.is_a?(String)
      raise "Direction must be one of (:asc|:desc): #{dir}" unless dir == :asc || dir == :desc
      @field = field
      @dir = dir
    end

    # Creates the CQL ORDER BY clause
    def to_cql
      "ORDER BY #{@field} #{@dir.to_s.upcase}"
    end

    # Inverts the direction of the order
    def inverse
      OrderBy.new(@field, @dir == :asc ? :desc : :asc)
    end

  end

end