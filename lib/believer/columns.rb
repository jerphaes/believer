module Believer

  # Defines methods for dealing with model attributes.
  module Columns
    extend ::ActiveSupport::Concern

    included do
      include Values

      # Returns the value of the attribute identified by <tt>attr_name</tt>.
      def [](attr_name)
        read_attribute(attr_name)
      end

      # Updates the attribute identified by <tt>attr_name</tt> with the specified +value+.
      def []=(attr_name, value)
        write_attribute(attr_name, value)
      end

    end

    class Column
      #TYPES = {
      #    :ascii	strings	US-ASCII character string
      #bigint	integers	64-bit signed long
      #blob	blobs	Arbitrary bytes (no validation), expressed as hexadecimal
      #boolean	booleans	true or false
      #counter	integers	Distributed counter value (64-bit long)
      #decimal	integers, floats	Variable-precision decimal
      #double	integers	64-bit IEEE-754 floating point
      #float	integers, floats	32-bit IEEE-754 floating point
      #inet	strings	IP address string in IPv4 or IPv6 format*
      #                                                     int	integers	32-bit signed integer
      #list	n/a	A collection of one or more ordered elements
      #map	n/a	A JSON-style array of literals: { literal : literal, literal : literal ... }
      #set	n/a	A collection of one or more elements
      #text	strings	UTF-8 encoded string
      #timestamp	integers, strings	Date plus time, encoded as 8 bytes since epoch
      #uuid	uuids	A UUID in standard UUID format
      #timeuuid	uuids	Type 1 UUID only (CQL 3)
      #varchar	strings	UTF-8 encoded string
      #varint	integers	Arbitrary-precision integer
      #}
      #
      CQL_COL_TYPES = {
          :integer => 'INT',
          :string => 'VARCHAR',
          :timestamp => 'TIMESTAMP',
          :float => 'FlOAT'
      }

      attr_reader :name, :type

      def initialize(opts)
        @name = opts[:name]
        @type = opts[:type]
        raise "Invalid column type #{@type}" unless CQL_COL_TYPES.has_key?(@type)
        @key = opts[:key] == true || !opts[:key].nil?
        if @key && opts[:key].is_a?(Hash)
          @partition_key = opts[:key][:partition_key]
        end
      end

      def cql_column_type
        CQL_COL_TYPES[@type]
      end

      def is_key?
        @key
      end

      def is_partition_key?
        @partition_key
      end

    end

    module ClassMethods

      # Returns all columns on the model
      # @return []
      def columns
        @columns ||= {}
      end

        # Defines a column on the model.
      # The column name must correspond with the Cassandra column name
      def column(name, opts = {})
        defaults = {
            :type => :string
        }
        options = defaults.merge(opts).merge(:name => name)

        columns[name] = Column.new(options)

        self.redefine_method(name) do
          read_attribute(name)
        end

        self.redefine_method("#{name}=") do |val|
          write_attribute(name, val)
        end
      end

      def primary_key(*cols)
        @primary_key = *cols
      end

      def get_primary_key
        @primary_key.dup
      end

      def primary_key_columns
        @primary_key.flatten
      end

      def partition_key
        @primary_key.first.dup
      end

      def partition_keys
        part_key = partition_key
        return part_key.dup if part_key.is_a?(Enumerable)
        [part_key]
      end

      def has_compound_key?
        @primary_key.size > 1
      end


    end

    def equal_key_values?(obj)
      self.class.primary_key_columns.all? do |key_col|
        read_attribute(key_col) == obj.read_attribute(key_col)
      end
    end

    def key_values
      k = {}
      self.class.primary_key_columns.each do |key_col|
        k[key_col] = read_attribute(key_col)
      end
      k
    end

    def read_attribute(attr_name)
      @attributes[attr_name]
    end

    def write_attribute(attr_name, value)
      v = value
      # Convert the value to the actual type
      unless v.nil? && self.class.columns[attr_name]
        value_type = self.class.columns[attr_name].type
        convert_method = "convert_to_#{value_type}".to_sym
        v = self.send(convert_method, v) if respond_to?(convert_method)
      end
      @attributes[attr_name] = v
    end

    # Returns true if the given attribute is in the attributes hash
    def has_attribute?(attr_name)
      @attributes.has_key?(attr_name.to_s)
    end

    # Returns an array of names for the attributes available on this object.
    def attribute_names
      @attributes.keys
    end

    # Returns a hash of all the attributes with their names as keys and the values of the attributes as values.
    def attributes
      attrs = {}
      attribute_names.each { |name| attrs[name] = read_attribute(name) }
      attrs
    end

    def attributes=(attrs)
      attrs.each do |name, value|
        setter_method = "#{name}=".to_sym
        self.send(setter_method, value) if respond_to?(setter_method)
      end if attrs.present?
    end

  end
end
