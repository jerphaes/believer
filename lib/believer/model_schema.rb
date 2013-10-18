module Believer
  module ModelSchema
    extend ActiveSupport::Concern

    included do
      ##
      # :singleton-method:
      # Accessor for the name of the prefix string to prepend to every table name. So if set
      # to "basecamp_", all table names will be named like "basecamp_projects", "basecamp_people",
      # etc. This is a convenient way of creating a namespace for tables in a shared database.
      # By default, the prefix is the empty string.
      #
      # If you are organising your models within modules you can add a prefix to the models within
      # a namespace by defining a singleton method in the parent module called table_name_prefix which
      # returns your chosen prefix.
      class_attribute :table_name_prefix, :instance_writer => false
      self.table_name_prefix = ""

      ##
      # :singleton-method:
      # Works like +table_name_prefix+, but appends instead of prepends (set to "_basecamp" gives "projects_basecamp",
      # "people_basecamp"). By default, the suffix is the empty string.
      class_attribute :table_name_suffix, :instance_writer => false
      self.table_name_suffix = ""

      ##
      # :singleton-method:
      # Indicates whether table names should be the pluralized versions of the corresponding class names.
      # If true, the default table name for a Product class will be +products+. If false, it would just be +product+.
      # See table_name for the full rules on table/class naming. This is true, by default.
      class_attribute :pluralize_table_names, :instance_writer => false
      self.pluralize_table_names = true
    end

    module ClassMethods
      # Guesses the table name (in forced lower-case) based on the name of the class in the
      # inheritance hierarchy descending directly from ActiveRecord::Base. So if the hierarchy
      # looks like: Reply < Message < ActiveRecord::Base, then Message is used
      # to guess the table name even when called on Reply. The rules used to do the guess
      # are handled by the Inflector class in Active Support, which knows almost all common
      # English inflections. You can add new inflections in config/initializers/inflections.rb.
      #
      # Nested classes are given table names prefixed by the singular form of
      # the parent's table name. Enclosing modules are not considered.
      #
      # ==== Examples
      #
      #   class Invoice < ActiveRecord::Base
      #   end
      #
      #   file                  class               table_name
      #   invoice.rb            Invoice             invoices
      #
      #   class Invoice < ActiveRecord::Base
      #     class Lineitem < ActiveRecord::Base
      #     end
      #   end
      #
      #   file                  class               table_name
      #   invoice.rb            Invoice::Lineitem   invoice_lineitems
      #
      #   module Invoice
      #     class Lineitem < ActiveRecord::Base
      #     end
      #   end
      #
      #   file                  class               table_name
      #   invoice/lineitem.rb   Invoice::Lineitem   lineitems
      #
      # Additionally, the class-level +table_name_prefix+ is prepended and the
      # +table_name_suffix+ is appended. So if you have "myapp_" as a prefix,
      # the table name guess for an Invoice class becomes "myapp_invoices".
      # Invoice::Lineitem becomes "myapp_invoice_lineitems".
      #
      # You can also set your own table name explicitly:
      #
      #   class Mouse < ActiveRecord::Base
      #     self.table_name = "mice"
      #   end
      #
      # Alternatively, you can override the table_name method to define your
      # own computation. (Possibly using <tt>super</tt> to manipulate the default
      # table name.) Example:
      #
      #   class Post < ActiveRecord::Base
      #     def self.table_name
      #       "special_" + super
      #     end
      #   end
      #   Post.table_name # => "special_posts"
      def table_name
        reset_table_name unless defined?(@table_name)
        @table_name
      end

      def original_table_name #:nodoc:
        deprecated_original_property_getter :table_name
      end

      # Sets the table name explicitly. Example:
      #
      #   class Project < ActiveRecord::Base
      #     self.table_name = "project"
      #   end
      #
      # You can also just define your own <tt>self.table_name</tt> method; see
      # the documentation for ActiveRecord::Base#table_name.
      def table_name=(value)
        @original_table_name = @table_name if defined?(@table_name)
        @table_name          = value && value.to_s
        @quoted_table_name   = nil
      end

      def set_table_name(value = nil, &block) #:nodoc:
        deprecated_property_setter :table_name, value, block
        @quoted_table_name = nil
      end

      # Returns a quoted version of the table name, used to construct SQL statements.
      def quoted_table_name
        @quoted_table_name ||= "`#{table_name}`"
      end

      # Computes the table name, (re)sets it internally, and returns it.
      def reset_table_name #:nodoc:
        self.table_name = compute_table_name
      end

      def full_table_name_prefix #:nodoc:
        (parents.detect{ |p| p.respond_to?(:table_name_prefix) } || self).table_name_prefix
      end

      private

      # Guesses the table name, but does not decorate it with prefix and suffix information.
      def undecorated_table_name(class_name = base_class.name)
        table_name = class_name.to_s.demodulize.underscore
        table_name = table_name.pluralize if pluralize_table_names
        table_name
      end

      # Computes and returns a table name according to default conventions.
      def compute_table_name
        "#{full_table_name_prefix}#{undecorated_table_name(name)}#{table_name_suffix}"
      end

      def deprecated_property_setter(property, value, block)
        if block
          ActiveSupport::Deprecation.warn(
              "Calling set_#{property} is deprecated. If you need to lazily evaluate " \
            "the #{property}, define your own `self.#{property}` class method. You can use `super` " \
            "to get the default #{property} where you would have called `original_#{property}`."
          )

          define_attr_method property, value, false, &block
        else
          ActiveSupport::Deprecation.warn(
              "Calling set_#{property} is deprecated. Please use `self.#{property} = 'the_name'` instead."
          )

          define_attr_method property, value, false
        end
      end

      def deprecated_original_property_getter(property)
        ActiveSupport::Deprecation.warn("original_#{property} is deprecated. Define self.#{property} and call super instead.")

        if !instance_variable_defined?("@original_#{property}") && respond_to?("reset_#{property}")
          send("reset_#{property}")
        else
          instance_variable_get("@original_#{property}")
        end
      end
    end
  end
end
