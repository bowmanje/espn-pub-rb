# frozen_string_literal: true

module EspnPub
  module Entities
    class PlayerGameStat < Base
      attr_reader :player, :team, :stats_data

      def initialize(player:, team:, stats_data: {})
        @player = player
        @team = team
        @stats_data = stats_data
        super()
      end
    end
  end
end
