module Believer
  module Environment
    extend ::ActiveSupport::Concern

    module ClassMethods

      def environment
        if @environment.nil?
          if defined?(Rails)
            @environment = RailsEnvironment.new
          end
        end
        @environment
      end

      def environment=(env)
        @environment = env
      end

    end

    class Base
      def create_connection(options = {})
        cc = connection_configuration

        if options[:connect_to_keyspace] && cc[:keyspace]
          connection = Cql::Client.connect(cc)
          connection.use(cc[:keyspace])
        else
          connection = Cql::Client.connect(cc.delete_if {|k,v|k==:keyspace})
        end
        connection
      end

      def create_keyspace(connection = nil)
        conn = connection || create_connection
        ks_def = <<-KSDEF
          CREATE KEYSPACE #{connection_configuration[:keyspace]}
          WITH replication = {
            'class': 'SimpleStrategy',
            'replication_factor': 1
          }
        KSDEF

        conn.execute(ks_def)
      end

    end

  end
end