module Believer

  module Values

    def convert_to_integer(v)
      return v.to_i unless v.nil?
      nil
    end

    def convert_to_float(v)
      return v.to_f unless v.nil?
      nil
    end

    def convert_to_boolean(v)
      return true if v.is_a?(TrueClass)
      return false if v.is_a?(FalseClass)
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
