module Believer

  #class EmptyResult
  #  DATA_METHODS = {
  #      :execute => [],
  #      :destroy_all => nil,
  #      :delete_all => 0,
  #      :to_a => [],
  #      :size => 0,
  #      :count => 0,
  #      :each => nil,
  #      :first => nil,
  #      :last => nil,
  #      :any? => false,
  #      :sort_by => nil,
  #      :loaded_objects => []
  #  }
  #  QUERY_METHODS = [:select, :where, :order, :limit]
  #
  #  DATA_METHODS.each do |method_name, return_val|
  #    define_method(method_name) do |*|
  #      return_val
  #    end
  #  end
  #
  #  QUERY_METHODS.each do |method_name|
  #    define_method(method_name) do |*|
  #      self
  #    end
  #  end
  #
  #end
  class EmptyResult < ::Believer::Query

    def clone
      self
    end

    def to_cql
      nil
    end

    def to_a
      []
    end

    def exists?(*args)
      false
    end

    def count
      0
    end

    def execute(name = nil)
      []
    end

    protected
    def loaded_objects
      []
    end

  end
end
