module Believer

  # A command which issues 0 or more other commands in batch to the Cassandra server.
  # This is achieved using the CQL BATCH command
  class Batch < Command

    # Yields the collection of commands
    # @return [Array<Command>] the command collection
    def commands
      @commands ||= []
    end

    # Adds a command
    # @param command [Command] a command
    def <<(command)
      add(command)
    end

    # Adds a command
    # @param command [Command] a command
    def add(command)
      commands << command
      self
    end

    # Yields the CQL for this command
    # @return [String] the CQL
    def to_cql
      cql = "BEGIN BATCH\n"
      commands.each do |c|
        cql += "  #{c.to_cql}\n"
      end
      cql += "APPLY BATCH;\n"
      cql
    end
  end
end