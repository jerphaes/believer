
module Test

  class Processor < Believer::Base
    column :computer_id, :type => :integer
    column :speed, :type => :integer
    primary_key :computer_id
  end

  class Computer < Believer::Base
    include Believer::Owner


    column :id, :type => :integer
    column :brand, :type => :string
    column :production_date, :type => :timestamp

    primary_key :id

    has_some :processors, :class => Processor

  end

  class Event < Believer::Base
    column :computer_id, :type => :integer
    column :event_type, :type => :integer
    column :time, :type => :integer, :key => true
    column :description, :type => :string

    primary_key [:computer_id, :event_type], :time

  end

  class Person < Believer::Base
    self.table_name= 'people'

    column :id, :type => :integer
    column :name, :type => :string

    primary_key :id

  end

  class Environment < Believer::Environment::BaseEnv
    def connection_configuration
      {:host => '127.0.0.1', :keyspace => 'believer_test_space'}
    end
  end

  def self.test_environment
    @env ||= Environment.new
  end

  CLASSES = [Processor, Computer, Event, Person]
  CLASSES.each {|cl| cl.environment = test_environment}

  def self.classes
    CLASSES
  end
end
