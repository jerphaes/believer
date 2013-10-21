
module Believer
  module Environment
    class RailsEnv < Believer::Environment::BaseEnv

      def connection_configuration
        unless @connection_configuration
          config_file = Rails.root + "config/cql.yml"
          #puts "Using CQL connection config file: #{config_file}"
          config = YAML::load(File.open(config_file.to_s))
          env_config = config[Rails.env]
          @connection_configuration = env_config.symbolize_keys
          @connection_configuration[:logger] = Rails.logger
        end
        @connection_configuration
      end
    end
  end
end
