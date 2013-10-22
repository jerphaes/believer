
module Believer
  module Environment
    class RailsEnv < Believer::Environment::BaseEnv

      def load_configuration
        config_file = File.join(Rails.root, 'config', 'believer.yml')
        config = HashWithIndifferentAccess.new(YAML::load(File.open(config_file.to_s)))
        env_config = config[Rails.env]
        env_config[:logger] = Rails.logger unless Rails.logger.nil?
        env_config
      end
    end
  end
end
