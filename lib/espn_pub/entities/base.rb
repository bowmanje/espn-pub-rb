# frozen_string_literal: true

module EspnPub
  module Entities
    # Base entity that holds a shared ESPN API client.
    class Base
      attr_reader :client

      # Initialize the base entity and create the shared client.
      #
      # @return [void]
      def initialize
        @client = init_client
      end

      private
      # Build a new EspnPub::Client for API requests.
      #
      # @return [EspnPub::Client]
      def init_client
        EspnPub::Client.new(
          base_uri: Client::BASE_URI,
          version: Client::API_VERSION,
        )
      end
    end
  end
end