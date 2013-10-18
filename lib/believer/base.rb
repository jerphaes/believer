require 'active_support/core_ext/module/delegation'

module Believer
  class Base
    extend ActiveModel::Naming

    include Connection
    include Columns
    include ModelSchema
    include Scoping
    include Persistence
    extend Querying
    include Callbacks

    include ActiveModel::Observing

    # The Cassandra row ID
    attr_accessor :id

    def initialize(attrs = {})
      @attributes = {}
      attrs.each do |name, value|
        send("#{name}=", value)
      end if attrs.present?
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