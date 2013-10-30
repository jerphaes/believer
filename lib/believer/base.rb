
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
    extend FinderMethods
    include Callbacks
    include Counting
    include DDL

    include ::ActiveModel::Observing

    # The Cassandra row ID
    attr_accessor :id

    def initialize(attrs = {})
      @attributes = {}
      set_attributes(attrs)
      yield self if block_given?
    end

    def self.instantiate_from_result_rows(row)
      new(row)
    end

    def reload!
      persisted_object = self.class.scoped.where(key_values).first
      unless persisted_object.nil?
        set_attributes(persisted_object.attributes)
      end
      self
    end

    def set_attributes(attrs)
      attrs.each do |name, val|
        send("#{name}=".to_sym, val)
      end if attrs.present?
    end

    def ==(obj)
      eql?(obj)
    end

    def eql?(obj)
      return false if obj.nil?
      return false unless obj.is_a?(self.class)
      equal_key_values?(obj)
    end

    def self.logger
      environment.logger
    end

  end


end

ActiveSupport.run_load_hooks(:believer, Believer::Base)