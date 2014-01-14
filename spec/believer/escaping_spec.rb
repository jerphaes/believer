require 'spec_helper'

describe 'String escaping' do

  it 'should escape string literals in queries' do
    q = Believer::Query.new(:record_class => Test::Album)
    q = q.select(:name).where(:name => "'quote!")
    expect(q.to_cql).to eql "SELECT name FROM albums WHERE name = '''quote!'"
  end

  it 'should escape string literals in updates' do
    q = Believer::Update.create(Test::Artist.new(:name => "'name'", :label => "'label'"))
    expect(q.to_cql).to eql "UPDATE artists SET label = '''label''' WHERE name = '''name'''"
  end

  it 'should escape string literals in inserts' do
    q = Believer::Insert.new(:record_class => Test::Artist)
    q.values = {:name => "'name'", :label => "'label'"}

    expect(q.to_cql).to eql "INSERT INTO artists (name, label) VALUES ('''name''', '''label''')"
  end

  it 'should escape string literals in delete' do
    q = Believer::Delete.new(:record_class => Test::Artist).where(:name => "'name'")

    expect(q.to_cql).to eql "DELETE FROM artists WHERE name = '''name'''"
  end

end
