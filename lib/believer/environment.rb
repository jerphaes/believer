module Believer
  module Environment
    extend ::ActiveSupport::Concern
    ENVIRONMENTS = [
        ::Believer::Environment::RailsEnv,
        ::Believer::Environment::MerbEnv
    ]

    module ClassMethods
      def environment
        if @environment.nil?
          if self.superclass.respond_to?(:environment)
            @environment = self.superclass.environment
          else
            env_class = ENVIRONMENTS.find { |env| env.respond_to?(:applies?) && env.applies? }
            @environment = env_class.new if env_class
          end
        end
        @environment
      end

      def environment=(env)
        @environment = env
      end

    end

  end
end