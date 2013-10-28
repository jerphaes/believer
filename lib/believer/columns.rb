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

        columns[name] = ::Believer::Column.new(options)

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
      v = self.class.columns[attr_name].convert_to_type(v) unless self.class.columns[attr_name].nil?
      #puts "#{attr_name} :: #{value} --> #{v} ==== #{v.class.name}"
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
