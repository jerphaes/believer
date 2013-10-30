module Believer
  class Update < FilterCommand
    include CqlHelper

    attr_accessor :values

    def self.create(object)
      pk_cols = object.class.primary_key_columns
      pk_values = object.attributes.delete_if {|k, v| !pk_cols.include?(k)}

      update = new(:record_class => object.class, :values => object.attributes)
      update.where(pk_values)
    end

    def query_attributes
      attrs = super
      attrs.merge(:values => (values.dup))
    end

    def values=(v)
      pk_cols = record_class.primary_key_columns
      vals = v.is_a?(Base) ? v.attributes : v.to_hash
      @values = vals.dup.delete_if {|k, v| pk_cols.include?(k)}
    end

    def can_execute?
      if record_class.is_counter_table?
        mock_instance = record_class.new(values)
        return mock_instance.has_counter_diffs?
      end
      true
    end

    def to_cql
      cql = "UPDATE #{record_class.table_name} SET "
      cql << values.keys.map {|col| assign_statement(col, values[col]) }.flatten.join(', ')
      cql << " WHERE #{wheres.map { |wc| "#{wc.to_cql}" }.join(' AND ')}" if wheres.any?
      cql
    end

    def assign_statement(col_name, val)
      column = record_class.columns[col_name]
      if column.ruby_type == :counter
        return nil if val.nil?
        operator = val.incremented? ? '+' : '-'
        return "#{col_name} = #{col_name} #{operator} #{val.diff}"
      end
      "#{col_name} = #{to_cql_literal(val)}"
    end

  end
end
