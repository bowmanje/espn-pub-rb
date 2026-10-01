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

      attr_reader :id, :home_team, :away_team, :date, :type, :venue, :league

      # Initialize a Game entity.
      #
      # @param id [String] The game identifier.
      # @param home_team [EspnPub::Entities::Team] The home team.
      # @param away_team [EspnPub::Entities::Team] The away team.
      # @param date [DateTime] The scheduled game date.
      # @param type [String] The type of the game.
      # @param venue [EspnPub::Entities::Venue] The venue of the game.
      # @param minutes [Integer] The length of the game in minutes.
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

      def player_game_stats
        unless defined?(@player_game_stats)
          teams = game_summary_response&.dig('boxscore', 'players')
          @player_game_stats = []

          return @player_game_stats unless teams

          teams.each do |team_data|
            team = [home_team, away_team].find { |team| team.id == team_data['team']['id'] }
            stats_keys = team_data['statistics'][0]['names']

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
              @player_game_stats << EspnPub::Entities::PlayerGameStat.new(
                player: player, team: team, stats_data: stats_data
              )
            end
          end
        end

        @player_game_stats
      end

      def team_game_stats
        unless defined?(@team_game_stats)
          teams = game_summary_response&.dig('boxscore', 'teams')
          @team_game_stats = []

          return @team_game_stats unless teams

          teams.each do |team_data|
            team = [home_team, away_team].find { |team| team.id == team_data['team']['id'] }
            stats_data = {}
            team_data['statistics'].each_with_object(stats_data) do |stat, memo|
              next memo unless labels.include?(stat['label'])

              memo[stat['label']] = stat['displayValue']
            end
            @team_game_stats << EspnPub::Entities::TeamGameStat.new(
              team: team, stats_data: stats_data
            )
          end
        end
        @team_game_stats
      end

      def minutes
        unless defined?(@minutes)
          @minutes = 48
          periods = game_summary_response&.dig('header', 'competitions', 0, 'competitors', 0, 'linescores')
          @minutes += (periods.count - 4) * 5 if periods
        end
        @minutes
      end

      def labels
        ['FG', '3PT', 'FT', 'Rebounds', 'Offensive Rebounds', 'Defensive Rebounds', 'Assists', 'Steals', 'Blocks',
         'Turnovers']
      end

      def game_summary_response
        unless defined?(@game_summary_response)
          begin
            path = format SUMMARY_PATH, EspnPub::Client::API_VERSION, league.sport, league.league_name, id
            @game_summary_response = EspnPub::Client.new.send_request(path)
          rescue Client::UnexpectedResponseCodeError => e
            warn "Failed to fetch game summary for #{id}: #{e.message}"
            return nil
          end
        end
        @game_summary_response
      end
    end
  end
end
