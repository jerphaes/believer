require 'bundler/gem_tasks'

require 'rake'
require 'rake/testtask'

include Rake::DSL

Rake::TestTask.new :spec do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs << 'spec'
  t.libs << 'lib'
  t.verbose = true
end

task :default => [:spec]