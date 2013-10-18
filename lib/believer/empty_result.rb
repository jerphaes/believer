module Believer

  class EmptyResult
    DATA_METHODS = {
        :execute => [],
        :destroy_all => nil,
        :delete_all => 0,
        :to_a => [],
        :size => 0,
        :count => 0,
        :each => nil,
        :first => nil,
        :last => nil,
        :any? => false
    }
    QUERY_METHODS = [:select, :where, :order, :limit]

    DATA_METHODS.each do |method_name, return_val|
      define_method(method_name) do |*|
        return_val
      end
    end

    QUERY_METHODS.each do |method_name|
      define_method(method_name) do |*|
        self
      end
    end

  end

end
