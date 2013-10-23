require 'spec_helper'

describe 'Time series' do
  include Believer::Test::TestRunLifeCycle

  before :each do
    @interval = 1.minute
    @start = Time.utc(2012)
    @count = 10
    @count.times do |i|
      attrs = {:computer_id => 'ABC', :event_type => 1, :time => @start + (@interval * i)}
      Test::Event::PARAMETER_NAMES.each do |param|
        attrs[param] = rand(1000) * rand(1000)
      end
      Test::Event.create(attrs)
    end
  end

  it 'load all' do
    Test::Event.where(:computer_id => 'ABC', :event_type => 1).size.should == @count
  end

end