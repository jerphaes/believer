module Believer
  module FinderMethods

    # Tests if there are any records present which conform to the argument filter(s)
    # @param args [Object] a filter condition. This argument has the same usage as the where method
    #def exists?(*args)
    #  super if defined?(super) && args.size == 0
    #  where(*args).exists?
    #end

    def find(*args)
      return where(args[0]).first if args[0].is_a?(Hash)

      if primary_key_columns.size == 1
        return where(primary_key_columns[0] => args).to_a if args.is_a?(Array) && args.size > 1
        return where(primary_key_columns[0] => args[0]).first
      end

      nil
    end

  end
end
