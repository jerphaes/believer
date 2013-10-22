#require "believer/environment/rails_env"
#require "believer/environment/merb_env"

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
          elsif defined?(::Merb)
            @environment = ::Believer::Environment::MerbEnv.new
          end
        end
        @environment
      end

      def environment=(env)
        @environment = env
      end

    end

    class BaseEnv
      # Default pool configuration
      DEFAULT_POOL_CONFIG = {
          :size => 1,
          :timeout => 10
      }

      # Creates a new environment using the provided configuration
      # @param config [Hash] the configuration
      def initialize(config = nil)
        @configuration = config.dup unless config.nil?
      end

      # Returns the configuration. This configuration hash should contain the cql-rb client connection parameters.
      # Optionally the connection_pool configuraton can be included in a :pool node.
      def configuration
        @configuration ||= load_configuration
      end

      # Sets the configuration
      def configuration=(config)
        @configuration = config
      end

      def connection_configuration
        configuration.reject {|k, v| k == :pool}
      end

      # The connection_pool configuration, which should be a :pool node in the configuration.
      def connection_pool_configuration
        DEFAULT_POOL_CONFIG.merge(configuration[:pool].is_a?(Hash) ? configuration[:pool].symbolize_keys! : {})
      end

      # Creates a new connection
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

      def create_keyspace(properties = {}, connection = nil)
        conn = connection || create_connection(:connect_to_keyspace => false)

        default_properties = {:replication => {:class => 'SimpleStrategy', :replication_factor => 1}}
        ks_props = default_properties.merge(properties)

        ks_props_s = ks_props.keys.map {|k|
          v = ks_props[k]
          v_s = nil
          if v.is_a?(Hash)
            v_s = v.to_json.gsub(/\"/) {|m| "'"}
          elsif v.is_a?(String)
            v_s = "'#{v}'"
          else
            v_s = v.to_s
          end
          "#{k} = #{v_s}"
        }.join("\nAND ")

        ks_def = <<-KS_DEF
          CREATE KEYSPACE #{connection_configuration[:keyspace]}
          WITH #{ks_props_s}
        KS_DEF

        puts ks_def

        conn.execute(ks_def)
      end

    end

  end
end