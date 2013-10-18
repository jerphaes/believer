module Believer

  module Persistence

    extend ActiveSupport::Concern

    module ClassMethods

      def create(attributes = nil, &block)
        if attributes.is_a?(Array)
          attributes.collect { |attr| create(attr, &block) }
        else
          object = new(attributes, &block)
          object.save
          object
        end
      end

    end

    # Saves the model.
    def save
      Insert.new(:record_class => self.class, :values => self).execute
    end

    def destroy
      Delete.new(:record_class => self.class).where(key_values).execute
    end

  end
end
