module Believer

  module Scoping
    extend ::ActiveSupport::Concern

    module ClassMethods

      def scoped
        Query.new(:record_class => self)
      end

    end

  end

end