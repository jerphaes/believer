module Believer
  # Model functionality for counter columns
  module Counting
    extend ::ActiveSupport::Concern

    module ClassMethods

      # Returns all the counter columns
      # @return an array of Column
      def counter_columns
        columns_with_type(:counter)
      end

      # Is this a model class with counter columns?
      def is_counter_table?
        counter_columns.any?
      end

    end

    # Is this a model with counters?
    def is_counter_instance?
      self.class.is_counter_table?
    end

    # Returns true if there are any counter increments or decrements
    def has_counter_diffs?
      self.class.counter_columns.any? do |col|
        counter = self.send(col.name)
        counter && counter.diff > 0
      end
    end

    # Reloads from DB, resets all counters and saves, which effectively resets all counters
    def reset_counters!
      reload!
      self.class.counter_columns.each do |cc|
        counter = self.send(cc.name)
        counter.reset! unless counter.nil?
      end
      save
    end

    # Increments a counter and saves the receiver model
    def incr_counter!(name, val = 1)
      counter = self.send(name.to_sym)
      counter.incr(val)
      save
      counter.reconcile!
    end

    # Increments a counter and saves the receiver model
    def decr_counter!(name, decr = 1)
      counter = self.send(name.to_sym)
      counter.decr(val)
      save
      counter.reconcile!
    end

  end
end
