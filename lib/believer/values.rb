module Believer

  module Values

    TIMESTAMP_FORMAT = '%Y-%m-%d %H:%M:%S%z'

    def to_cql_literal(value)
      return 'NULL' if value.nil?
      return "'#{value}'" if value.is_a?(String)
      return "#{value}" if value.is_a?(Numeric)
      return "'#{value.strftime(TIMESTAMP_FORMAT)}'" if value.is_a?(Time) || value.is_a?(DateTime)
      #return "#{value.to_i * 1000}" if value.is_a?(Time) || value.is_a?(DateTime)
      return nil
    end

    def convert_to_integer(v)
      return v.to_i unless v.nil?
      nil
    end

    def convert_to_float(v)
      return v.to_f unless v.nil?
      nil
    end

    def convert_to_boolean(v)
      return v.to_bool if v.respond_to?(:to_bool)
      nil
    end

    def convert_to_time(v)
      return nil if v.nil?
      return v if v.is_a?(Time)
      return Time.parse(v) if v.is_a?(String)
      Time.at(v.to_i)
    end

  end

end
