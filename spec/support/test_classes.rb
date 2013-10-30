
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
    column :computer_id, :type => :string
    column :event_type, :type => :integer
    column :time, :type => :timestamp, :key => true
    column :description, :type => :string

    PARAMETER_NAMES = (1..5).map { |index| "parameter_#{index}".to_sym }
    PARAMETER_NAMES.each do |param|
      column param, :type => :float
    end

    primary_key [:computer_id, :event_type], :time

  end

  class Child < Believer::Base
    column :name, :type => :string
    column :marbles, :type => :set, :element_type => :symbol
    column :soccer_cards, :type => :array, :element_type => :string
    column :family, :type => :hash, :key_type => :symbol, :value_type => :string

    primary_key :name
  end

  class Environment < Believer::Environment::BaseEnv
    def configuration
      {
          :host => '127.0.0.1',
          :keyspace => 'believer_test_space',
          :believer => {
              :logger => {:level => ::Logger::DEBUG}
          }
      }
    end
  end

  def self.test_environment
    @env ||= Environment.new
  end

  Believer::Base.environment = test_environment
  CLASSES = [Artist, Album, Song, Event, Person, Child]
  #CLASSES.each {|cl| cl.environment = test_environment}

  def self.classes
    CLASSES
  end
end
