module Believer
  # Creates CQL DELETE statements
  class Delete < FilterCommand

    # Creates the CQL
    def to_cql
      cql = "DELETE FROM #{record_class.table_name}"
      cql << " WHERE #{wheres.map { |wc| "#{wc.to_cql}" }.join(' AND ')}" if wheres.any?
      cql
    end

  end
end
