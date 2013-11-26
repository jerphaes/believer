require 'spec_helper'

describe Believer::Updating do

  it "should update all" do
    Test::Album.create(
        [
            {:artist_name => 'Beatles', :name => 'Help', :release_date => Time.utc(1965)},
            {:artist_name => 'Jethro Tull', :name => 'Aqualung', :release_date => Time.utc(1971)},
            {:artist_name => 'Jethro Tull', :name => 'Standup', :release_date => Time.utc(1969)},
            {:artist_name => 'Michael Jackson', :name => 'Thriller', :release_date => Time.utc(1982)}
        ])

    Test::Album.where(:artist_name => 'Jethro Tull').update_all(:release_date => Time.utc(2000))
    albums = Test::Album.where(:artist_name => 'Jethro Tull').to_a
    albums.each do |album|
      expect(album.release_date).to eql(Time.utc(2000))
    end

    help = Test::Album.where(:artist_name => 'Beatles', :name => 'Help').first
    expect(help.release_date).to eql(Time.utc(1965))
  end

end