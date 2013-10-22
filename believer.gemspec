# encoding: utf-8

#$: << File.expand_path('../lib', __FILE__)
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'believer/version'

Gem::Specification.new do |s|
  s.name          = 'believer'
  s.version       = Believer::Version::VERSION.dup
  s.authors       = ['Jerphaes van Blijenburgh']
  s.email         = ['jerphaes@gmail.com']
  s.homepage      = 'http://github.com/jerphaes/believer'
  s.summary       = %q{CQL3 ORM}
  s.description   = %q{An Objeect Relational Mapping library for CQL3 }
  s.license       = 'Apache License 2.0'

  s.files         = Dir['lib/**/*.rb', 'bin/*', 'README.md']
  s.test_files    = Dir['spec/**/*.rb']
  s.require_paths = %w(lib)
  s.bindir        = 'bin'

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency 'activemodel', '3.2.13'
  s.add_dependency 'cql-rb', '1.1.0.pre6'
  s.add_dependency 'connection_pool'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov', '0.7.1'

end