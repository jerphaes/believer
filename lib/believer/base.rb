
module Believer
  class Base
    extend ::ActiveModel::Naming

    include Environment
    include Connection
    include Columns
    include ModelSchema
    include Scoping
    include Persistence
    extend Querying
    include Callbacks
    include DDL

    include ::ActiveModel::Observing

    # The Cassandra row ID
    attr_accessor :id

    def initialize(attrs = {})
      @attributes = {}
      #puts "Attrs: #{attrs.to_json}"
      #self.class.columns.each do |name, colum_definition|
      #  send("#{name}=".to_sym, attrs[name.to_s])
      #end if attrs.present?
      attrs.each do |name, val|
        send("#{name}=".to_sym, val)
      end if attrs.present?

      yield self if block_given?
    end

    def self.instantiate_from_result_rows(row)
      new(row)
    end

    def ==(obj)
      return false if obj.nil?
      return false unless obj.is_a?(self.class)
      equal_key_values?(obj)
    end

  end


end