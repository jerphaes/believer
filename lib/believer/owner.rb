module Believer
  module Owner
    extend ActiveSupport::Concern

    module ClassMethods
      def cql_record_relations
        @cql_record_relations ||= {}
      end

      def has_some(name, opts = {})
        defaults = {
        }
        options = opts.merge(defaults)

        relation_class = options[:class]
        if relation_class.nil?
          relation_class = Kernel.const_get(name.to_s.camelize[0, (name.to_s.size - 1)])
        elsif relation_class.is_a?(String)
          relation_class = Kernel.const_get(relation_type)
        end

        foreign_key = options[:foreign_key]
        foreign_key = "#{self.name.underscore}_id" if foreign_key.nil?
        foreign_key = foreign_key.to_sym

        key_attribute = options[:key_attribute]
        if key_attribute.nil?
          key_attribute = foreign_key
        end

        cql_record_relations[name] = options

        self.redefine_method(name) do
          q = relation_class.where(foreign_key => self.send(key_attribute))
          if options[:filter]
            q = options[:filter].call(self, q)
            return EmptyResult.new unless q
          end
          q
        end

      end

    end

  end

end
