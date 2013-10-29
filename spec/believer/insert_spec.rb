require 'spec_helper'

describe Believer::Insert do

  it "create statement based on hash" do
    insert = Believer::Insert.new(:record_class => Test::Artist, :values => {:id => 1, :name => 'Beatles'})
    expect(insert.to_cql).to eql "INSERT INTO artists (id, name) VALUES (1, 'Beatles')"
  end
end