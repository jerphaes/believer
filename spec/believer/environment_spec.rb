require 'spec_helper'

describe Believer::Environment do

  before :each do
    @original_env = Believer::Base.environment
    Believer::Base.environment = nil
  end

  after :each do
    Believer::Base.environment = @original_env
  end

  it 'load the rails configuration' do
    if defined?(Rails)
      puts "Rails: #{Rails}"
    end
    Rails = Struct.new(:root, :env, :logger).new(File.join(RSpec.configuration.test_files_dir, 'rails'), :test, nil)
    env = Believer::Base.environment
    expect(env.class).to eql Believer::Environment::RailsEnv
    expect(env.configuration[:host]).to eql '123.456.789.0'
    Object.instance_eval { remove_const :Rails}
  end

  it 'load the Merb configuration' do
    if defined?(Merb)
      puts "Rails: #{Merb}"
    end
    Merb = Struct.new(:root, :environment, :logger).new(File.join(RSpec.configuration.test_files_dir, 'merb'), :test, nil)
    env = Believer::Base.environment
    expect(env.class).to eql Believer::Environment::MerbEnv
    expect(env.configuration[:host]).to eql 'merb.test.local'
    Object.instance_eval { remove_const :Merb}
  end

end