require 'bundler/setup'
require 'rspec/autorun'
#require 'simplecov'

require 'believer'

require 'believer/test/rspec/test_run_life_cycle'
#Dir[File.expand_path('believer/test/rspec/*.rb', __FILE__)].each {|f| require f}


#unless ENV['COVERAGE'] == 'no'
#  require 'simplecov'
#  SimpleCov.start do
#    add_filter "/spec/"
#  end
#end
#


Dir[File.expand_path('../support/*.rb', __FILE__)].each {|f| require f}


setup_database

#class Event < Cql::Model
#  primary_key :id
#
#  column :location
#  column :date
#end
#
#class Person < Cql::Model
#  primary_key :id
#
#  column :first_name
#  column :last_name
#  column :birth_date, column_name: :dob
#end