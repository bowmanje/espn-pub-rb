# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Entities::Game do
  describe '#initialize' do
    subject do
      described_class.new(
        id: game_id,
        home_team: home_team,
        away_team: away_team,
        date: game_date,
        league: league
      )
    end

    let(:game_id) { Faker::Number.unique.number(digits: 10).to_s }
    let(:home_team) { instance_double(EspnPub::Entities::Team) }
    let(:away_team) { instance_double(EspnPub::Entities::Team) }
    let(:league) { instance_double(EspnPub::Entities::League) }
    let(:game_date) { DateTime.now }

    it 'has the correct game_id' do
      expect(subject.id).to eq(game_id)
    end

    it 'has the correct home_team' do
      expect(subject.home_team).to eq(home_team)
    end

    it 'has the correct away_team' do
      expect(subject.away_team).to eq(away_team)
    end

    it 'has the correct date' do
      expect(subject.date).to eq(game_date)
    end

    it 'has a client from Base' do
      expect(subject.client).to be_a(EspnPub::Client)
    end
  end

  describe '#game_stats' do
    subject { game.game_stats }

    let(:game) do
      described_class.new(
        id: game_id,
        home_team: home_team,
        away_team: away_team,
        date: game_date,
        league: league
      )
    end

    let(:game_id) { Faker::Number.unique.number(digits: 10).to_s }
    let(:home_team_id) { Faker::Number.unique.number(digits: 5).to_s }
    let(:away_team_id) { Faker::Number.unique.number(digits: 5).to_s }
    let(:home_player_id) { Faker::Number.unique.number(digits: 7).to_s }
    let(:away_player_id) { Faker::Number.unique.number(digits: 7).to_s }
    let(:home_team) { instance_double(EspnPub::Entities::Team, id: home_team_id) }
    let(:away_team) { instance_double(EspnPub::Entities::Team, id: away_team_id) }
    let(:league) { instance_double(EspnPub::Entities::League, sport: sport, league_name: league_name) }
    let(:league_name) { EspnPub::Entities::League::NAME::NBA }
    let(:sport) { EspnPub::Entities::League::NAME_TO_SPORT[league_name] }
    let(:game_date) { DateTime.now }

    let(:stat_keys) { %w[MIN PTS REB] }
    let(:home_player_stats) { ['32', '28', '7'] }
    let(:away_player_stats) { ['30', '22', '5'] }

    let(:boxscore_players) do
      [
        {
          'team' => { 'id' => home_team_id },
          'statistics' => [
            {
              'names' => stat_keys,
              'athletes' => [
                {
                  'athlete' => { 'id' => home_player_id },
                  'stats' => home_player_stats
                }
              ]
            }
          ]
        },
        {
          'team' => { 'id' => away_team_id },
          'statistics' => [
            {
              'names' => stat_keys,
              'athletes' => [
                {
                  'athlete' => { 'id' => away_player_id },
                  'stats' => away_player_stats
                }
              ]
            }
          ]
        }
      ]
    end

    let(:status) { 200 }
    let(:summary_response) { { 'boxscore' => { 'players' => boxscore_players } } }
    let(:path) { "/apis/site/v2/sports/#{sport}/#{league_name}/summary?event=#{game_id}" }

    before do
      stub_request(:get, "https://site.web.api.espn.com#{path}")
        .to_return(status: status, body: summary_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'sends a request to the ESPN summary path' do
      expect_any_instance_of(EspnPub::Client).to receive(:send_request).with(path).and_return(summary_response)
      subject
    end

    context 'when the request is successful' do
      it 'returns GameStat objects mapped from the boxscore' do
        expect(subject.size).to eq(2)
        expect(subject).to all(be_a(EspnPub::Entities::GameStat))

        home_stat, away_stat = subject

        expect(home_stat.player).to be_a(EspnPub::Entities::Player)
        expect(home_stat.player.id).to eq(home_player_id)
        expect(home_stat.team).to eq(home_team)
        expect(home_stat.stats_data).to eq('MIN' => '32', 'PTS' => '28', 'REB' => '7')

        expect(away_stat.player).to be_a(EspnPub::Entities::Player)
        expect(away_stat.player.id).to eq(away_player_id)
        expect(away_stat.team).to eq(away_team)
        expect(away_stat.stats_data).to eq('MIN' => '30', 'PTS' => '22', 'REB' => '5')
      end

      it 'caches the game stats and issues only one request' do
        first_result = game.game_stats
        second_result = game.game_stats

        expect(a_request(:get, "https://site.web.api.espn.com#{path}")).to have_been_made.once
        expect(first_result).to eq(second_result)
      end

      context 'when the expected response data is missing' do
        let(:summary_response) { {} }

        it { is_expected.to eq([]) }
      end
    end

    context 'when the request is not successful' do
      let(:status) { 500 }
      let(:summary_response) { 'internal_error' }

      it 'logs a warning' do
        expect_any_instance_of(Kernel).to receive(:warn).with(/Failed to fetch game stats for/)
        subject
      end

      it { is_expected.to eq([]) }
    end
  end
end
