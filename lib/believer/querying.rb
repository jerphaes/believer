module Believer
  module Querying
    delegate :select, :where, :order, :limit, :to => :scoped

  end
end
