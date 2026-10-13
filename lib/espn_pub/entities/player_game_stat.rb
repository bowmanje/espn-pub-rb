# frozen_string_literal: true

module EspnPub
  module Entities
    class PlayerGameStat < Base
      attr_reader :player, :team, :stats_data, :starter

      def initialize(player:, team:, stats_data: {}, starter: false)
        @player = player
        @team = team
        @stats_data = stats_data
        @starter = starter
        super()
      end
    end
  end
end
