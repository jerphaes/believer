module Believer
  module Updating

    # Updates all objects returned by the query with the given values
    # @param values [Hash] a hash of new values
    def update_all(values)
      q = clone
      q.selects = primary_key_columns

      batch = Batch.new(:record_class => record_class)

      q.each do |obj|
        update = Update.create(obj)
        update.values = values
        batch << update
      end
      batch.execute
    end

  end
end
