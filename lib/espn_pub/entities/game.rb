# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a game between two teams.
    class Game < Base
      module Type
        PRESEASON = 'preseason'
        REGULAR = 'regular'
        POSTSEASON = 'postseason'
      end

      GAME_TYPES = {
        1 => Type::PRESEASON,
        2 => Type::REGULAR,
        3 => Type::POSTSEASON
      }.freeze

      attr_reader :id, :home_team, :away_team, :date, :type, :venue

      # Initialize a Game entity.
      #
      # @param id [String] The game identifier.
      # @param home_team [EspnPub::Entities::Team] The home team.
      # @param away_team [EspnPub::Entities::Team] The away team.
      # @param date [DateTime] The scheduled game date.
      # @param type [String] The type of the game.
      # @param venue [EspnPub::Entities::Venue] The venue of the game.
      def initialize(id:, home_team:, away_team:, date:, type: nil, venue: nil)
        @id = id
        @home_team = home_team
        @away_team = away_team
        @date = date
        @type = type
        @venue = venue
        super()
      end
    end
  end
end
