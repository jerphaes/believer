module Believer
  # A command implementation which includes a CQL WHERE clause
  class FilterCommand < Command

    def query_attributes
      attrs = super
      attrs.merge(:wheres => (wheres.dup))
    end

    def wheres
      #puts "Wheres: #{@wheres}"
      @wheres ||= []
    end

    def wheres=(w)
      @wheres = w.is_a?(Array) ? w : [w]
    end

    def where(*args)
      q = clone
      q.wheres << WhereClause.new(*args)
      q
    end

  end
end
