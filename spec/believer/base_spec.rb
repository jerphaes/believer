require 'spec_helper'

describe Believer::Base do

  it 'should implement equality' do
    a1 = Test::Artist.new(:name => 'Level 42')
    a2 = Test::Artist.new(:name => 'Level 42', :label => 'Epic')
    expect(a1).to eql(a2)
  end

  it 'should be able to reload itself' do
    artist = Test::Artist.create(:name => 'Level 42', :label => 'Epic')
    artist.label = 'Apple'
    expect(artist.reload!.label).to eql('Epic')
  end

end