require 'spec_helper'

#TODO: this is a crappy test!
describe Believer::Test::TestRunLifeCycle do
  include Believer::Test::TestRunLifeCycle

  CREATE_COUNT = 10

  before :all do
    @monitor = Monitor.new
    begin
      Fly.drop_table
    rescue
    ensure
      Fly.create_table
      @created = []
      CREATE_COUNT.times do |i|
        @created << Fly.create(:name => "artist_#{i}", :kill_monitor => @monitor)
      end
    end
  end

  after :all do
    Fly.drop_table
    expect(@monitor.kill_count).to eql @created.size
  end

  after :each do
  end

  before :each do
  end

  it "should clean all created objects, even after a fail" do
    expect(Believer::Test::TestRunLifeCycle::Destructor.instance.observed_models.size).to eql CREATE_COUNT
  end

  class Monitor
    attr_reader :kill_count

    def initialize
      @kill_count = 0
    end

    def destroyed
      @kill_count += 1
    end
  end

  class Fly < Believer::Base
    column :name, :type => :string
    primary_key :name

    attr_accessor :kill_monitor

    before_destroy do
      self.kill_monitor.destroyed
    end
  end

end