
module Believer
  module Environment
    class MerbEnv < Believer::Environment::BaseEnv

      def load_configuration
        config_file = File.join(Merb.root, 'config', 'believer.yml')
        config = HashWithIndifferentAccess.new(YAML::load(File.open(config_file.to_s)))
        env_config = config[Merb.environment]
        env_config
      end
    end
  end
end
