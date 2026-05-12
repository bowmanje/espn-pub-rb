# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a player on a team
    class Player < Base
      attr_reader :id,
                  :sport,
                  :league,
                  :first_name,
                  :last_name,
                  :position,
                  :team_id

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

      def full_name
        @full_name ||= first_name + ' ' + last_name
      end
    end
  end
end