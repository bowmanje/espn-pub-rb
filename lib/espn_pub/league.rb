# frozen_string_literal: true

module EspnPub
  # Represents a sports league, eg. NBA, NFL, etc.
  class League
    # Supported league names
    module NAME
      NBA = 'nba'
      NFL = 'nfl'
    end

    TEAMS_PATH = '/apis/site/%s/sports/%s/%s/teams'

    NAME_TO_SPORT = {
      'nba' => 'basketball',
      'nfl' => 'football'
    }.freeze

    attr_reader :name, :client

    def initialize(name)
      @name = name
      @client = init_client
    end

    def teams
      unless defined?(@teams)
        path = format TEAMS_PATH, client.version, NAME_TO_SPORT[name], name
        teams_resp = client.send_request(path)
        @teams = teams_resp.dig('sports', 0, 'leagues', 0, 'teams')
      end

      @teams
    end

    private

    def init_client
      EspnPub::Client.new(
        base_uri: Client::BASE_URI,
        version: Client::API_VERSION,
        league: name
      )
    end
  end
end
