
module Test

  class Artist < Believer::Base
    include Believer::Relation

    column :name
    column :label

    primary_key :name

    has_some :albums, :class => 'Test::Album', :key => :name, :foreign_key => :artist_name
  end

  class Album < Believer::Base
    column :artist_name
    column :name
    column :release_date, :type => :timestamp

    primary_key :artist_name, :name
  end

  class Song < Believer::Base
    include Believer::Relation

    column :artist_name
    column :album_name
    column :name
    column :track_number, :type => :integer
    column :data, :cql_type => :blob

    primary_key :artist_name, :album_name, :name

    has_single :album, :class => 'Test::Album', :key => [:artist_name, :album_name], :foreign_key => [:artist_name, :name]
  end

  class Person < Believer::Base
    self.table_name= 'people'

    column :id, :type => :integer
    column :name, :type => :string

    primary_key :id

  end

  class Event < Believer::Base
    column :computer_id, :type => :integer
    column :event_type, :type => :integer
    column :time, :type => :integer, :key => true
    column :description, :type => :string

    primary_key [:computer_id, :event_type], :time

  end

  class Environment < Believer::Environment::BaseEnv
    def configuration
      {:host => '127.0.0.1', :keyspace => 'believer_test_space'}
    end
  end

  def self.test_environment
    @env ||= Environment.new
  end

  Believer::Base.environment = test_environment
  CLASSES = [Artist, Album, Song, Event, Person]
  #CLASSES.each {|cl| cl.environment = test_environment}

  def self.classes
    CLASSES
  end
end
