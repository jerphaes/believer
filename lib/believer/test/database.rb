module Believer
  module Test
    class Database

      # Drop, and create the keyspace. If options contains classes, creates all tables
      # @param options [Hash] the options
      # @option options :environment the environment to use. Must be a subclass of Believer::Environment::BaseEnv
      # @option options :classes an array of classes to create tables for. Items can be strings or class constants
      def self.setup(options = {})
        env = options[:environment] || Believer::Base.environment

        connection = env.create_connection(:connect_to_keyspace => false)

        keyspace = ::Believer::KeySpace.new(env)
        # First delete the existing keyspace
        begin
          #env.logger.debug "Dropping keyspace"
          keyspace.drop
        rescue Cql::QueryError
        end

        keyspace.create({})
        connection.use(env.connection_configuration[:keyspace])

        classes = options[:classes]
        classes.each do |cl|
          if cl.is_a?(String)
            clazz = cl.split('::').inject(Kernel) { |scope, const_name| scope.const_get(const_name) }
          elsif cl.is_a?(Class)
            clazz = cl
          end
          if clazz.ancestors.include?(Believer::Base)
            #puts "Creating table #{clazz.table_name}"
            clazz.create_table()
          end

        end unless classes.nil? || classes.empty?

      end

    end
  end
end
