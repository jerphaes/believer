require 'spec_helper'

describe Believer::Counting do

  it 'should detect a counter table' do
    expect(Test::Artist.is_counter_table?).to eql false
    expect(Test::AlbumSales.is_counter_table?).to eql true
  end

  it 'should detect a changed counter instance' do
    album_sales = Test::AlbumSales.new
    expect(album_sales.has_counter_diffs?).to eql false
    album_sales.sales.incr
    expect(album_sales.has_counter_diffs?).to eql true
  end

  it 'should be able to set a counter using a number' do
    album_sales = Test::AlbumSales.new
    album_sales.sales = 2
    expect(album_sales.sales.to_i).to eql 2
  end

  it 'should be able to undo changes in a counter' do
    album_sales = Test::AlbumSales.new
    album_sales.sales.incr
    expect(album_sales.has_counter_diffs?).to eql true
    album_sales.sales.undo_changes!
    expect(album_sales.has_counter_diffs?).to eql false
  end

  it 'should be able to reset a counter' do
    album_attrs = {:artist_name => 'CSNY', :name => 'Deja vu'}
    album_sales = Test::AlbumSales.new(album_attrs)
    album_sales.sales.incr(4)
    expect(album_sales.has_counter_diffs?).to eql true
    album_sales.save

    album_sales = Test::AlbumSales.where(album_attrs).first
    expect(album_sales.sales.value).to eql 4
    album_sales.sales.reset!
    album_sales.save

    album_sales = Test::AlbumSales.where(album_attrs).first
    expect(album_sales.sales.value).to eql 0
  end

  it 'should be able to persist a counter value' do
    album_sales = Test::AlbumSales.new(:artist_name => 'CSNY', :name => 'Deja vu')
    album_sales.sales.incr
    album_sales.save
    expect(album_sales.sales.value).to eql 1

    album_sales = Test::AlbumSales.where(:artist_name => 'CSNY', :name => 'Deja vu').first
    album_sales.sales.incr
    album_sales.save

    album_sales = Test::AlbumSales.where(:artist_name => 'CSNY', :name => 'Deja vu').first
    expect(album_sales.sales.value).to eql 2
  end

end