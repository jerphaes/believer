module Believer

  class Insert < Command
    include CqlHelper

    attr_accessor :values

    def values=(v)
      @values = v.is_a?(Base) ? v.attributes : v.to_hash
    end

    def to_cql
      attrs = @values.keys
      "INSERT INTO #{@record_class.table_name} (#{attrs.join(', ')}) VALUES (#{attrs.map {|a| to_cql_literal(@values[a]) }.join(', ')})"
    end
  end

end
