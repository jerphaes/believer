require 'spec_helper'

describe Believer::Query, 'Acting as Enumerable' do

  [:first, :last, :any?, :exists?, :count].each do |method|
    it "should not execute a query after the initial load in the #{method} method" do
      query = Believer::Query.new(:record_class => Test::Album).where(:artist_name => 'Jethro Tull').order(:name)
      expect(query).to receive(:execute).once.and_return([])
      query.to_a
      query.send(method)
      query.send(method)
    end
  end

  [:first, :last, :any?, :exists?, :count].each do |method|
    it "should delegate query to a cloned query instance for the #{method} method" do
      query = Believer::Query.new(:record_class => Test::Album).where(:artist_name => 'Jethro Tull').order(:name)
      expect(query).not_to receive(:execute)
      query.send(method)
    end
  end

end