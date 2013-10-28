module Believer

  module DDL
    extend ActiveSupport::Concern

    module ClassMethods

      def drop_table
        ::Believer::DropTable.new(:record_class => self).execute
      end

      def create_table
        ::Believer::CreateTable.new(:record_class => self).execute
      end

    end

  end

end