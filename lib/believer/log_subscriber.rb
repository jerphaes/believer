module Believer

  class LogSubscriber < ActiveSupport::LogSubscriber

    def initialize
      super
      @odd_or_even = false
    end

    def ddl(event)
      return unless logger.debug?

      payload = event.payload

      name  = '%s (%.1fms) [CQL]' % [payload[:class].to_s, event.duration]
      name = color(name, MAGENTA, true)
      cql   = color(payload[:cql].squeeze(' '), BLACK, true)

      debug "  #{name} #{payload[:method]} table:\n#{cql}"
    end

    def deserialize(event)
      return unless logger.debug?

      payload = event.payload

      name  = '%s (%.1fms)' % [payload[:class].to_s, event.duration]
      name = color(name, RED, true)

      debug "  #{name} deserialized #{payload[:count]} objects"
    end

    def cql(event)
      return unless logger.debug?

      payload = event.payload

      return if 'SCHEMA' == payload[:name]

      name  = '%s (%.1fms) [CQL]' % [payload[:name], event.duration]
      cql   = payload[:cql].squeeze(' ')

      if odd?
        name = color(name, GREEN, true)
        cql  = color(cql, nil, true)
      else
        name = color(name, CYAN, true)
      end

      debug "  #{name} #{cql}"
    end

    def logger
      Believer::Base.logger
    end

    private
    def odd?
      @odd_or_even = !@odd_or_even
    end

  end
end

Believer::LogSubscriber.attach_to :believer
