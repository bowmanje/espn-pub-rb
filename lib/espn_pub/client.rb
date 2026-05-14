# frozen_string_literal: true

require 'net/http'
require 'json'

module EspnPub
  # Client for making requests to the ESPN public API.
  class Client
    # Raised when the API returns an unexpected HTTP response code.
    class UnexpectedResponseCodeError < StandardError; end

    BASE_URI = 'https://site.api.espn.com/'
    API_VERSION = 'v2'

    attr_reader :uri, :version

    # Initialize a new Client.
    #
    # @param base_uri [String] The base URI for ESPN API requests.
    # @param version [String] The API version string.
    def initialize(base_uri:, version:)
      @uri = get_uri(base_uri)
      @version = version
    end

    # Send a GET request to the specified API path.
    #
    # @param path [String] The request path to fetch from ESPN.
    # @return [Hash] The parsed JSON response.
    # @raise [UnexpectedResponseCodeError] if the response status is not 200.
    def send_request(path)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request_get path
      end

      raise UnexpectedResponseCodeError, "Unexpected response code: #{response.code}" unless response.code.to_i == 200

      JSON.parse response.body
    end

    private

    # Parse a string into a URI object.
    #
    # @param uri [String] The URI string to parse.
    # @return [URI]
    def get_uri(uri)
      URI uri
    end
  end
end
