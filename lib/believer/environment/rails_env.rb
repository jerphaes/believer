
module Believer
  module Environment
    class RailsEnv < Believer::Environment::BaseEnv

      def load_configuration
        config_file = Rails.root + "config/believer.yml"
        config = YAML::load(File.open(config_file.to_s))
        env_config = config[Rails.env]
        env_config = {}.merge(env_config).symbolize_keys
        env_config[:logger] = Rails.logger
        env_config
      end
    end
  end
end
