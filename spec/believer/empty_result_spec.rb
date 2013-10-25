require 'spec_helper'

describe Believer::EmptyResult do

  let :empty_result do
    Believer::EmptyResult.new(:record_class => Test::Artist)
  end
  let :artist do
    Test::Artist.create(:name => 'Colplay')
  end

  it "should not return data" do
    expect(empty_result.size).to eq(0)
    expect(empty_result.to_a).to eq([])
  end

  {
      :select => [:name],
      :where => {:name => 'Colplay'},
      :order => :name,
      :limit => 10
  }.each do |method, args|
    it "should remain empty after #{method} query call" do
      empty_new = empty_result.send(method, args)
      expect(empty_new.size).to eq(0)
      expect(empty_new.to_a).to eq([])
    end
  end

  it "should return false for exists?" do
    expect(empty_result.exists?).to eq(false)
  end

  it "should return 0 for count" do
    expect(empty_result.count).to eq(0)
  end

end