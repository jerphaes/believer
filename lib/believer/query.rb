module Believer
  class Query < FilterCommand

    attr_accessor :record_class, :selects, :order_by, :limit_to

    delegate *(Enumerable.instance_methods(false).map {|enum_method| enum_method.to_sym}), :to => :to_a
    delegate :each, :size, :[], :to => :to_a
    delegate :primary_key_columns, :to => :record_class

    def initialize(attrs)
      super
    end

    def query_attributes
      attrs = super
      attrs.merge(:order_by => @order_by, :selects => @selects, :limit_to => @limit_to)
    end

    def select(*fields)
      q = clone
      q.selects ||= []
      q.selects += fields
      q.selects.flatten!
      #puts "New selects: #{q.selects}, added: #{fields}"
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

    def to_cql
      cql = "SELECT "
      if @selects && @selects.any?
        cql << "#{@selects.join(', ')}"
      else
        cql << @record_class.columns.keys.join(',')
        #cql << "*"
      end

      cql << " FROM #{@record_class.table_name}"
      cql << " WHERE #{wheres.map { |wc| "#{wc.to_cql}" }.join(' AND ')}" if wheres.any?
      cql << " #{order_by.to_cql}" unless order_by.nil?
      cql << " #{limit_to.to_cql}" unless limit_to.nil?
      cql
    end

    def destroy_all
      objects = to_a
      objects.each do |obj|
        obj.destroy
      end
      objects.size
    end

    def delete_all(options = {})
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
        @loaded_objects = []
        start = Time.now
        result.each do |row|
          @loaded_objects << @record_class.instantiate_from_result_rows(row)
        end
        puts "Took #{sprintf "%.3f", (Time.now - start)*1000.0} ms to deserialize #{@loaded_objects.size} object(s)"
      end
      @loaded_objects
    end

    def count
      return @loaded_objects.size unless @loaded_objects.nil?

      count_q = clone
      count_q.selects = ['COUNT(*)']
      result = count_q.execute

      cnt = -1
      result.each do |row|
        cnt = row['count']
      end
      cnt
    end

    # Tests if there are any records present which conform to the argument filter(s)
    # @param args [Object] a filter condition. This argument has the same usage as the where method
    def exists?(*args)
      return count > 0 if args.nil? || args.size == 0
      where(*args).exists?
    end

    def first
      return @loaded_objects.first unless @loaded_objects.nil?
      clone.limit(1)[0]
    end

    def last
      return @loaded_objects.last unless @loaded_objects.nil?
      raise "Cannot retrieve last if no order column is set" if @order_by.nil?
      lq = clone.limit(1)
      lq.order_by = @order_by.inverse
      lq[0]
    end

    protected
    def loaded_objects
      @loaded_objects
    end

  end

end
