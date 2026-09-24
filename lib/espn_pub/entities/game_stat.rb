module EspnPub
  module Entities
    class GameStat < Base

      attr_reader :player, :team, :stats_data

      def initialize(player:, team:, stats_data: {})
        @player = player
        @team = team
        @stats_data = stats_data
      end
    end
  end
end