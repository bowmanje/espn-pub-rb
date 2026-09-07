# frozen_string_literal: true

require 'date'

module EspnPub
  module Entities
    # Represents a sports league, eg. NBA, NFL, etc.
    class League < Base
      # Supported league names.
      module NAME
        NBA = 'nba'
        NFL = 'nfl'
      end

      TEAMS_PATH = '/apis/site/%s/sports/%s/%s/teams'
      GAMES_PATH = '/apis/site/%s/sports/%s/%s/scoreboard'

      NAME_TO_SPORT = {
        'nba' => 'basketball',
        'nfl' => 'football'
      }.freeze

      attr_reader :name

      # Initialize a League instance.
      #
      # @param name [String] The league identifier string.
      def initialize(name)
        @name = name
        super()
      end

      # Fetch the teams for this league.
      #
      # @return [Array<EspnPub::Entities::Team>]
      def teams
        unless defined?(@teams)
          begin
            path = format TEAMS_PATH, client.version, sport, name
            teams_resp = client.send_request(path)
            @teams = (teams_resp.dig('sports', 0, 'leagues', 0, 'teams') || []).map do |team_data|
              EspnPub::Entities::Team.new(
                id: team_data.dig('team', 'id'),
                name: team_data.dig('team', 'name'),
                location: team_data.dig('team', 'location'),
                abbreviation: team_data.dig('team', 'abbreviation'),
                sport: sport,
                league: name
              )
            end
          rescue Client::UnexpectedResponseCodeError => e
            warn "Failed to fetch teams for league #{name}: #{e.message}"
            return []
          end
        end

        @teams
      end

      # Fetch games for this league.
      #
      # @param date [Date, DateTime, nil] An optional date to filter games.
      # @return [Array<EspnPub::Entities::Game>]
      def games(date: nil)
        path = format GAMES_PATH, client.version, sport, name
        path += "?dates=#{date.strftime('%Y%m%d')}" if date
        games_resp = client.send_request(path)
        (games_resp['events'] || []).map do |game_data|
          EspnPub::Entities::Game.new(
            id: game_data['id'],
            home_team: EspnPub::Entities::Team.fetch_by_id(
              id: game_data.dig('competitions', 0, 'competitors', 0, 'id'),
              sport: sport,
              league: name
            ),
            away_team: EspnPub::Entities::Team.fetch_by_id(
              id: game_data.dig('competitions', 0, 'competitors', 1, 'id'),
              sport: sport,
              league: name
            ),
            date: DateTime.parse(game_data['date'])
          )
        end
      rescue Client::UnexpectedResponseCodeError => e
        warn "Failed to fetch games for league #{name}: #{e.message}"
        []
      end

      # Return the sport name for this league.
      #
      # @return [String, nil] The sport name or nil when unknown.
      def sport
        NAME_TO_SPORT[name]
      end
    end
  end
end
