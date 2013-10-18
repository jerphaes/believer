module Believer
  class ScopedCommand < Command

    attr_accessor :wheres

    def query_attributes
      attrs = super
      attrs.merge(:wheres => @wheres)
    end

    def where(*args)
      q = clone
      q.wheres ||= []
      q.wheres << WhereClause.new(*args)
      q
    end

  end
end
