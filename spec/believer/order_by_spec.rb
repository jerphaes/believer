require 'spec_helper'

describe Believer::OrderBy do

  it "create a CQL expression" do
    ob = Believer::OrderBy.new(:field)
    ob.to_cql.downcase.should == 'order by field asc'
  end

  it "reverse order" do
    ob = Believer::OrderBy.new(:field).inverse
    ob.to_cql.downcase.should == 'order by field desc'
  end
end