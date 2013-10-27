require 'will_paginate/per_page'
require 'will_paginate/page_number'
require 'will_paginate/collection'
require 'believer'

module Believer
  module Extensions
    # = Paginating finders for Believer models
    #
    # WillPaginate adds +paginate+, +per_page+ and other methods to
    # Believer::Base class methods and associations.
    #
    # In short, paginating finders are equivalent to ActiveRecord finders; the
    # only difference is that we start with "paginate" instead of "find" and
    # that <tt>:page</tt> is required parameter:
    #
    #   @posts = Post.paginate :all, :page => params[:page], :order => 'created_at DESC'
    #
    module WillPaginate
      # makes a Relation look like WillPaginate::Collection
      module RelationMethods
        include ::WillPaginate::CollectionMethods

        attr_accessor :current_page
        attr_writer :total_entries, :wp_count_options

        def per_page(value = nil)
          if value.nil? then
            limit_value
          else
            limit(value)
          end
        end

        # TODO: solve with less relation clones and code dups
        def limit(num)
          rel = super
          if rel.current_page
            rel.offset rel.current_page.to_offset(rel.limit_value).to_i
          else
            rel
          end
        end

        def offset(value = nil)
          if value.nil? then
            offset_value
          else
            super(value)
          end
        end

        def total_entries
          @total_entries ||= begin
            if loaded? and size < limit_value and (current_page == 1 or size > 0)
              offset_value + size
            else
              @total_entries_queried = true
              result = count
              result = result.size if result.respond_to?(:size) and !result.is_a?(Integer)
              result
            end
          end
        end

        def count
          if limit_value
            excluded = [:order, :limit, :offset]
            excluded << :includes unless eager_loading?
            rel = self.except(*excluded)
            # TODO: hack. decide whether to keep
            rel = rel.apply_finder_options(@wp_count_options) if defined? @wp_count_options
            rel.count
          else
            super
          end
        end

        # workaround for Active Record 3.0
        def size
          if !loaded? and limit_value and group_values.empty?
            [super, limit_value].min
          else
            super
          end
        end

        # overloaded to be pagination-aware
        def empty?
          if !loaded? and offset_value
            result = count
            result = result.size if result.respond_to?(:size) and !result.is_a?(Integer)
            result <= offset_value
          else
            super
          end
        end

        def clone
          copy_will_paginate_data super
        end

        # workaround for Active Record 3.0
        def scoped(options = nil)
          copy_will_paginate_data super
        end

        def to_a
          if current_page.nil? then
            super # workaround for Active Record 3.0
          else
            ::WillPaginate::Collection.create(current_page, limit_value) do |col|
              col.replace super
              col.total_entries ||= total_entries
            end
          end
        end

        private

        def copy_will_paginate_data(other)
          other.current_page = current_page unless other.current_page
          other.total_entries = nil if defined? @total_entries_queried
          other.wp_count_options = @wp_count_options if defined? @wp_count_options
          other
        end
      end

      module Pagination
        def paginate(options)
          options = options.dup
          pagenum = options.fetch(:page) { raise ArgumentError, ":page parameter required" }
          per_page = options.delete(:per_page) || self.per_page
          total = options.delete(:total_entries)

          count_options = options.delete(:count)
          options.delete(:page)

          rel = limit(per_page.to_i).page(pagenum)
          rel = rel.apply_finder_options(options) if options.any?
          rel.wp_count_options = count_options if count_options
          rel.total_entries = total.to_i unless total.blank?
          rel
        end

        def page(num)
          rel = scoped.extending(RelationMethods)
          pagenum = ::WillPaginate::PageNumber(num.nil? ? 1 : num)
          per_page = rel.limit_value || self.per_page
          rel = rel.offset(pagenum.to_offset(per_page).to_i)
          rel = rel.limit(per_page) unless rel.limit_value
          rel.current_page = pagenum
          rel
        end
      end

      module BaseMethods

      end

      # mix everything into Believer
      ::Believer::Base.extend ::WillPaginate::PerPage
      ::Believer::Base.extend Pagination
      #::Believer::Base.extend BaseMethods

      klasses = [::Believer::Relation]

      # support pagination on associations and scopes
      klasses.each { |klass| klass.send(:include, Pagination) }
    end
  end
end

