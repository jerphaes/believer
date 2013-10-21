require 'spec_helper'

describe Believer::Insert do

  it "create statement based on hash" do
    insert = Believer::Insert.new(:record_class => Test::Computer, :values => {:id => 1, :brand => 'Apple'})
    insert.to_cql.should == "INSERT INTO computers (id, brand) VALUES (1, 'Apple')"
  end
end