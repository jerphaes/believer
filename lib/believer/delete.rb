module Believer
  class Delete < ScopedCommand

    def to_cql
      cql = "DELETE FROM #{@record_class.table_name}"
      cql << " WHERE #{@wheres.map { |wc| "#{wc.to_cql}" }.join(' AND ')}" if @wheres && @wheres.any?
      cql
    end

  end
end
