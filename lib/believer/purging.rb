module Believer
  module Purging

    # Destroys all objects returned by the query. This first loads the object before deleting, allowing callbacks to be called.
    def destroy_all
      objects = to_a
      objects.each do |obj|
        obj.destroy
      end
      objects.size
    end

    # Directly deletes rows the query references. No object are loaded.
    def delete_all
      del = Delete.new(:record_class => self.record_class)
      del.wheres = self.wheres.dup
      del.execute
    end

    def delete_all_chunked(options = {})
      cnt = count
      chunk_size = options[:delete_batch_chunk_size] || (self.limit_to.nil? ? nil : self.limit_to.size) || cnt
      key_cols = self.record_class.primary_key_columns
      deleted_count = 0
      while deleted_count < cnt
        batch = Batch.new(:record_class => @record_class)
        rows_to_delete = clone.select(key_cols).limit(chunk_size).execute
        rows_to_delete.each do |row_to_delete|
          batch << Delete.new(:record_class => self.record_class).where(row_to_delete)
        end
        batch.execute
        deleted_count += batch.commands.size
      end
      deleted_count
    end

  end
end