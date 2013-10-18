module Believer
  class OrderBy
    attr_reader :field, :dir

    def initialize(field, dir = :asc)
      raise "Invalid field: #{field}" unless field.is_a?(Symbol) || field.is_a?(String)
      raise "Direction must be one of (:asc|:desc): #{dir}" unless dir == :asc || dir == :desc
      @field = field
      @dir = dir
    end

    def to_cql
      "ORDER BY #{@field} #{@dir.present? ? @dir.to_s.upcase : 'ASC'}"
    end

    def inverse
      OrderBy.new(@field, @dir == :asc ? :desc : :asc)
    end

  end

end