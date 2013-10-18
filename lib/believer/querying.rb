module Believer
  module Querying
    delegate :select, :where, :order, :to => :scoped

  end
end
