require 'set'

module Believer

  # Represents a Cassandra table column
  class Column
    include Values

    CQL_TYPES = {
        :ascii => {:ruby_type => :string}, # strings US-ASCII character string
        :bigint => {:ruby_type => :integer}, # integers 64-bit signed long
        :blob => {:ruby_type => :string}, # blobs Arbitrary bytes (no validation), expressed as hexadecimal
        :boolean => {:ruby_type => :boolean}, # booleans true or false
        :counter => {:ruby_type => :counter}, # integers Distributed counter value (64-bit long)
        :decimal => {:ruby_type => :float}, # integers, floats Variable-precision decimal
        :double => {:ruby_type => :float}, # integers 64-bit IEEE-754 floating point
        :float => {:ruby_type => :float}, # integers, floats 32-bit IEEE-754 floating point
        :inet => {:ruby_type => :string}, # strings IP address string in IPv4 or IPv6 format*
        :int => {:ruby_type => :integer}, # integers 32-bit signed integer
        :list => {:ruby_type => :array}, # n/a A collection of one or more ordered elements
        :map => {:ruby_type => :hash}, # n/a A JSON-style array of literals: { literal : literal, literal : literal ... }
        :set => {:ruby_type => :set}, # n/a A collection of one or more elements
        :text => {:ruby_type => :string}, # strings UTF-8 encoded string
        :timestamp => {:ruby_type => :time}, # integers, strings Date plus time, encoded as 8 bytes since epoch
        :uuid => {:ruby_type => :string}, # uuids A UUID in standard UUID format
        :timeuuid => {:ruby_type => :integer}, # uuids Type 1 UUID only (CQL 3)
        :varchar => {:ruby_type => :string}, # strings UTF-8 encoded string
        :varint => {:ruby_type => :integer} # integers Arbitrary-precision integer
    }

    # Supported Ruby 'types'
    RUBY_TYPES = {
        :symbol => {:default_cql_type => :varchar},
        :integer => {:default_cql_type => :int},
        :string => {:default_cql_type => :varchar},
        :time => {:default_cql_type => :timestamp},
        :timestamp => {:default_cql_type => :timestamp},
        :float => {:default_cql_type => :float},
        :array => {:default_cql_type => :list},
        :set => {:default_cql_type => :set, :apply_cql_result_row_conversion => true},
        :hash => {:default_cql_type => :map},
        :counter => {
            :default_cql_type => :counter,
            :default_value => lambda { Counter.new },
            :apply_cql_result_row_conversion => true
        }
    }

    attr_reader :name,
                :ruby_type,
                :cql_type,
                :element_type,
                :key_type,
                :value_type

    # Creates a new instance.
    # @param opts [Hash] values options
    # @option opts :name the column name
    # @option opts :type the Ruby type. Can be :integer, :string, :time, :timestamp, :float
    # @option opts :cql_type the CQL type. See Cassandra CQL documentation and {#CQL_TYPES} for supported types
    def initialize(opts)
      raise "Must specify either a :type and/or a :cql_type" if opts[:type].nil? && opts[:cql_type].nil?
      raise "Invalid CQL column type #{opts[:cql_type]}" if opts[:cql_type] && !CQL_TYPES.has_key?(opts[:cql_type])
      raise "Invalid type #{opts[:type]}" unless RUBY_TYPES.has_key?(opts[:type])

      @name = opts[:name]
      @ruby_type = opts[:type].nil? ? CQL_TYPES[opts[:cql_type]][:ruby_type] : opts[:type]
      @cql_type = opts[:cql_type].nil? ? RUBY_TYPES[opts[:type]][:default_cql_type] : opts[:cql_type]

      @element_type = opts[:element_type]
      @key_type = opts[:key_type]
      @value_type = opts[:value_type]

      @default_value = opts[:default_value]

      @apply_cql_result_row_conversion = opts[:apply_cql_result_row_conversion] || RUBY_TYPES[@ruby_type][:apply_cql_result_row_conversion]
    end

    # Converts the value to a one that conforms to the type of this column
    # @param v [Object] the value
    def convert_to_type(v)
      # TODO: kind of a dirty hack, this...
      case @ruby_type
        when :array
          return convert_to_array(v, element_type)
        when :set
          return convert_to_set(v, element_type)
        when :hash
          return convert_to_hash(v, key_type, value_type)
      end
      convert_value_to_type(v, @ruby_type)
    end

    def to_cql
      col_stmt = "#{name} #{cql_type}"
      if cql_type == :list
        col_stmt << "<#{to_cql_type(element_type)}>"
      elsif cql_type == :set
        col_stmt << "<#{to_cql_type(element_type)}>"
      elsif cql_type == :map
        col_stmt << "<#{to_cql_type(key_type)},#{to_cql_type(value_type)}>"
      end
      col_stmt
    end

    def has_default_value?
      (@default_value != nil) || RUBY_TYPES[ruby_type][:default_value] != nil
    end

    def default_value
      def_val = @default_value || RUBY_TYPES[ruby_type][:default_value]
      unless def_val.nil?
        return def_val.call if def_val.is_a?(Proc)
        return def_val
      end
      nil
    end

    def apply_cql_result_row_conversion?
      @apply_cql_result_row_conversion == true
    end

    private
    def to_cql_type(t)
      return t if CQL_TYPES.has_key?(t)
      return RUBY_TYPES[t][:default_cql_type] if RUBY_TYPES.has_key?(t)
      nil
    end

    def to_ruby_type(t)
      return t if RUBY_TYPES.has_key?(t)
      return CQL_TYPES[t][:ruby_type] if CQL_TYPES.has_key?(t)
      nil
    end

  end

end
