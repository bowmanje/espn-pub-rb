# frozen_string_literal: true

require 'net/http'

module EspnPub
  # Client for making requests to the ESPN public API.
  class Client
    class NotExpectedResponseCodeError < StandardError; end

    BASE_URI = 'https://site.api.espn.com/'
    API_VERSION = 'v2'

    attr_reader :uri, :version, :league

    def initialize(base_uri:, version:, league:)
      @uri = get_uri(base_uri)
      @version = version
      @league = league
    end

    def send_request(path)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request_get path
      end

      raise NotExpectedResponseCodeError, "Unexpected response code: #{response.code}" unless response.code.to_i == 200

      JSON.parse response.body
    end

    private

    def get_uri(uri)
      URI uri
    end
  end
end
