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
    Rails = Struct.new(:root, :env, :logger).new(File.join(RSpec.configuration.test_files_dir, 'rails'), :test, nil)
    env = Believer::Base.environment
    env.class.should == Believer::Environment::RailsEnv
    env.configuration[:host].should == '123.456.789.0'
    #remove_const(Rails)
    Rails = nil
  end

  it 'load the Merb configuration' do
    Merb = Struct.new(:root, :environment, :logger).new(File.join(RSpec.configuration.test_files_dir, 'merb'), :test, nil)
    env = Believer::Base.environment
    env.class.should == Believer::Environment::MerbEnv
    env.configuration[:host].should == 'merb.test.local'
    #remove_const(Merb)
    Merb = nil
  end

end