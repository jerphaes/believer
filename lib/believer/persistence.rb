module Believer

  # Defines persistence functionality for a class
  module Persistence
    extend ::ActiveSupport::Concern

    module ClassMethods

      # Creates 1 or more new instances, and persists them to the database.
      # An optional block can be provided which is called for each created model.
      #
      # @param attributes [Enumerable] the attributes. If this is an array, it is assumed multiple models should be created
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

    # Destroys the model.
    def destroy
      Delete.new(:record_class => self.class).where(key_values).execute
    end

  end
end
