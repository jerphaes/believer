require 'spec_helper'

describe Believer::Insert do

  it "create statement based on hash" do
    insert = Believer::Insert.new(:record_class => Test::Artist, :values => {:id => 1, :name => 'Beatles'})
    insert.to_cql.should == "INSERT INTO artists (id, name) VALUES (1, 'Beatles')"
  end
end