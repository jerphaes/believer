require 'yaml'
require 'open3'

class Migrator

  attr_reader :hostname, :port, :keyspace, :username, :password

  def initialize env
    conf = YAML.load(File.open("config/cassandra.yml"))
    servers = conf[env]["servers"].split ","
    server = servers[rand(servers.length)]
    @hostname, @port = server.split ":"
    @keyspace = conf[env]["keyspace"]
    @username = conf[env]["username"]
    @password = conf[env]["password"]
  end

  def execute
    executed  = executed_migrations
    available = available_migrations
    #return if executed.length == available.length
    available.each do |migration|
      next if executed.include?(migration)
      cql = File.read(migration)
      cql << "\n"
      out, err = cqlsh cql
      check_result err
      puts "Executed migration #{migration}"
      insert migration
    end
  end

  def create
    out, err = cqlsh keyspace_schema, false
    if err.length > 0
      $stderr.puts "Creating keyspace #{keyspace} failed: #{err}"
      exit(1)
    end
  end

  private

  def cqlsh command, use_keyspace = true
    sh = "cqlsh -3 "
    sh << "-u #{username} " if username
    sh << "-p #{password} " if password
    sh << "-k #{keyspace} " if use_keyspace
    sh << "#{hostname} #{port}"
    Open3.popen3(sh) do |stdin, stdout, stderr, wait_thr|
      stdin.write command
      stdin.close
      [stdout.read, stderr.read]
    end
  end

  def keyspace_schema
    "CREATE KEYSPACE #{keyspace} WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};\n"
  end

  def migration_table_schema
    "CREATE TABLE schema_migrations (name varchar PRIMARY KEY, executed timestamp);\n"
  end

  def parse_out out
    migrations = []
    out.split("\n").each do |line|
      # Commented out line below because a migration name may contain a string 'version'. Why is this here????
      #next if line =~ /version/
      next if line =~ /---/
      migrations << line.strip
    end
    migrations
  end

  def executed_migrations
    out, err = cqlsh "select name from schema_migrations;\n"
    if err =~ /unconfigured/
      out, err = cqlsh migration_table_schema
      check_result err
      out, err = cqlsh "select name from schema_migrations;\n"
    end

    check_result err
    parse_out(out)
  end

  def available_migrations
    Dir["migrations/**.cql"].sort
  end

  def insert migration
    command = "INSERT INTO schema_migrations (name, executed) VALUES ('#{migration}', #{Time.now.to_i * 1000});\n"
    cqlsh command
  end

  def check_result err
    unless err.empty?
      $stderr.puts "Failed to retrieve migration info: #{err}"
      exit(1)
    end
  end
end

namespace :db do
  task :create do
    env = ENV["STORM_ENV"] || "development"
    Migrator.new(env).create
  end

  task :migrate do
    env = ENV["STORM_ENV"] || "development"
    Migrator.new(env).execute
  end
end
