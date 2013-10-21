require 'spec_helper'

describe Believer::Limit do
  it 'create CQL' do
    Believer::Limit.new(23).to_cql.downcase.should == 'limit 23'
  end
end