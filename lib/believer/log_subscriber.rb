module Believer

  class LogSubscriber < ActiveSupport::LogSubscriber
    #def self.runtime=(value)
    #  Thread.current["active_record_sql_runtime"] = value
    #end
    #
    #def self.runtime
    #  Thread.current["active_record_sql_runtime"] ||= 0
    #end
    #
    #def self.reset_runtime
    #  rt, self.runtime = runtime, 0
    #  rt
    #end

    def initialize
      super
      @odd_or_even = false
    end

    def cql(event)
      #self.class.runtime += event.duration
      return unless logger.debug?

      payload = event.payload

      return if 'SCHEMA' == payload[:name]

      name  = '%s (%.1fms)' % [payload[:name], event.duration]
      cql   = payload[:cql].squeeze(' ')
      binds = nil
      #
      #unless (payload[:binds] || []).empty?
      #  binds = "  " + payload[:binds].map { |col,v|
      #    if col
      #      [col.name, v]
      #    else
      #      [nil, v]
      #    end
      #  }.inspect
      #end

      puts ">>>>> #{cql}"
      if odd?
        name = color(name, GREEN, true)
        cql  = color(cql, nil, true)
      else
        name = color(name, BLUE, true)
      end

      debug "  #{name}  #{cql}#{binds}"
    end

    #def identity(event)
    #  return unless logger.debug?
    #
    #  name = color(event.payload[:name], odd? ? CYAN : MAGENTA, true)
    #  line = odd? ? color(event.payload[:line], nil, true) : event.payload[:line]
    #
    #  debug "  #{name}  #{line}"
    #end

    def odd?
      @odd_or_even = !@odd_or_even
    end

    def logger
      #ActiveRecord::Base.logger
      return Rails.logger if defined? Rails
      @std_logger ||= ::Logger.new(STDOUT)
    end

  end
end

Believer::LogSubscriber.attach_to :believer
