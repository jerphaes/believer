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
    Test::Artist.exists?(:name => 'U2').should == true
    Test::Artist.exists?('name = ?', 'U2').should == true
  end

  it 'exists? should return false for an non-existing object' do
    # Test all variants
    Test::Artist.exists?(:name => 'Genesis').should == false
    Test::Artist.exists?('name = ?', 'Genesis').should == false
  end

  it 'find using a hash' do
    Test::Artist.find(:name => 'U2').should == @u2
  end

  it 'find using an array' do
    res = Test::Artist.find('U2', 'UB 40')
    res.size.should == 2
    res.include?(@u2).should == true
    res.include?(@ub_40).should == true
  end

  it 'find using single primary key value' do
    Test::Artist.find('U2').should == @u2
  end

end