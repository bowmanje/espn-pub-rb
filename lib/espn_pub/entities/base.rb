# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a sports league, eg. NBA, NFL, etc.
    class Base
      attr_reader :client

      def initialize
        @client = init_client
      end

      def init_client
        EspnPub::Client.new(
          base_uri: Client::BASE_URI,
          version: Client::API_VERSION,
        )
      end
    end
  end
end