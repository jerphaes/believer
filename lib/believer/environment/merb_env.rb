
module Believer
  module Environment
    class MerbEnv < Believer::Environment::BaseEnv

      def self.applies?
        defined?(::Merb)
      end

      def load_configuration
        config_file = File.join(Merb.root, 'config', 'believer.yml')
        config = load_config_from_file(config_file)
        env_config = config[Merb.environment]
        env_config
      end
    end
  end
end
