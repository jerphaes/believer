
module Believer
  module Environment
    class RailsEnv < ::Believer::Environment::BaseEnv

      def self.applies?
        defined?(::Rails) && ::Rails.respond_to?(:env) && ::Rails.respond_to?(:root)
      end

      def load_configuration
        config_file = File.join(Rails.root, 'config', 'believer.yml')
        config = load_config_from_file(config_file)
        env_config = config[Rails.env]
        env_config
      end

      def environment_logger
        if defined?(Rails) && !Rails.nil? && Rails.logger && Rails.logger.respond_to?(:debug)
          return Rails.logger
        end
        super
      end

    end
  end
end
