module Believer
  module Counting
    extend ::ActiveSupport::Concern

    module ClassMethods

      def counter_columns
        columns_with_type(:counter)
      end

      def is_counter_table?
        counter_columns.any?
      end

    end

    def is_counter_instance?
      self.class.is_counter_table?
    end

    def has_counter_diffs?
      self.class.counter_columns.any? do |col|
        counter = self.send(col.name)
        counter && counter.diff > 0
      end
    end

  end
end
