module Believer

  # Contains various methods for dealing with CQL statements
  module CqlHelper

    CQL_TIMESTAMP_FORMAT = '%Y-%m-%d %H:%M:%S%z'

    # Converts a value to a CQL literal
    # @param value [Object] the value to convert
    def to_cql_literal(value)
      return 'NULL' if value.nil?
      return "'#{value}'" if value.is_a?(String)
      return "#{value}" if value.is_a?(Numeric)
      return "'#{value.strftime(CQL_TIMESTAMP_FORMAT)}'" if value.is_a?(Time) || value.is_a?(DateTime)
      #return "#{value.to_i * 1000}" if value.is_a?(Time) || value.is_a?(DateTime)
      return nil
    end

  end
end