module Believer
  class Command

    attr_accessor :record_class, :consistency_level

    def initialize(attrs = {})
      attrs.each do |name, value|
        send("#{name}=", value)
      end if attrs.present?
      #@instrumenter = ActiveSupport::Notifications.instrumenter
    end

    def clone
      self.class.new(query_attributes)
    end

    def consistency(level)
      c = clone
      c.consistency_level = level
      c
    end

    def query_attributes
      {:record_class => @record_class, :consistency_level => @consistency_level}
    end

    def command_name
      self.class.name.split('::').last.underscore
    end

    def execute(name = nil)
      @record_class.connection_pool.with do |connection|
        cql = to_cql
        begin
          name = "#{record_class.name} #{command_name}" if name.nil?
          return ActiveSupport::Notifications.instrument('cql.believer', :cql => cql, :name => name) do
            exec_opts = {}
            exec_opts[:consistency] = consistency_level unless consistency_level.nil?
            return connection.execute(cql, exec_opts)
          end
        rescue Cql::Protocol::DecodingError => e
          # Decoding errors tend to #$%# up the connection, resulting in no more activity, so a reconnect is performed here.
          # This is a known issue in cql-rb, and will be fixed in version 1.10
          @record_class.reset_connection(connection)
          raise e
        end
      end

    end

  end

end