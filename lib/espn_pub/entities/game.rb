# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a game between two teams.
    class Game < Base
      attr_reader :id, :home_team, :away_team, :date

      # Initialize a Game entity.
      #
      # @param id [String] The game identifier.
      # @param home_team [EspnPub::Entities::Team] The home team.
      # @param away_team [EspnPub::Entities::Team] The away team.
      # @param date [DateTime] The scheduled game date.
      def initialize(id:, home_team:, away_team:, date:)
        @id = id
        @home_team = home_team
        @away_team = away_team
        @date = date
        super()
      end
    end
  end
end
