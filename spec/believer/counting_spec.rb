require 'spec_helper'

describe Believer::Counting do

  it 'should detect a counter table' do
    expect(Test::Artist.is_counter_table?).to eql false
    expect(Test::AlbumStatistics.is_counter_table?).to eql true
  end

  it 'should detect a changed counter instance' do
    album_sales = Test::AlbumStatistics.new
    expect(album_sales.has_counter_diffs?).to eql false
    album_sales.sold.incr
    expect(album_sales.has_counter_diffs?).to eql true
  end

  it 'should be able to set a counter using a number' do
    album_sales = Test::AlbumStatistics.new
    album_sales.sold = 2
    expect(album_sales.sold.to_i).to eql 2
  end

  it 'should be able to undo changes in a counter' do
    album_sales = Test::AlbumStatistics.new
    album_sales.sold.incr
    expect(album_sales.has_counter_diffs?).to eql true
    album_sales.sold.undo_changes!
    expect(album_sales.has_counter_diffs?).to eql false
  end

  it 'should be able to reset a counter' do
    album_attrs = {:artist_name => 'CSNY', :name => 'Deja vu'}
    album_sales = Test::AlbumStatistics.new(album_attrs)
    album_sales.sold.incr(4)
    expect(album_sales.has_counter_diffs?).to eql true
    album_sales.save

    album_sales = Test::AlbumStatistics.where(album_attrs).first
    expect(album_sales.sold.value).to eql 4
    album_sales.sold.reset!
    album_sales.save

    album_sales = Test::AlbumStatistics.where(album_attrs).first
    expect(album_sales.sold.value).to eql 0
  end

  it 'should be able to reset all counters in one go' do
    album_attrs = {:artist_name => 'CSNY', :name => 'Deja vu'}
    album_sales = Test::AlbumStatistics.new(album_attrs)
    album_sales.sold.incr(4)
    album_sales.produced.incr(7)
    expect(album_sales.has_counter_diffs?).to eql true
    album_sales.save

    album_sales = Test::AlbumStatistics.where(album_attrs).first
    expect(album_sales.sold.value).to eql 4
    expect(album_sales.produced.value).to eql 7
    album_sales.reset_counters!

    album_sales = Test::AlbumStatistics.where(album_attrs).first
    expect(album_sales.sold.value).to eql 0
    expect(album_sales.produced.value).to eql 0
  end

  it 'should be able to persist a counter value' do
    album_sales = Test::AlbumStatistics.new(:artist_name => 'CSNY', :name => 'Deja vu')
    album_sales.sold.incr
    album_sales.save
    expect(album_sales.sold.value).to eql 1

    album_sales = Test::AlbumStatistics.where(:artist_name => 'CSNY', :name => 'Deja vu').first
    album_sales.sold.incr
    album_sales.save

    album_sales = Test::AlbumStatistics.where(:artist_name => 'CSNY', :name => 'Deja vu').first
    expect(album_sales.sold.value).to eql 2
  end

end