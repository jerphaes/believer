module Believer
  class BatchDelete < FilterCommand

    DELETE_BATCH_CHUNK_SIZE = 100

    def execute
      #cql = "DELETE FROM #{@record_class.table_name}"
      #cql << " WHERE #{@wheres.map { |wc| "#{wc.to_cql}" }.join(' AND ')}" if @wheres && @wheres.any?
      #cql << " #{@limit_to.to_cql}" unless @limit_to.nil?
      #cql

      cnt = count
      s = self.limit_to.size
      key_cols = self.record_class.primary_key_columns
      cql = "BEGIN BATCH\n"
      rows = clone.select(self.record_class.primary_key_columns).execute
      rows.each do |row_to_delete|
        d = Delete.new(:record_class => self.record_class).where(row_to_delete)
        cql += "#{d.to_cql}"
      end
      cql = "APPLY BATCH;\n"
      #BatchDelete.new(:record_class => self.record_class, :wheres => self.wheres, :limit_to => self.limit_to).execute
      cnt
    end

  end
end
