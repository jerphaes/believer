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

  it 'should be able to reset a counter' do
    album_sales = Test::AlbumSales.new
    album_sales.sales.incr
    expect(album_sales.has_counter_diffs?).to eql true
    album_sales.sales.reset!
    expect(album_sales.has_counter_diffs?).to eql false
  end

end