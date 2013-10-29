require 'spec_helper'

describe Believer::WhereClause do

  [
      [:null, nil, "field = null"],
      [:string, 'abc', "field = 'abc'"],
      [:number, 23, "field = 23"],
      [:timestamp, Time.utc(2013), "field = '2013-01-01 00:00:00+0000'"],
  ].each do |scenario|
    it "simple #{scenario[0]} parameter " do
      expect(Believer::WhereClause.new('field = ?', scenario[1]).to_cql.downcase).to eql scenario[2]
    end
  end

  it 'multiple parameters' do
    expect(Believer::WhereClause.new('a = ? AND b = ? AND c = ?', 1, 2, 3).to_cql.downcase).to eql 'a = 1 and b = 2 and c = 3'
  end

  it 'simple hash parameter' do
    expect(Believer::WhereClause.new(:a => 1, :b => 2).to_cql.downcase).to eql 'a = 1 and b = 2'
  end

  it 'enumerable hash parameter' do
    expect(Believer::WhereClause.new(:a => [1, 2, 3]).to_cql.downcase).to eql 'a in (1,2,3)'
  end

end