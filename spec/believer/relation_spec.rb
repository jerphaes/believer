require 'spec_helper'

describe Believer::Relation do

  before :each do
    @artists = []
    @artists << Test::Artist.create(:name => 'Beatles', :label => 'Apple')
    @artists << Test::Artist.create(:name => 'Jethro Tull', :label => 'Crysalis')
    @artists << Test::Artist.create(:name => 'Pink Floyd', :label => 'Epic')

    @albums = []
    @albums << Test::Album.create(:artist_name => 'Beatles', :name => 'Help', :release_date => Time.utc(1965))
    @albums << Test::Album.create(:artist_name => 'Beatles', :name => 'Revolver', :release_date => Time.utc(1966))
    @albums << Test::Album.create(:artist_name => 'Beatles', :name => 'Abbey Road', :release_date => Time.utc(1969))

    @albums << Test::Album.create(:artist_name => 'Pink Floyd', :name => 'Dark side of the moon', :release_date => Time.utc(1973))
    @albums << Test::Album.create(:artist_name => 'Pink Floyd', :name => 'Wish you were here', :release_date => Time.utc(1975))

    @songs = []
    @songs << Test::Song.create(:artist_name => 'Pink Floyd', :album_name => 'Wish you were here', :name => 'Have a cigar')

  end

  it "report correct size of one to many relation" do
    a = Test::Artist.where(:name => 'Beatles').first
    a.albums.size.should == 3
  end

  it "one to one relation" do
    @songs[0].album.should == Test::Album.where(:artist_name => 'Pink Floyd', :name => 'Wish you were here').first
  end

end