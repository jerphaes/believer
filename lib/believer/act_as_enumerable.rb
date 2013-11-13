module Believer
  module ActAsEnumerable

    def self.included(base)
      base.delegate *(Enumerable.instance_methods(false).map {|enum_method| enum_method.to_sym}), :to => :to_a
      base.delegate :each, :size, :[], :to => :to_a
    end

    def count
      return loaded_objects.size unless loaded_objects.nil?

      count_q = clone
      count_q.selects = ['COUNT(*)']
      result = count_q.execute

      cnt = -1
      result.each do |row|
        cnt = row['count']
      end
      cnt
    end

    # Tests if there are any records present which conform to the argument filter(s)
    # @param args [Object] a filter condition. This argument has the same usage as the where method
    def exists?(*args)
      return count > 0 if args.nil? || args.size == 0
      where(*args).exists?
    end

    def first
      return loaded_objects.first unless loaded_objects.nil?
      clone.limit(1)[0]
    end

    def last
      return loaded_objects.last unless loaded_objects.nil?
      raise "Cannot retrieve last if no order column is set" if @order_by.nil?
      lq = clone.limit(1)
      lq.order_by = @order_by.inverse
      lq[0]
    end

    def any?
      return loaded_objects.any? unless loaded_objects.nil?
      q = clone
      q.limit(1)
      q.count > 0
    end
  end
end
