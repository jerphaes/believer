module Believer
  class DropTable < Command

    def to_cql
      "DROP TABLE #{record_class.table_name}"
    end

  end
end
