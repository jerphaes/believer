require 'spec_helper'

describe Believer::Update do

  let :artist do
    Test::Artist.create(:name => 'Beatles', :label => 'Apple')
  end

  let :album_statistics do
    Test::AlbumStatistics.create(:artist_name => 'Beatles', :name => 'Revolver')
  end

  it "should create statement based on hash" do
    update = Believer::Update.new(:record_class => artist.class, :values => {:label => 'Apple'}).where(:name => artist.name)
    expect(update.to_cql).to eql "UPDATE artists SET label = '#{artist.label}' WHERE name = '#{artist.name}'"
  end

  it "should create statement based on an object" do
    update = Believer::Update.create(artist)
    expect(update.to_cql).to eql "UPDATE artists SET label = '#{artist.label}' WHERE name = '#{artist.name}'"
  end

  it "should create create a correct statement for a counter increment" do
    album_statistics.sold.incr(2)
    update = Believer::Update.create(album_statistics)
    expect(update.to_cql).to eql "UPDATE album_statistics SET sold = sold + 2 WHERE artist_name = '#{album_statistics.artist_name}' AND name = '#{album_statistics.name}'"
  end

  it "should create create a correct statement for a counter decrement" do
    album_statistics.sold.decr(2)
    update = Believer::Update.create(album_statistics)
    expect(update.to_cql).to eql "UPDATE album_statistics SET sold = sold - 2 WHERE artist_name = '#{album_statistics.artist_name}' AND name = '#{album_statistics.name}'"
  end

  it "should execute a counter change" do
    cur_val = album_statistics.sold.to_i
    album_statistics.sold.incr(2)
    update = Believer::Update.create(album_statistics)
    update.execute
    cur_album_statistics = Test::AlbumStatistics.where(album_statistics.key_values).first
    expect(cur_album_statistics.sold.to_i).to eql (cur_val + 2)
  end

  it "should not execute if no changes are detected in any counter" do
    cur_val = album_statistics.reload!.sold.to_i
    album_statistics.sold.incr(2)
    album_statistics.sold.decr(2)
    expect(album_statistics.sold.to_i).to eql cur_val
    update = Believer::Update.create(album_statistics)
    expect(update.execute).to eql false

    cur_album_statistics = Test::AlbumStatistics.where(album_statistics.key_values).first
    expect(cur_album_statistics.sold.to_i).to eql cur_val
  end

  it "should update the values" do
    artist.label = 'Chrysalis'
    Believer::Update.create(artist).execute
    loaded_artist = Test::Artist.where(:name => 'Beatles').first
    expect(loaded_artist.label).to eql('Chrysalis')
  end

  it "should update the values" do
    artist.label = 'Chrysalis'
    Believer::Update.create(artist).execute
    loaded_artist = Test::Artist.where(:name => 'Beatles').first
    expect(loaded_artist.label).to eql('Chrysalis')
  end

end