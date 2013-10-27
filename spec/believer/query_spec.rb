require 'spec_helper'

describe Believer::Query do
  include Believer::Test::TestRunLifeCycle

  let :artists do
    Test::Artist.create(
        [
            {:name => 'Beatles', :label => 'Apple'},
            {:name => 'Jethro Tull', :label => 'Crysalis'},
            {:name => 'Pink Floyd', :label => 'Epic'},
            {:name => 'Michael Jackson', :label => 'Epic'}
    ])
  end

  let :albums do
    Test::Album.create(
        [
            {:artist_name => 'Beatles', :name => 'Help'},
            {:artist_name => 'Jethro Tull', :name => 'Aqualung'},
            {:artist_name => 'Jethro Tull', :name => 'Standup'},
            {:artist_name => 'Michael Jackson', :name => 'Thriller'}
        ])

  end

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

  it 'should include allow filtering clause' do
    q = Believer::Query.new(:record_class => Test::Album)
    q = q.select(:name)
    expect(q.to_cql).to eql "SELECT name FROM albums"
    q = q.allow_filtering(true)
    expect(q.to_cql).to eql "SELECT name FROM albums ALLOW FILTERING"
    q = q.allow_filtering(false)
    expect(q.to_cql).to eql "SELECT name FROM albums"
  end

  it 'should behave like an Enumerable' do
    q = Believer::Query.new(:record_class => Test::Artist).where(:name => artists.map { |o| o.name })
    Enumerable.instance_methods(false).each do |enum_method|
      q.respond_to?(enum_method.to_sym).should == true
    end
  end

  it 'should order' do
    q = Believer::Query.new(:record_class => Test::Album).select(:name)
    q = q.order(:release_date, :desc)
    expect(q.to_cql).to eql("SELECT name FROM albums ORDER BY release_date DESC")
  end

  it 'should be able to pluck single column values' do
    albums
    q = Believer::Query.new(:record_class => Test::Album).where(:artist_name => 'Jethro Tull')
    album_names = q.pluck(:name)
    expect(album_names.size).to eql(2)
    expect(album_names).to include('Standup')
    expect(album_names).to include('Aqualung')
  end

  it 'should be able to pluck multiple column values' do
    albums
    q = Believer::Query.new(:record_class => Test::Album).where(:artist_name => 'Jethro Tull').order(:name)
    album_names = q.pluck(:name, :artist_name)
    expect(album_names).to eql([['Aqualung', 'Jethro Tull'], ['Standup', 'Jethro Tull']])
  end

  it 'should not be able to pluck if an unknown column name is used' do
    albums
    q = Believer::Query.new(:record_class => Test::Album).where(:artist_name => 'Jethro Tull').order(:name)
    begin
      q.pluck(:artist_xxx)
      fail
    rescue Exception => e
    end
    begin
      q.pluck(:name, :artist_xxx)
      fail
    rescue Exception => e
    end
  end

end