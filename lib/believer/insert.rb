module Believer

  class Insert < Command
    include CqlHelper

    attr_accessor :values

    def values=(v)
      @values = v.is_a?(Base) ? v.attributes : v.to_hash
    end

    def to_cql
      attrs = @values.keys
      cols_def = "#{attrs.join(', ')}"
      vals_defs = attrs.map { |a| to_cql_literal(@values[a]) }.join(', ')
      "INSERT INTO #{@record_class.table_name} (#{cols_def}) VALUES (#{vals_defs})"
    end
  end

end
