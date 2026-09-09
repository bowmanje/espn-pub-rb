# frozen_string_literal: true

require 'date'

module EspnPub
  module Entities
    # Represents a player on a team.
    class Player < Base
      ATHLETE_PATH = '/apis/common/v3/sports/%s/%s/athletes/%s'

      attr_reader :id,
                  :sport,
                  :league,
                  :first_name,
                  :last_name,
                  :position,
                  :team_id,
                  :date_of_birth,
                  :birth_city,
                  :birth_state,
                  :birth_country,
                  :height,
                  :weight,
                  :debut_year

      # Initialize a Player entity.
      #
      # @param id [String] The player identifier.
      # @param sport [String] The sport name.
      # @param league [String] The league identifier.
      # @param first_name [String, nil] The player's first name.
      # @param last_name [String, nil] The player's last name.
      # @param position [String, nil] The player's position abbreviation.
      # @param team_id [String, nil] The identifier of the player's team.
      # @param date_of_birth [Date, nil] The player's date of birth.
      # @param birth_city [String, nil] The player's birth city.
      # @param birth_state [String, nil] The player's birth state.
      # @param birth_country [String, nil] The player's birth country.
      # @param height [String, nil] The player's listed height.
      # @param weight [String, nil] The player's listed weight.
      # @param debut_year [Integer, nil] The year the player made their debut.
      def initialize(id:, sport:, league:, first_name: nil, last_name: nil, position: nil, team_id: nil,
                     date_of_birth: nil, birth_city: nil, birth_state: nil, birth_country: nil, height: nil, weight: nil, debut_year: nil)
        @id = id
        @sport = sport
        @league = league
        @first_name = first_name
        @last_name = last_name
        @position = position
        @team_id = team_id
        @date_of_birth = self.class.parse_date_of_birth(date_of_birth)
        @birth_city = birth_city
        @birth_state = birth_state
        @birth_country = birth_country
        @height = height
        @weight = weight
        @debut_year = debut_year
        super()
      end

      # Fetch a player by ID from the ESPN common v3 athlete endpoint.
      #
      # @param id [String] The player identifier.
      # @param sport [String] The sport name.
      # @param league [String] The league identifier.
      # @return [Player, nil] The player, or nil when the request fails or data is missing.
      def self.fetch_by_id(id:, sport:, league:)
        client = EspnPub::Client.new
        path = format ATHLETE_PATH, sport, league, id
        begin
          athlete_data = client.send_request(path)['athlete']
        rescue Client::UnexpectedResponseCodeError => e
          warn "Failed to fetch player data for #{id}: #{e.message}"
          return nil
        end

        return nil unless athlete_data

        new(
          id: athlete_data['id'],
          sport: sport,
          league: league,
          first_name: athlete_data['firstName'],
          last_name: athlete_data['lastName'],
          position: athlete_data.dig('position', 'abbreviation'),
          team_id: athlete_data.dig('team', 'id'),
          date_of_birth: parse_date_of_birth(athlete_data['dateOfBirth']),
          birth_city: athlete_data.dig('birthPlace', 'city'),
          birth_state: athlete_data.dig('birthPlace', 'state'),
          birth_country: athlete_data.dig('birthPlace', 'country'),
          height: athlete_data['displayHeight'],
          weight: athlete_data['displayWeight'],
          debut_year: athlete_data['debutYear']
        )
      end

      # Return the player's full name.
      #
      # @return [String] The player's full name.
      def full_name
        @full_name ||= "#{first_name} #{last_name}"
      end

      # @param value [String, Date, nil]
      # @return [Date, nil]
      def self.parse_date_of_birth(value)
        return nil unless value
        return value if value.is_a?(Date)
        return nil unless value.is_a?(String)

        Date.parse(value)
      rescue ArgumentError
        nil
      end
    end
  end
end
