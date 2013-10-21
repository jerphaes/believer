require 'spec_helper'

describe 'Time series' do

  before :each do
    @interval = 1.minute
    @start = Time.utc(2012)
    @count = 1000
    @count.times do |i|
      Test::Event.create(:computer_id => 1, :event_type => 1, :time => @start + (@interval * i))
    end
  end

  it 'load all' do
    Test::Event.where(:computer_id => 1, :event_type => 1).size.should == @count
  end

end