require 'cql'
require 'yaml'

module Believer
  module Connection
    extend ActiveSupport::Concern

    module ClassMethods

      def reset_connection
        unless connection.nil?
          connection.close
          @client_connection = nil
        end
      end

      def connection
        unless @client_connection
          cc = Cql::Client.connect(connection_config)
          cc.use(connection_config[:keyspace])
          @client_connection = cc
        end
        @client_connection
      end

      def connection_config
        unless @connection_config
          config_file = Rails.root + "config/cql.yml"
          puts "Using CQL connection config file: #{config_file}"
          config = YAML::load(File.open(config_file.to_s))
          env_config = config[Rails.env]
          @connection_config = env_config.symbolize_keys
          @connection_config[:logger] = Rails.logger
        end
        @connection_config
      end

    end

  end

end