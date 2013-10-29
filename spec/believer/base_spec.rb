require 'spec_helper'

describe Believer::Base do

  it 'equality' do
    a1 = Test::Artist.new(:name => 'Level 42')
    a2 = Test::Artist.new(:name => 'Level 42', :label => 'Epic')
    expect(a1).to eql(a2)
  end
end