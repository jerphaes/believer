require 'spec_helper'

describe Believer::FinderMethods do

  before :each do
    @level_42 = Test::Artist.create(:name => 'Level 42')
    @u2 = Test::Artist.create(:name => 'U2')
    @ub_40 = Test::Artist.create(:name => 'UB 40')
    @artists = [@level_42, @u2, @ub_40]
  end

  it 'exists? should return true for an existing object' do
    # Test all variants
    expect(Test::Artist.exists?(:name => 'U2')).to eql true
    expect(Test::Artist.exists?('name = ?', 'U2')).to eql true
  end

  it 'exists? should return false for an non-existing object' do
    # Test all variants
    expect(Test::Artist.exists?(:name => 'Genesis')).to eql false
    expect(Test::Artist.exists?('name = ?', 'Genesis')).to eql false
  end

  it 'find using a hash' do
    expect(Test::Artist.find(:name => 'U2')).to eql @u2
  end

  it 'find using an array' do
    res = Test::Artist.find('U2', 'UB 40')
    expect(res.size).to eql 2
    expect(res.include?(@u2)).to eql true
    expect(res.include?(@ub_40)).to eql true
  end

  it 'find using single primary key value' do
    expect(Test::Artist.find('U2')).to eql @u2
  end

end