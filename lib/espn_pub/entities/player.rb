# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a player on a team.
    class Player < Base
      attr_reader :id,
                  :sport,
                  :league,
                  :first_name,
                  :last_name,
                  :position,
                  :team_id

      # Initialize a Player entity.
      #
      # @param id [String] The player identifier.
      # @param sport [String] The sport name.
      # @param league [String] The league identifier.
      # @param first_name [String, nil] The player's first name.
      # @param last_name [String, nil] The player's last name.
      # @param position [String, nil] The player's position abbreviation.
      # @param team_id [String, nil] The identifier of the player's team.
      def initialize(id:, sport:, league:, first_name: nil, last_name: nil, position: nil, team_id: nil)
        @id = id
        @sport = sport
        @league = league
        @first_name = first_name
        @last_name = last_name
        @position = position
        @team_id = team_id
        super()
      end

      # Return the player's full name.
      #
      # @return [String] The player's full name.
      def full_name
        @full_name ||= "#{first_name} #{last_name}"
      end
    end
  end
end