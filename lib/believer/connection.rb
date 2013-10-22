require 'connection_pool'

module Believer
  module Connection
    extend ::ActiveSupport::Concern

    module ClassMethods

      def reset_connection(conn)
        unless conn.nil?
          conn.close
        end
      end

      def connection_pool
        Believer::Connection::Pool.instance.connection(environment)
        #@client_connection ||= environment.create_connection(:connect_to_keyspace => true)
      end

    end

    class Pool
      include ::Singleton

      # Retrieve a connection from the pool
      # @param environment [Believer::Environment::BaseEnv] the environment with the connection configuration
      def connection(environment)
        unless @connection_pool
          pool_config = environment.connection_pool_configuration
          @connection_pool ||= ::ConnectionPool.new(pool_config) do
            environment.create_connection(:connect_to_keyspace => true)
          end
        end
        @connection_pool
      end

    end

  end

end