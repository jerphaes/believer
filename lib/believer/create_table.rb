module Believer
  class CreateTable < Command
    include CqlHelper

    attr_accessor :table_properties

    def to_cql
      keys = []
      record_class.get_primary_key.each do |key_part|
        if key_part.is_a?(Enumerable)
          keys << "(#{key_part.join(',')})"
        else
          keys << key_part
        end
      end

      s = "CREATE TABLE #{record_class.table_name} (\n"
      col_statement_parts = record_class.columns.keys.map {|col_name| record_class.columns[col_name].to_cql }
      s << col_statement_parts.join(",\n")
      s << ",\n"
      s << "PRIMARY KEY (#{keys.join(',')})"
      s << "\n)"

      unless table_properties.nil? || table_properties.empty?
        s << " WITH #{to_cql_properties(table_properties)}"
      end

      s
    end

  end
end
