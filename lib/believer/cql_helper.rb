require 'set'

module Believer

  # Contains various methods for dealing with CQL statements
  module CqlHelper

    CQL_TIMESTAMP_FORMAT = '%Y-%m-%d %H:%M:%S%z'

    # Converts a value to a CQL literal
    # @param value [Object] the value to convert
    def to_cql_literal(value)
      return 'NULL' if value.nil?
      return "'#{value}'" if value.is_a?(String)
      return "'#{value}'" if value.is_a?(Symbol)
      return "#{value}" if value.is_a?(Numeric)
      return "'#{value.strftime(CQL_TIMESTAMP_FORMAT)}'" if value.is_a?(Time) || value.is_a?(DateTime)
      #return "#{value.to_i * 1000}" if value.is_a?(Time) || value.is_a?(DateTime)

      # Set
      if value.is_a?(Set)
        return "{#{value.map {|v| to_cql_literal(v)}.join(',')}}"
      end

      # Map
      if value.is_a?(Hash)
        keys = value.keys
        return "{#{keys.map {|k| "#{to_cql_literal(k)} : #{to_cql_literal(value[k])}" }.join(',')} }"
      end

      # List
      return "[#{value.map {|v| to_cql_literal(v)}.join(',')}]" if value.is_a?(Array)

      return nil
    end

  end
end