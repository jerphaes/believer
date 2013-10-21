# CQL3 Object Relational Mapping
Believer is an Object Relational Mapping library for CQL3

## Installation
    gem install believer

## Inspiration
The Believer library is heavily inspired by ActiveRecord. Most patterns used in this library should be pretty familiar for ActiveRecord user.

## Usage

### Define your class
An example:

    require 'believer'

    class Artist < Believer::Base
        column :name
        column :label

        primary_key :name
    end

    class Album
        column :artist
        column :name
        column :release_date, :type => :timestamp

        primary_key :artist, :name
    end

    class Song
        column :artist
        column :album
        column :name
        column :track_number, :type => :integer

        primary_key :artist, :album, :name
    end

#### The Believer::Base class
This is the class you should extend from.

#### The column class method
Defines the mapping between a Ruby object attribute and a Cassandra column. Also defines a getter and setter attribute with the same name.
The second argument is a Hash, which support the following keys:
* type: the data type


#### The primary_key class method
Sets the primary key columns of the class.
In a situation where you're only querying data, you don't need to set this.
However, if you rely on object equality somewhere in your application, it is advisable to set the primary key.

### Query your class
The following methods can be used to query class instances.
* where: specify query filters
* select: specify which fields to load. Using none defaults to all fields being loaded.
* limit: limit the number of results to a maximum
* order: specify the order of the results

All methods are chainable, meaning you can

#### The where method
Use the where method to specify filters on the result set. These filters correspond to the expressions in the WHERE clause of a Cassandra query.

    # Using a hash
    Artist.where(:name => 'James Brown')

    # Using a hash mapping key to an array of possible values. Maps to the CQL IN operator
    Artist.where(:name => ['Coldplay', 'Depeche Mode', 'Eurythmics'])

    # Using string with interpolation
    Artist.where('name = ?', 'Foreigner')

#### The select method
Using the select method you can define the columns loaded in a query. These fields correspond to the expressions in the SELECT clause of a Cassandra query.
This might be handy in the case you have a table with a lot of columns, but only need a few.

    # Select a single field
    Artist.select(:name)

    # Select a multiple fields
    Artist.select(:name, :label)

#### The limit method
Limits the amount of records returned to the specified maximum

    # Yield at most 20 class instances
    Artist.limit(20)

#### The order method
Order the results in using the specified column

    # Order ascending by name
    Album.order(:name)
    Album.order(:name, :asc)

    # Order descending by name
    Album.order(:name, :desc)

#### Method chaining
All query methods can be chained.
This is done by creating and returning a clone of the receiver. The clone is the receiver of the query method.

    # 'Echoes'....
    Song.where(:artist => 'Pink Floyd').where(:album => 'Meddle').order(:track_number, :desc).limit(1)

