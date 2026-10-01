# frozen_string_literal: true

module EspnPub
  module Entities
    class TeamGameStat < Base
      attr_reader :team, :stats_data

      def initialize(team:, stats_data: {})
        @team = team
        @stats_data = stats_data
        super()
      end
    end
  end
end
