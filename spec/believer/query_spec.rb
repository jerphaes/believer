require 'spec_helper'

describe Believer::Query do
 include Believer::Test::TestRunLifeCycle

  it 'create simple statement' do
    q = Believer::Query.new(:record_class => Test::Album)
    q = q.select(:name).
        select(:artist).
        where(:name => 'Revolver').
        where(:release_date => Time.utc(2013)).
        order(:name, :desc).
        limit(10)
    q.to_cql.should == "SELECT name, artist FROM albums WHERE name = 'Revolver' AND release_date = '2013-01-01 00:00:00+0000' ORDER BY name DESC LIMIT 10"
  end

  it 'should behave like an Enumerable' do

    @objects = Test::Artist.create([
        {:name => 'Beatles', :label => 'Apple'},
        {:name => 'Jethro Tull', :label => 'Crysalis'},
        {:name => 'Pink Floyd', :label => 'Epic'}
    ])
    q = Believer::Query.new(:record_class => Test::Artist).where(:name => @objects.map {|o|o.name})
    Enumerable.instance_methods(false).each do |enum_method|
      q.respond_to?(enum_method.to_sym).should == true
    end
    q.first.should == @objects.first
  end

end