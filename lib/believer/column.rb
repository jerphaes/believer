module Believer

  # Represents a Cassandra table column
  class Column
    include Values

    CQL_TYPES = {
        :ascii => {:ruby_type => :string}, # strings US-ASCII character string
        :bigint => {:ruby_type => :integer}, # integers 64-bit signed long
        :blob => {:ruby_type => :string}, # blobs Arbitrary bytes (no validation), expressed as hexadecimal
        :boolean => {:ruby_type => :boolean}, # booleans true or false
        :counter => {:ruby_type => :integer}, # integers Distributed counter value (64-bit long)
        :decimal => {:ruby_type => :float}, # integers, floats Variable-precision decimal
        :double => {:ruby_type => :float}, # integers 64-bit IEEE-754 floating point
        :float => {:ruby_type => :float}, # integers, floats 32-bit IEEE-754 floating point
        :inet => {:ruby_type => :string}, # strings IP address string in IPv4 or IPv6 format*
        :int => {:ruby_type => :integer}, # integers 32-bit signed integer
        :list => {:ruby_type => :array}, # n/a A collection of one or more ordered elements
        :map => {:ruby_type => :hash}, # n/a A JSON-style array of literals: { literal : literal, literal : literal ... }
        :set => {:ruby_type => :array}, # n/a A collection of one or more elements
        :text => {:ruby_type => :string}, # strings UTF-8 encoded string
        :timestamp => {:ruby_type => :time}, # integers, strings Date plus time, encoded as 8 bytes since epoch
        :uuid => {:ruby_type => :string}, # uuids A UUID in standard UUID format
        :timeuuid => {:ruby_type => :integer}, # uuids Type 1 UUID only (CQL 3)
        :varchar => {:ruby_type => :string}, # strings UTF-8 encoded string
        :varint => {:ruby_type => :integer}, # integers Arbitrary-precision integer
    }

    # Supported Ruby 'types'
    RUBY_TYPES = {
        :integer => {:default_cql_type => :int},
        :string => {:default_cql_type => :varchar},
        :time => {:default_cql_type => :timestamp},
        :timestamp => {:default_cql_type => :timestamp},
        :float => {:default_cql_type => :float}
    }

    attr_reader :name, :type, :cql_type

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
      @type = opts[:type].nil? ? CQL_TYPES[opts[:cql_type]][:ruby_type] : opts[:type]
      @cql_type = opts[:cql_type].nil? ? RUBY_TYPES[opts[:type]][:default_cql_type] : opts[:cql_type]
    end

    # Converts the value to a one that conforms to the type of this column
    # @param v [Object] the value
    def convert_to_type(v)
      convert_method = "convert_to_#{@type}".to_sym
      return self.send(convert_method, v) if respond_to?(convert_method)
      v
    end

  end

end
