module Believer
  class Update < FilterCommand
    include CqlHelper

    attr_accessor :values

    def self.create(object)
      pk_cols = object.class.primary_key_columns
      pk_values = object.attributes.delete_if {|k, v| !pk_cols.include?(k)}
      update_values = object.attributes.delete_if {|k, v| pk_cols.include?(k)}

      update = new(:record_class => object.class, :values => update_values)
      update.where(pk_values)
    end

    def query_attributes
      attrs = super
      attrs.merge(:values => (values.dup))
    end

    def values=(v)
      @values = v.is_a?(Base) ? v.attributes : v.to_hash
    end

    def to_cql
      pk_cols = record_class.primary_key_columns
      puts "Values: #{@values}"
      update_values = values.dup.delete_if {|k, v| pk_cols.include?(k)}

      cql = "UPDATE #{record_class.table_name} SET "
      cql << update_values.keys.map {|col| "#{col} = #{to_cql_literal(update_values[col])}"}.join(', ')
      cql << " WHERE #{wheres.map { |wc| "#{wc.to_cql}" }.join(' AND ')}" if wheres.any?
      cql
    end

  end
end
