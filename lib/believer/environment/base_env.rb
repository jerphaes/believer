module Believer
  module Environment
    class BaseEnv
      DEFAULT_CONFIG = {
          :pool => {
              :size => 1,
              :timeout => 10
          },
          :believer => {
              :logger => {
                  :use_environment => true,
                  :level => ::Logger::DEBUG
              }
          }
      }

      # Creates a new environment using the provided configuration
      # @param config [Hash] the configuration
      def initialize(config = nil)
        @configuration = config.dup unless config.nil?
      end

      def logger
        return nil unless believer_configuration[:logger]
        return environment_logger if believer_configuration[:logger][:use_environment] && respond_to?(:environment_logger)
        unless @std_logger
          puts believer_configuration[:logger]
          @std_logger = ::Logger.new(STDOUT)
          if believer_configuration[:logger][:level] && believer_configuration[:logger][:level].is_a?(Numeric)
            @std_logger.level = believer_configuration[:logger][:level].to_i
          end

        end
        @std_logger
      end

      # Returns the configuration. This configuration hash should contain the cql-rb client connection parameters.
      # Optionally the connection_pool configuraton can be included in a :pool node.
      def configuration
        unless @configuration
          loaded = load_configuration
          config = HashWithIndifferentAccess.new(DEFAULT_CONFIG.merge(loaded))
          @configuration = config
        end
        @configuration
      end

      # Sets the configuration
      def configuration=(config)
        @configuration = config
      end

      def connection_configuration
        configuration.reject { |k, v| k == :pool || k == :believer }
      end

      # The connection_pool configuration, which should be a :pool node in the configuration.
      def connection_pool_configuration
        pc = configuration[:pool]
        return DEFAULT_CONFIG[:pool] unless pc
        pc
      end

      # The connection_pool configuration, which should be a :pool node in the configuration.
      def believer_configuration
        configuration[:believer]
      end

      # Creates a new connection
      def create_connection(options = {})
        cc = connection_configuration
        if options[:connect_to_keyspace] && cc[:keyspace]
          connection = Cql::Client.connect(cc)
          connection.use(cc[:keyspace])
        else
          connection = Cql::Client.connect(cc.delete_if { |k, v| k == :keyspace })
        end
        connection
      end

      def create_keyspace(properties = {}, connection = nil)
        conn = connection || create_connection(:connect_to_keyspace => false)

        default_properties = {:replication => {:class => 'SimpleStrategy', :replication_factor => 1}}
        ks_props = default_properties.merge(properties)

        ks_props_s = ks_props.keys.map { |k|
          v = ks_props[k]
          v_s = nil
          if v.is_a?(Hash)
            v_s = v.to_json.gsub(/\"/) { |m| "'" }
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