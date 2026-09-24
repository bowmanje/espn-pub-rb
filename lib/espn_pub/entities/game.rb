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

      SUMMARY_PATH = '/apis/site/%s/sports/%s/%s/summary?event=%s'

      GAME_TYPES = {
        1 => Type::PRESEASON,
        2 => Type::REGULAR,
        3 => Type::POSTSEASON
      }.freeze

      attr_reader :id, :home_team, :away_team, :date, :type, :venue, :league, :game_stats

      # Initialize a Game entity.
      #
      # @param id [String] The game identifier.
      # @param home_team [EspnPub::Entities::Team] The home team.
      # @param away_team [EspnPub::Entities::Team] The away team.
      # @param date [DateTime] The scheduled game date.
      # @param type [String] The type of the game.
      # @param venue [EspnPub::Entities::Venue] The venue of the game.
      def initialize(id:, league:, home_team:, away_team:, date:, type: nil, venue: nil)
        @id = id
        @league = league
        @home_team = home_team
        @away_team = away_team
        @date = date
        @type = type
        @venue = venue
        super()
      end

      def game_stats
        unless defined?(@game_stats)
          begin
            path = format SUMMARY_PATH, EspnPub::Client::API_VERSION, league.sport, league.league_name, id
            response = EspnPub::Client.new.send_request(path)
            teams = response.dig('boxscore', 'players')
            @game_stats = []

            return @game_stats unless teams

            teams.each do |team_data|
              team = [home_team, away_team].find { |team| team.id == team_data['team']['id'] }
              stats_keys = team_data['statistics'][0].dig('names')

              team_data['statistics'][0]['athletes'].each do |athlete|
                player = EspnPub::Entities::Player.new(
                  id: athlete['athlete']['id'],
                  sport: league.sport,
                  league_name: league.league_name
                )
                stats_data = {}
                stats_keys.each_with_index do |key, index|
                  stats_data[key] = athlete['stats'][index]
                end
                @game_stats << EspnPub::Entities::GameStat.new(
                  player: player, team: team, stats_data: stats_data
                )
              end
            end
          rescue Client::UnexpectedResponseCodeError => e
            warn "Failed to fetch game stats for #{id}: #{e.message}"
            return []
          end
        end

        @game_stats
      end
    end
  end
end
