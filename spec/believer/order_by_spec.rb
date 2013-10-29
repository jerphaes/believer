require 'spec_helper'

describe Believer::OrderBy do

  it "create a CQL expression" do
    ob = Believer::OrderBy.new(:field)
    expect(ob.to_cql.downcase).to eql 'order by field asc'
  end

  it "reverse order" do
    ob = Believer::OrderBy.new(:field).inverse
    expect(ob.to_cql.downcase).to eql 'order by field desc'
  end
end