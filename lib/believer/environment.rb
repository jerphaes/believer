#require "believer/environment/rails_env"

module Believer
  module Environment
    extend ::ActiveSupport::Concern

    module ClassMethods

      def environment

        if @environment.nil?
          if self.superclass.respond_to?(:environment)
            @environment = self.superclass.environment
          elsif defined?(::Rails)
            @environment = ::Believer::Environment::RailsEnv.new
          end
        end
        @environment
      end

      def environment=(env)
        @environment = env
      end

    end

    class BaseEnv
      #def connection_configuration
      #  {:host => '127.0.0.1'}
      #end

      def initialize(config = nil)
        @configuration = config.dup unless config.nil?
      end

      def configuration
        @configuration ||= load_configuration
      end

      def configuration=(config)
        @configuration = config
      end

      def connection_configuration
        @connection_configuration ||= configuration.reject_if {|k, v| k == :pool}
      end

      def create_connection(options = {})
        cc = connection_configuration

        if options[:connect_to_keyspace] && cc[:keyspace]
          connection = Cql::Client.connect(cc)
          connection.use(cc[:keyspace])
        else
          connection = Cql::Client.connect(cc.delete_if {|k,v|k == :keyspace})
        end
        connection
      end

      def create_keyspace(connection = nil)
        conn = connection || create_connection
        ks_def = <<-KS_DEF
          CREATE KEYSPACE #{connection_configuration[:keyspace]}
          WITH replication = {
            'class': 'SimpleStrategy',
            'replication_factor': 1
          }
        KS_DEF

        conn.execute(ks_def)
      end

    end

  end
end