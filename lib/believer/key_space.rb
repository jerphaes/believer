module Believer
  class KeySpace
    include CqlHelper

    DEFAULT_PROPERTIES = {:replication => {:class => 'SimpleStrategy', :replication_factor => 1}}

    def initialize(environment)
      @environment = environment
    end

    def name
      @environment.connection_configuration[:keyspace]
    end

    def drop
      connection = @environment.create_connection(:connect_to_keyspace => false)
      connection.execute("DROP KEYSPACE #{name}")
      connection.close
    end

    def create(properties = {})
      conn = @environment.create_connection(:connect_to_keyspace => false)
      ks_props = DEFAULT_PROPERTIES.merge(properties)
      ks_props_s = to_cql_properties(ks_props)
      ks_def = "CREATE KEYSPACE #{name} WITH #{ks_props_s}"
      conn.execute(ks_def)
    end

  end
end
