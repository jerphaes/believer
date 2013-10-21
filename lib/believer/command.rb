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

    def connection
      @record_class.connection
    end

    def execute(name = 'cql.cql_record')
      cql = to_cql
      begin
        start = Time.now
        puts "Executing #{cql}"
        res = connection.execute(cql)
        #Rails.logger.debug "#{name} #{sprintf "%.3f", (Time.now - start)*1000.0} ms: #{cql}"
        return res
      rescue Cql::Protocol::DecodingError => e
        # Decoding errors tend to #$%# up the connection, resulting in no more activity, so a reconnect is performed here.
        # This is a known issue in cql-rb, and will be fixed in version 1.10
        @record_class.reset_connection
        raise e
      end

    end

  end

end