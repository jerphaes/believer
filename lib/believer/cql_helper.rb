require 'set'

module Believer

  # Contains various methods for dealing with CQL statements
  module CqlHelper

    CQL_TIMESTAMP_FORMAT = '%Y-%m-%d %H:%M:%S%z'

    # Converts a value to a CQL literal
    # @param value [Object] the value to convert
    def to_cql_literal(value)
      return 'NULL' if value.nil?
      return "'#{escape_special_chars(value)}'" if value.is_a?(String)
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

    def to_cql_properties(properties)
      return '' if properties.nil? || properties.empty?

      props_s = properties.keys.map { |k|
        v = properties[k]
        v_s = nil
        if v.is_a?(Hash)
          v.each {|k, val| v[k] = escape_special_chars(val) if val.is_a?(String)}
          v_s = v.to_json.gsub(/\"/) { |m| "'" }
        elsif v.is_a?(String)
          v_s = "'#{escape_special_chars(v)}'"
        else
          v_s = escape_special_chars(v.to_s)
        end
        "#{k} = #{v_s}"
      }.join("\nAND ")

      props_s
    end

    def escape_special_chars(v)
      v.gsub("'", "''")
    end

    def to_hex_literal(s)
      s.unpack('U'*s.length).map {|i|i.to_s(16)}.join()
    end

  end
end