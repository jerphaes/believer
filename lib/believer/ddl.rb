module Believer

  module DDL
    extend ActiveSupport::Concern

    module ClassMethods

      def drop_table
        connection_pool.with do |connection|
          cql = "DROP TABLE #{table_name}"
          ActiveSupport::Notifications.instrument('deserialize.believer', :class => self, :cql => cql, :method => :drop) do
            connection.execute(cql)
          end
        end
      end

      def create_table
        connection_pool.with do |connection|
          cql = create_table_cql
          ActiveSupport::Notifications.instrument('ddl.believer', :class => self, :cql => cql, :method => :create) do
            connection.execute(cql)
          end
        end
      end

      def create_table_cql

        keys = []
        get_primary_key.each do |key_part|
          if key_part.is_a?(Enumerable)
            keys << "(#{key_part.join(',')})"
          else
            keys << key_part
          end
        end

        s = "CREATE TABLE #{table_name} (\n"
        col_statement_parts = columns.keys.map {|col| "#{col} #{columns[col].cql_type}"}
        s << col_statement_parts.join(",\n")
        s << ",\n"
        s << "PRIMARY KEY (#{keys.join(',')})"
        s << "\n)"
        s
      end
    end

  end

end