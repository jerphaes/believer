require 'spec_helper'

#TODO: this is a crappy test!
describe Believer::Test::TestRunLifeCycle do
  include Believer::Test::TestRunLifeCycle

  before :all do
    @destroyed_count = 0
    @destroy_monitor = lambda do |obj|
      @destroyed_count += 1
    end

    begin
      XXX.drop_table

    rescue
    ensure
          XXX.create_table
    end
  end

  after :all do
    puts "DROP TABLE XXXX"
    @destroyed_count.should == @created.size
    XXX.drop_table
  end

  before :each do
    @created = []
    10.times do |i|
      @created << XXX.create(:name => "artist_#{i}", :destroy_monitor => @destroy_monitor)
    end
  end

  it "should clean all created objects, even after a fail" do
    #fail
  end

  class XXX < Believer::Base
    column :name, :type => :string
    primary_key :name
    cattr_accessor :destroyed_count

    attr_accessor :destroy_monitor

    before_destroy do
      @destroy_monitor.call(self)
    end
  end

end