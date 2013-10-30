require 'spec_helper'

describe Believer::Update do

  let :artist do
    Test::Artist.create(:name => 'Beatles', :label => 'Apple')
  end

  it "should create statement based on hash" do
    update = Believer::Update.new(:record_class => artist.class, :values => {:label => 'Apple'}).where(:name => artist.name)
    expect(update.to_cql).to eql "UPDATE artists SET label = '#{artist.label}' WHERE name = '#{artist.name}'"
  end

  it "should create statement based on an object" do
    update = Believer::Update.create(artist)
    expect(update.to_cql).to eql "UPDATE artists SET label = '#{artist.label}' WHERE name = '#{artist.name}'"
  end

  it "should update the values" do
    artist.label = 'Chrysalis'
    Believer::Update.create(artist).execute
    loaded_artist = Test::Artist.where(:name => 'Beatles').first
    expect(loaded_artist.label).to eql('Chrysalis')
  end

end