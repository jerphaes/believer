module Believer
  module Querying
    delegate :select, :where, :order, :limit, :exists?, :count, :pluck, :to => :scoped

  end
end
