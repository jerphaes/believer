require 'spec_helper'

describe Believer::Counter do

  it 'should have a default initial value' do
    c = Believer::Counter.new(3)
    expect(c.initial_value).to eql 3
  end

  it 'should increment' do
    c = Believer::Counter.new(3)
    c.incr
    expect(c.initial_value).to eql 3
    expect(c.to_i).to eql 4
  end

  it 'should decrement' do
    c = Believer::Counter.new(3)
    c.decr
    expect(c.initial_value).to eql 3
    expect(c.to_i).to eql 2
  end

  it 'should adopt a number value' do
    c = Believer::Counter.new(3)
    c.adopt_value(4)
    expect(c.initial_value).to eql 3
    expect(c.to_i).to eql 4
  end

  it 'should adopt a counter value' do
    c = Believer::Counter.new(3)
    c.adopt_value(Believer::Counter.new(4))
    expect(c.initial_value).to eql 3
    expect(c.to_i).to eql 4
  end

  it 'should adopt a nil value' do
    c = Believer::Counter.new(3)
    c.adopt_value(nil)
    expect(c.initial_value).to eql 3
    expect(c.to_i).to eql 0
  end


end