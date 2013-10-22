module Believer

  module DDL
    extend ActiveSupport::Concern

    module ClassMethods
      def create_table
        connection_pool.with do |connection|
          cql = create_table_cql
          puts "Creating table #{table_name} using CQL:\n#{cql}"
          connection.execute(cql)
          puts "Created table #{table_name}"
        end
      end

      def create_table_cql
        s = "CREATE TABLE #{table_name} (\n"
        col_statement_parts = columns.keys.map {|col| "#{col} #{columns[col].cql_type}"}
        s << col_statement_parts.join(",\n")

        keys = []
        get_primary_key.each do |key_part|
          if key_part.is_a?(Enumerable)
            keys << "(#{key_part.join(',')})"
          else
            keys << key_part
          end
        end
        s << ",\n"
        s << "PRIMARY KEY (#{keys.join(',')})"
        s << "\n)"
        s
      end
    end

  end

end