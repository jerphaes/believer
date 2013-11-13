require 'believer/extending'

module Believer
  class Query < FilterCommand
    include Extending
    include ActAsEnumerable

    DEFAULT_FILTER_LIMIT = 10000

    attr_accessor :record_class, :selects, :order_by, :limit_to, :filtering_allowed
    alias :filtering_allowed? :filtering_allowed

    delegate :primary_key_columns, :to => :record_class

    def initialize(attrs)
      super
    end

    def query_attributes
      attrs = super
      attrs.merge(:order_by => @order_by, :selects => @selects, :limit_to => @limit_to, :filtering_allowed => filtering_allowed)
    end

    def pluck(*fields)
      fields.each do |f|
        raise "Unknown field #{f} for class #{record_class}" unless record_class.columns.has_key?(f)
      end
      q = clone
      q.selects = fields
      rows = q.execute
      pluck_res = []
      rows.each do |r|
        if fields.size > 1
          pluck_res << fields.map {|f|
            val = r[f.to_s]
            col = record_class.columns[f]
            val = (col.apply_cql_result_row_conversion? ? col.convert_to_type(val) : val)
            val
          }
        else
          f = fields[0]
          val = r[f.to_s]
          col = record_class.columns[f]
          pluck_res << (col.apply_cql_result_row_conversion? ? col.convert_to_type(val) : val)
        end
      end
      pluck_res
    end

    def select(*fields)
      q = clone
      q.selects ||= []
      q.selects += fields
      q.selects.flatten!
      q
    end

    def order(field, order = :asc)
      q = clone
      q.order_by = OrderBy.new(field, order)
      q
    end

    def limit(l)
      q = clone
      q.limit_to = Limit.new(l)
      q
    end

    def limit_to=(l)
      if l.nil?
        @limit_to = nil
      else
        @limit_to = Limit.new(l.to_i)
      end
    end

    def allow_filtering(b = true)
      q = clone
      q.filtering_allowed = b
      q
    end

    def to_cql
      cql = "SELECT "
      if @selects && @selects.any?
        cql << "#{@selects.join(', ')}"
      else
        #@record_class.environment.believer_configuration[:expand_columns]
        cql << @record_class.columns.keys.join(',')
        #cql << "*"
      end

      cql << " FROM #{@record_class.table_name}"
      cql << " WHERE #{wheres.map { |wc| "#{wc.to_cql}" }.join(' AND ')}" if wheres.any?
      cql << " #{order_by.to_cql}" unless order_by.nil?
      cql << " #{limit_to.to_cql}" unless limit_to.nil?
      cql << " ALLOW FILTERING" if filtering_allowed?
      cql
    end

    def destroy_all
      objects = to_a
      objects.each do |obj|
        obj.destroy
      end
      objects.size
    end

    def delete_all
      del = Delete.new(:record_class => self.record_class)
      del.wheres = self.wheres.dup
      del.execute
    end

    def delete_all_chunked(options = {})
      cnt = count
      chunk_size = options[:delete_batch_chunk_size] || (self.limit_to.nil? ? nil : self.limit_to.size) || cnt
      key_cols = self.record_class.primary_key_columns
      deleted_count = 0
      while deleted_count < cnt
        batch = Batch.new(:record_class => @record_class)
        rows_to_delete = clone.select(key_cols).limit(chunk_size).execute
        rows_to_delete.each do |row_to_delete|
          batch << Delete.new(:record_class => self.record_class).where(row_to_delete)
        end
        batch.execute
        deleted_count += batch.commands.size
      end
      deleted_count
    end

    def to_a
      if @loaded_objects.nil?
        result = execute
        notify_payload = {:class => @record_class}
        @loaded_objects = ActiveSupport::Notifications.instrument('deserialize.believer', notify_payload) do
          objects = []
          result.each do |row|
            objects << record_class.instantiate_from_result_rows(row)
          end
          notify_payload[:count] = objects.count
          objects
        end
      end
      @loaded_objects
    end


    protected
    def loaded_objects
      @loaded_objects
    end

  end

end
