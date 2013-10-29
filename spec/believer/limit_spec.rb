require 'spec_helper'

describe Believer::Limit do
  it 'create CQL' do
    expect(Believer::Limit.new(23).to_cql.downcase).to eql 'limit 23'
  end
end