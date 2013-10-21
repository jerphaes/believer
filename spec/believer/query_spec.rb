require 'spec_helper'

describe Believer::Query do
 include Believer::Test::RSpec::TestRunLifeCycle

  it 'create simple statement' do
    q = Believer::Query.new(:record_class => Test::Computer)
    q = q.select(:id).
        select(:brand).
        where(:brand => 'Atari').
        where(:production_date => Time.utc(2013)).
        order(:id, :desc).
        limit(10)
    q.to_cql.should == "SELECT id, brand FROM computers WHERE brand = 'Atari' AND production_date = '2013-01-01 00:00:00+0000' ORDER BY id DESC LIMIT 10"
  end

  it 'should behave like an Enumerable' do
    puts Test::Computer.environment
    @objects = Test::Computer.create([
        {:id => 1, :brand => 'Dell'},
        {:id => 2, :brand => 'Apple'},
        {:id => 3, :brand => 'HP'}
    ])
    q = Believer::Query.new(:record_class => Test::Computer).where(:id => @objects.map {|o|o.id})
    Enumerable.instance_methods(false).each do |enum_method|
      q.respond_to?(enum_method.to_sym).should == true
    end
    q.first.should == @objects.first
  end

end