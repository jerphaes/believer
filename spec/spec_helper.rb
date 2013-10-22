require 'bundler/setup'
require 'rspec/autorun'
require 'simplecov'

unless ENV['COVERAGE'] == 'no'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require 'believer'
require 'believer/test/test_run_life_cycle'

Dir[File.expand_path('../support/*.rb', __FILE__)].each {|f| require f}

setup_database

RSpec.configure do |c|
  c.add_setting :test_files_dir, :default => File.expand_path('../test_files/', __FILE__)
end

File.expand_path('../test_files/', __FILE__)