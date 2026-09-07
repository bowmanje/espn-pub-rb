# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a sports team, eg. Miami Heat, New England Patriots, etc.
    class Team < Base
      TEAM_PATH = '/apis/site/%s/sports/%s/%s/teams/%s'
      ROSTER_PATH = '/apis/site/%s/sports/%s/%s/teams/%s/roster'

      attr_reader :id,
                  :name,
                  :location,
                  :abbreviation,
                  :sport,
                  :league,
                  :venue

      # Initialize a Team entity.
      #
      # @param id [String] The team identifier.
      # @param name [String] The team name.
      # @param location [String] The team location.
      # @param abbreviation [String] The team abbreviation.
      # @param sport [String] The sport name.
      # @param league [String] The league identifier.
      # @param venue [EspnPub::Entities::Venue, nil] The team's home venue.
      def initialize(id:, name:, location:, abbreviation:, sport:, league:, venue: nil)
        @id = id
        @name = name
        @location = location
        @abbreviation = abbreviation
        @sport = sport
        @league = league
        @venue = venue
        super()
      end

      def self.fetch_by_id(id:, sport:, league:)
        client = EspnPub::Client.new
        path = format TEAM_PATH, client.version, sport, league, id
        begin
          team_data = client.send_request(path)['team']
        rescue Client::UnexpectedResponseCodeError => e
          warn "Failed to fetch team data for #{id}: #{e.message}"
          return nil
        end

        return nil unless team_data

        new(
          id: team_data['id'],
          name: team_data['name'],
          location: team_data['location'],
          abbreviation: team_data['abbreviation'],
          sport: sport,
          league: league,
          venue: EspnPub::Entities::Venue.from_api(team_data.dig('franchise', 'venue'))
        )
      end

      # Fetch the roster for this team.
      #
      # @return [Array<EspnPub::Entities::Player>]
      def players
        unless defined?(@roster)
          begin
            path = format ROSTER_PATH, client.version, sport, league, id
            roster_resp = client.send_request(path)
            @roster = (roster_resp['athletes'] || []).map do |athlete_data|
              EspnPub::Entities::Player.new(
                id: athlete_data['id'],
                sport: sport,
                league: league,
                first_name: athlete_data['firstName'],
                last_name: athlete_data['lastName'],
                position: athlete_data['position']['abbreviation'],
                team_id: id,
                birthCity: athlete_data.dig('birthPlace', 'city'),
                birthState: athlete_data.dig('birthPlace', 'state'),
                birthCountry: athlete_data.dig('birthPlace', 'country'),
                date_of_birth: athlete_data['dateOfBirth'],
                height: athlete_data['height'],
                weight: athlete_data['weight'],
                debut_year: athlete_data['debutYear']
              )
            end
          rescue Client::UnexpectedResponseCodeError => e
            warn "Failed to fetch roster for team #{name} (#{id}): #{e.message}"
            return []
          end
        end

        @roster
      end

      # Return the team's full name.
      #
      # @return [String] The team's full name.
      def full_name
        @full_name ||= "#{location} #{name}"
      end
    end
  end
end
