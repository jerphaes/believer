module Believer
  module Relation
    extend ::ActiveSupport::Concern

    module ClassMethods
      def cql_record_relations
        @cql_record_relations ||= {}
      end

      def has_single(name, opts = {})
        if opts[:foreign_key].nil?
          opts[:foreign_key] = opts[:key].nil? ? :id : opts[:key]
        end
        if opts[:key].nil?
          opts[:key] = opts[:foreign_key].nil? ? "#{self.name.underscore}_id".to_sym : opts[:foreign_key]
        end
        has_a_relation(name, opts.merge(:type => :one_2_one))
      end

      def has_some(name, opts = {})
        if opts[:foreign_key].nil?
          opts[:foreign_key] = opts[:key].nil? ? "#{self.name.underscore}_id".to_sym : opts[:key]
        end
        if opts[:key].nil?
          opts[:key] = opts[:foreign_key].nil? ? :id : opts[:foreign_key]
        end

        has_a_relation(name, opts.merge(:type => :one_2_many))
      end

      # Defines a (one to many) relation.
      # @param name [Symbol] the name of the relation, which will also be used as an accessor method
      # @param opts [Hash] the options
      # @option opts :class the name of the referenced class. If nil, it will be created from the relation name. Can be a constant or a String
      # @option opts :foreign_key the name of the attribute of the referenced class which acts as the key to this object
      # @option opts :key the name of the attribute of the referencing class which acts as the key the referenced records
      # @option opts :filter a Proc or lambda which is called with a Believer::Query instance as a parameter to tweak the relation query
      def has_a_relation(name, opts = {})
        defaults = {
        }
        options = defaults.merge(opts)

        # Use a proc to avoid classes not yet loaded being referenced
        get_relation_class = lambda do
          if options[:relation_class].nil?
            relation_class = options[:class]
            if relation_class.nil?
              cn = name.to_s.camelize
              if options[:type] == :one_2_many
                cn = cn[0, (name.to_s.size - 1)]
              end
              relation_class = Kernel.const_get(cn)
            elsif relation_class.is_a?(String)
              relation_class = relation_class.split('::').inject(Kernel) { |scope, const_name| scope.const_get(const_name) }
            end
            options[:relation_class] = relation_class
          end
          options[:relation_class]
        end

        cql_record_relations[name] = options

        opts[:foreign_key] = opts[:foreign_key].is_a?(Array) ? opts[:foreign_key] : [opts[:foreign_key]]
        opts[:key] = opts[:key].is_a?(Array) ? opts[:key] : [opts[:key]]

        raise "key and foreign_key must have same number of items" if opts[:key].size != opts[:foreign_key].size

        self.redefine_method(name) do |reload = false|
          relation_class = get_relation_class.call

          q = relation_class.scoped
          opts[:foreign_key].each_with_index do |fk, index|
            key = opts[:key][index]
            q = q.where(fk => self.send(key))
          end
          if options[:filter]
            q = self.instance_exec(q, &(options[:filter]))
            unless q
              er = EmptyResult.new
              er.extend(CollectionMethods)
              er.extend(::Believer::FinderMethods)
              return er
            end
          end
          return q.first if options[:type] == :one_2_one

          col = Collection.new(q.query_attributes)
          col.to_a if reload
          col
        end

      end

    end

    module CollectionMethods

      def clear
        destroy(*(to_a.dup))
      end

      def destroy(*objects)
        return if loaded_objects.nil? || loaded_objects.empty?
        objects.each do |obj|
          if loaded_objects.include?(obj)
            obj.destroy
            loaded_objects.delete(obj)
          end
        end
      end

      def create(attrs = {})
        obj = record_class.create(attrs)
        loaded_objects << obj
      end

    end

    class Collection < Believer::Query
      include CollectionMethods
      include FinderMethods

    end

  end

end
