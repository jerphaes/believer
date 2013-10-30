require 'set'

module Believer

  module Values

    # Converts the value to a one that conforms to the type of this column
    # @param v [Object] the value
    # @param value_type [Symbol] value type
    def convert_value_to_type(v, value_type)
      meth = convert_method(value_type)
      return send(meth, v) if respond_to?(meth)
      v
    end

    def convert_method(value_type)
      return nil if value_type.nil?
      "convert_to_#{value_type}".to_sym
    end

    def convert_to_string(v)
      return v.to_s unless v.nil?
      nil
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

    def convert_to_symbol(v)
      return nil if v.nil?
      return v.to_sym
    end

    def convert_to_counter(v)
      return nil if v.nil?
      return v if v.is_a?(Counter)
      Counter.new(v.to_i)
    end

    def convert_to_array(v, element_type = nil)
      return nil if v.nil?
      arr = v.is_a?(Array) ? v : Array.new(v)
      convert_collection_elements(arr, element_type)
    end

    def convert_to_set(v, element_type = nil)
      return nil if v.nil?
      s = v.is_a?(Set) ? v : Set.new(v)
      Set.new(convert_collection_elements(s, element_type))
    end

    def convert_collection_elements(col, element_type = nil)
      return col if element_type.nil?
      meth = convert_method(element_type)
      col.map {|el| send(meth, el)}
    end

    def convert_to_hash(v, key_type = nil, value_type = nil)
      return nil if v.nil?
      hash = v.is_a?(Hash) ? v : Hash.new(v)
      unless key_type.nil? && value_type.nil?
        key_conv_meth = convert_method(key_type)
        val_conv_meth = convert_method(value_type)
        hash_conv = {}
        hash.each do |key, value|
          key_conv = key_conv_meth.nil? ? key : send(key_conv_meth, key)
          value_conv = val_conv_meth.nil? ? value : send(val_conv_meth, value)
          hash_conv[key_conv] = value_conv
        end
        return hash_conv
      end
      hash
    end

  end

end
