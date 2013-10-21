module Believer
  module Connection
    extend ::ActiveSupport::Concern

    module ClassMethods

      def reset_connection
        unless connection.nil?
          connection.close
          @client_connection = nil
        end
      end

      def connection
        @client_connection ||= environment.create_connection(:connect_to_keyspace => true)
      end

    end

  end

end