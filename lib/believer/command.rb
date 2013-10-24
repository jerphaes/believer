module Believer
  class Command

    attr_accessor :record_class

    def initialize(attrs = {})
      attrs.each do |name, value|
        send("#{name}=", value)
      end if attrs.present?
      #@instrumenter = ActiveSupport::Notifications.instrumenter
    end

    def clone
      self.class.new(query_attributes)
    end

    def query_attributes
      {:record_class => @record_class}
    end

    def command_name
      self.class.name.split('::').last.underscore
    end

    def execute(name = nil)
      name = "#{record_class.name} #{command_name}" if name.nil?
      @record_class.connection_pool.with do |connection|
        cql = to_cql
        begin
          #start = Time.now
          #res = connection.execute(cql)
          #puts "#{name} #{sprintf "%.3f", (Time.now - start)*1000.0} ms: #{cql}"
          #return res
          return ActiveSupport::Notifications.instrument('cql.believer', :cql => cql, :name => name) do
            return connection.execute(cql)
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