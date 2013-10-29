require 'spec_helper'

describe 'Collection columns' do

  before :each do
    @marbles  = Set.new [:red, :green, :red]
    @soccer_cards  = ['Messi', 'Ronaldo', 'Pele']
    @family  = {:father => 'Fred', :mother => 'Tina', :sister => 'Emily'}
    @children = Test::Child.create(:name => 'Johnny', :marbles => @marbles, :family => @family, :soccer_cards => @soccer_cards)
  end

  it 'should load a set' do
    johnny = Test::Child.where(:name => 'Johnny').first
    expect(johnny.marbles.size).to eql(@marbles.size)
    @marbles.each do |m|
      expect(johnny.marbles).to include(m)
    end
  end

  it 'should be able to add to a set' do
    johnny = Test::Child.where(:name => 'Johnny').first
    johnny.marbles << :yellow
    johnny.save

    johnny = Test::Child.where(:name => 'Johnny').first
    expect(johnny.marbles.size).to eql(@marbles.size + 1)
    expect(johnny.marbles).to include(:yellow)
  end

  it 'should be able to remove from a set' do
    johnny = Test::Child.where(:name => 'Johnny').first
    johnny.marbles.delete(:red)
    johnny.save

    johnny = Test::Child.where(:name => 'Johnny').first
    expect(johnny.marbles.size).to eql(@marbles.size - 1)
    expect(johnny.marbles).not_to include(:red)
  end

  it 'should load a list' do
    johnny = Test::Child.where(:name => 'Johnny').first
    expect(johnny.soccer_cards.size).to eql(@soccer_cards.size)
    @soccer_cards.each do |m|
      expect(johnny.soccer_cards).to include(m)
    end
  end

  it 'should be able to add to a list' do
    johnny = Test::Child.where(:name => 'Johnny').first
    johnny.soccer_cards << 'Neymar'
    johnny.save

    johnny = Test::Child.where(:name => 'Johnny').first
    expect(johnny.soccer_cards.size).to eql(@soccer_cards.size + 1)
    expect(johnny.soccer_cards).to include('Neymar')
  end

  it 'should be able to remove from a set' do
    johnny = Test::Child.where(:name => 'Johnny').first
    johnny.soccer_cards.delete('Messi')
    johnny.save

    johnny = Test::Child.where(:name => 'Johnny').first
    expect(johnny.soccer_cards.size).to eql(@soccer_cards.size - 1)
    expect(johnny.soccer_cards).not_to include('Messi')
  end

  it 'should load a map' do
    johnny = Test::Child.where(:name => 'Johnny').first
    expect(johnny.family.size).to eql(@family.size)
    @family.each do |k, v|
      expect(johnny.family.keys).to include(k)
      expect(johnny.family[k]).to eql(v)
    end
  end

  it 'should be able to add to a map' do
    johnny = Test::Child.where(:name => 'Johnny').first
    johnny.family[:brother] = 'Brad'
    johnny.save

    johnny = Test::Child.where(:name => 'Johnny').first
    expect(johnny.family[:brother]).to eql('Brad')
  end

  it 'should be able to remove from a map' do
    johnny = Test::Child.where(:name => 'Johnny').first
    johnny.family.delete(:sister)
    johnny.save

    johnny = Test::Child.where(:name => 'Johnny').first
    expect(johnny.family.has_key?(:sister)).to eql(false)
  end

end