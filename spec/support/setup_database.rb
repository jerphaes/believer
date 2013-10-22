require 'believer'

def setup_database
  env = Test.test_environment

  connection = env.create_connection(:connect_to_keyspace => false)
  begin
    connection.use(env.connection_configuration[:keyspace])
  rescue Cql::QueryError

    env.create_keyspace({}, connection)
    connection.use(env.connection_configuration[:keyspace])

    Test.classes.each do |cl|
      puts "Creating table #{cl.table_name}"
      cl.create_table
    end
  end

end
