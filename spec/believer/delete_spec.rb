require 'spec_helper'

describe Believer::Delete do

  it "create a valid delete statement" do
    del = Believer::Delete.new(:record_class => Test::Computer)
    del = del.where(:id => 1)
    del.to_cql.should == 'DELETE FROM computers WHERE id = 1'
  end


end