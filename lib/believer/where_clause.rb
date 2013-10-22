module Believer

  class WhereClause
    include CqlHelper

    def initialize(*args)
      if args.any?
        if args[0].is_a?(Hash)
          @value_map = args[0]
        else
          @where_string = args[0]
          @bindings = args.slice(1, args.length - 1)
        end
      end
    end

    def to_cql
      if @value_map && @value_map.any?
        return @value_map.keys.map {|k| create_expression(k, @value_map[k])}.join(' AND ')
      end
      binding_index = 0
      ws = @where_string.gsub(/\?/) { |match|
        rep_val = to_cql_literal(@bindings[binding_index])
        binding_index += 1
        rep_val
      }
      ws
    end

    private
    def create_expression(key, value)
      if value.is_a?(Enumerable)
        values = value.map {|v| to_cql_literal(v)}.join(',')
        return "#{key} IN (#{values})"
      end
      "#{key} = #{to_cql_literal(value)}"
    end
  end

end
