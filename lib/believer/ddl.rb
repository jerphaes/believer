module Believer

  module DDL
    extend ActiveSupport::Concern

    module ClassMethods

      def drop_table
        ::Believer::DropTable.new(:record_class => self).execute
      end

      def create_table(properties = {})
        ::Believer::CreateTable.new(:record_class => self, :table_properties => properties).execute
      end

    end

  end

end