# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a game between two teams
    class Game < Base
      attr_reader :id, :home_team_id, :away_team_id, :date

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