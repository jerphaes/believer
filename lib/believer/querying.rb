module Believer
  module Querying
    delegate :select, :where, :order, :limit, :exists?, :to => :scoped

  end
end
