# CQL3 Object Relational Mapping
Believer is an Object Relational Mapping library for CQL3

## Installation
    gem install believer

## Inspiration
The Believer library is heavily inspired by ActiveRecord. Most patterns used in this library should be pretty familiar for ActiveRecord users.

## Usage

### Define your class
An example:

``` ruby
require 'believer'

class Artist < Believer::Base
    column :name
    column :label

    primary_key :name
end

class Album < Believer::Base
    column :artist
    column :name
    column :release_date, :type => :timestamp

    primary_key :artist, :name
end

class Song < Believer::Base
    column :artist
    column :album
    column :name
    column :track_number, :type => :integer
    column :data, :cql_type => :blob

    primary_key :artist, :album, :name
end
```

#### The Believer::Base class
This is the class you should extend from.

#### The column class method
Defines the mapping between a Ruby object attribute and a Cassandra column. Also defines a getter and setter attribute with the same name.
The second argument is a Hash, which support the following keys:
* type: the data type. Supported values are: :string, :integer, :float, :timestamp, :time, :array, :set, :map
* cql_type: the CQL data type.
* element_type: sets the type of elements in a collection if the type is a :set (CQL type SET) or an :array (CQL type LIST)
* key_type; set the type of the hash keys is the type is a :hash (CQL type MAP)
* value_type; set the type of the hash values is the type is a :hash (CQL type MAP)

Note: for correct type determination, you must include either or both the :type or the :cql_type options.

#### Counters
You can use CQL counters by setting the column type to :counter. The internal value is a Believer::Counter instance,
and can be manipulated in the following ways:

``` ruby
class AlbumSales < Believer::Base
    column :artist_name
    column :name

    column :sales, :type => :counter

    primary_key :artist_name, :name
end

album_sales = AlbumSales.new(
album_sales.sales # Returns a Believer::Counter, with a value of 0
album_sales.sales.incr # Increment counter by 1, value is 1
album_sales.sales.incr(6) # Increment counter by 3, value is 7
album_sales.sales.decr # Decrement counter by 1, value is 6
album_sales.sales.decr(3) # Decrement counter by 3, value is 3
album_sales.sales.undo_changes! # Reset it to the initial value, which is 0
album_sales.sales = 4 # Explicitly set the value...
album_sales.sales.to_i # ...which is now 4
album_sales.save

album_sales.sales.reset! # Reset the counter value to 0
album_sales.save
album_sales.sales == 0 # True
```

#### The primary_key class method
Sets the primary key columns of the class.
In a situation where you're only querying data, you don't need to set this.
However, if you rely on object equality somewhere in your application, it is advisable to set the primary key, as the primary key values are used in the Believer::Base.eql? method.

If you wish to use a partition key consisting of multiple columns, use an array as the first part of the primary_key list:

``` ruby
class Song
    ...
    primary_key [:artist, :album], :name, :...
    ...
end
```

### Query your class
The following methods can be used to query class instances.
* where: specify query filters
* select: specify which fields to load. Using none defaults to all fields being loaded.
* limit: limit the number of results to a maximum
* order: specify the order of the results
* allow_filtering: allow or disallow filtering (see ALLOW FILTERING in Cassandra CQL docs)

All methods are chainable, meaning you can

#### The where method
Use the where method to specify filters on the result set. These filters correspond to the expressions in the WHERE clause of a Cassandra query.

``` ruby
# Using a hash
Artist.where(:name => 'James Brown')

# Using a hash mapping key to an array of possible values. Maps to the CQL IN operator
Artist.where(:name => ['Coldplay', 'Depeche Mode', 'Eurythmics'])

# Using string with interpolation
Artist.where('name = ?', 'Foreigner')
```

#### The select method
Using the select method you can define the columns loaded in a query. These fields correspond to the expressions in the SELECT clause of a Cassandra query.
This might be handy in the case you have a table with a lot of columns, but only need a few.

``` ruby
# Select a single field
Artist.select(:name)

# Select a multiple fields
Artist.select(:name, :label)
```

#### The limit method
Limits the amount of records returned to the specified maximum

``` ruby
# Yield at most 20 class instances
Artist.limit(20)
```

#### The order method
Order the results in using the specified column

``` ruby
# Order ascending by name
Album.order(:name)
Album.order(:name, :asc)

# Order descending by name
Album.order(:name, :desc)
```

#### pluck
In order to retrieve just the the value(s) of one or more columns, the pluck method can be used.
This method does not instantiate any Believer::Base instances

``` ruby
# Select single column value
Album.where(:artist_name => 'Michael Jackson').pluck(:name) # -> ['Off the wall', 'Thriller', 'Bad']
# Select multiple column values
Album.where(:artist_name => 'Michael Jackson').pluck(:name, :release_date) # -> [['Off the wall', '1979-01-01', 'Thriller', 'Bad']
```

#### allow_filtering
``` ruby
Album.allow_filtering(true) # -> SELECT * FROM albums ALLOW FILTERING
Album.allow_filtering(false) # -> SELECT * FROM albums
```

#### Query methods
All query instances are decorated with a few data manipulation methods:
* update_all(values): updates all objects returned by the query with the given values
* destroy_all: destroys all objects returned by the query. This first loads the object before deleting, allowing callbacks to be called.
* destroy_all: directly deletes rows the query references. No object are loaded.

#### Method chaining
All query methods can be chained.
This is done by creating and returning a clone of the receiver. The clone is the receiver of the query method.

``` ruby
# 'Echoes'....
Song.where(:artist => 'Pink Floyd').where(:album => 'Meddle').order(:track_number, :desc).limit(1)
```

### Configuration
If using Rails or Merb, place a believer.yml file in the configuration directory of your application.
The file structure starts with the the environment name, followed by the connection configuration.
This is the client connection configuration passed to the cql-rb gem.

``` yml
development:
    host: 127.0.0.1
    port: 9042
    keyspace: my_keyspace

staging:
    host: 'staging.mynetwork.local'
    port: 9042
    keyspace: my_keyspace
    credentials:
        username: john
        password: $FDFD%@#&*
```

In other cases, you will have to programatically set the environment:

``` ruby
Believer::Base.environment = Believer::Environment::BaseEnv.new(:host => '127.0.0.1',
                                                                :keyspace => 'mykeyspace')
```

### Connection pooling
If you wish to use a pool of connections, include a :pool node to the configuration.
The pool library used is [connection_pool](https://github.com/mperham/connection_pool).

``` yaml
development:
    host: 127.0.0.1
    port: 9042
    keyspace: my_keyspace
    pool:
        size: 10
        timeout: 5
```
### Believer configuration
The Believer exposes some configuration options. These can added in a 'believer' node of the configuration hash.
Supported are options for logging, connection pooling and CQL command execution.

The connection pool options are those that are sent to the ConnectionPool.new constructor (from the connection_pool gem).

The command execution options are those which are sent to the Cql::Client.execute method of the cql-rb gem.

Some examples of logging options:

``` yaml
development:
    host: 127.0.0.1
    port: 9042
    keyspace: my_keyspace
    believer:
        logger:
            # Use the application log (f.e. /log/development.log)
            use_environment: true

development:
    host: 127.0.0.1
    port: 9042
    keyspace: my_keyspace
    believer:
        logger:
            # Use STDOUT to log messages
            use_environment: false
            # Log at info (1) level -> no CQL prints
            level: 1

development:
    host: 127.0.0.1
    port: 9042
    keyspace: my_keyspace
    believer:
        # No Believer logging at all
        logger: false
```

## Callbacks
The Believer::Base supports several callbacks to hook into the lifecycle of the models.
These callbacks can be included in the body of a Believer::Base subclass, like so:

``` ruby
class Song < Believer::Base
    after_save :do_something

    before_destroy do
        puts "About to be destroyed: #{self}"
    end

    def do_something
        puts "Just been saved: #{self}"
    end
end
```

Supported callbacks are:
* after_initialize
* before_save
* after_save
* around_save
* before_destroy
* after_destroy
* around_destroy

## Relations
If you include Believer::Relation in any class, you can define a relation between the including class and the Believer::Base instances.

Supported relations are:
* one-to-one: use the has_single method in the referencing class
* one-to-many: use the has_some method in the referencing class

Options for both relations are:
* :class the name of the referenced class. If nil, it will be created from the relation name. Can be a constant or a String
* :foreign_key the name of the attribute of the referenced class which acts as the key to this object. Can also be an array, in which case the cardinality and order must match with the :key option
* :key the name of the attribute of the referencing class which acts as the key the referenced records. Can also be an array, in which case the cardinality and order must match with the :foreign_key option
* :filter a Proc or lambda which is called with a Believer::Query instance as a parameter to tweak the relation query

Example(s):

``` ruby
class Artist
    include Believer::Relation

    attr_accessor :name

    has_some :albums, :class => 'Album', :key => :name, :foreign_key => :artist_name
end

class Album < Believer::Base
    column :artist_name
    column :name
end

class Song < Believer::Base
    include Believer::Relation

    column :artist_name
    column :album_name

    has_single :album, :class => 'Test::Album', :key => [:artist_name, :album_name], :foreign_key => [:artist_name, :name]
end
```

## Test support
An important aspect to note is that Cassandra does not support transactional rollbacks.
The consequence of this is that records persisted in a test case are not automatically deleted after a test has executed,
causing you to 'manually' delete all the garbage.

To make this a little less labor intensive, you can include the module Believer::Test::TestRunLifeCycle in your test.
This module will implement an after(:each) hook, which deletes all Believer::Base instance/records created in the span
of the test.


## Class documentation
For API go [here](http://rubydoc.info/gems/believer/frames).