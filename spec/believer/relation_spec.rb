require 'spec_helper'

describe Believer::Relation do
  include Believer::Test::TestRunLifeCycle

  before :each do
    @beatles = Test::Artist.create(:name => 'Beatles', :label => 'Apple')
    @jethro_tull = Test::Artist.create(:name => 'Jethro Tull', :label => 'Crysalis')
    @pink_floyd = Test::Artist.create(:name => 'Pink Floyd', :label => 'Epic')

    @help = Test::Album.create(:artist_name => 'Beatles', :name => 'Help', :release_date => Time.utc(1965))
    @revolver = Test::Album.create(:artist_name => 'Beatles', :name => 'Revolver', :release_date => Time.utc(1966))
    @abbey_road = Test::Album.create(:artist_name => 'Beatles', :name => 'Abbey Road', :release_date => Time.utc(1969))

    @dark_side_of_the_moon = Test::Album.create(:artist_name => 'Pink Floyd', :name => 'Dark side of the moon', :release_date => Time.utc(1973))
    @wish_you_were_here = Test::Album.create(:artist_name => 'Pink Floyd', :name => 'Wish you were here', :release_date => Time.utc(1975))

    @have_a_cigar = Test::Song.create(:artist_name => 'Pink Floyd', :album_name => 'Wish you were here', :name => 'Have a cigar')

  end

  it "report correct size of one to many relation" do
    a = Test::Artist.where(:name => 'Beatles').first
    a.albums.size.should == 3
  end

  it "one to many relation collection should support exists? method" do
    a = Test::Artist.where(:name => 'Beatles').first
    a.albums.exists?(:name => 'Help').should == true
  end

  it "one to many relation collection should support clear method" do
    a = Test::Artist.where(:name => 'Beatles').first
    a.albums.size.should == 3
    a.albums.clear
    a.albums.size.should == 0
  end

  it "one to many relation collection should support find method" do
    a = Test::Artist.where(:name => 'Beatles').first
    a.albums.find(:name => 'Help').should == @help
  end

  it "one to one relation" do
    @have_a_cigar.album.should == Test::Album.where(:artist_name => 'Pink Floyd', :name => 'Wish you were here').first
  end

end