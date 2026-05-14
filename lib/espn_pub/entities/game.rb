# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a game between two teams.
    class Game < Base
      attr_reader :id, :home_team_id, :away_team_id, :date

      # Initialize a Game entity.
      #
      # @param id [String] The game identifier.
      # @param home_team_id [String] The home team identifier.
      # @param away_team_id [String] The away team identifier.
      # @param date [DateTime] The scheduled game date.
      def initialize(id:, home_team_id:, away_team_id:, date:)
        @id = id
        @home_team_id = home_team_id
        @away_team_id = away_team_id
        @date = date
        super()
      end
    end
  end
end