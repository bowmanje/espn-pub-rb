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

  describe '#player_game_stats' do
    subject { game.player_game_stats }

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
    let(:home_player_stats) { %w[32 28 7] }
    let(:away_player_stats) { %w[30 22 5] }
    let(:home_player_starter) { true }
    let(:away_player_starter) { false }
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
                  'stats' => home_player_stats,
                  'starter' => home_player_starter
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
                  'stats' => away_player_stats,
                  'starter' => away_player_starter
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
        expect(subject).to all(be_a(EspnPub::Entities::PlayerGameStat))

        home_stat, away_stat = subject

        expect(home_stat.player).to be_a(EspnPub::Entities::Player)
        expect(home_stat.player.id).to eq(home_player_id)
        expect(home_stat.team).to eq(home_team)
        expect(home_stat.stats_data).to eq('MIN' => '32', 'PTS' => '28', 'REB' => '7')
        expect(home_stat.starter).to eq(home_player_starter)
        expect(away_stat.player).to be_a(EspnPub::Entities::Player)
        expect(away_stat.player.id).to eq(away_player_id)
        expect(away_stat.team).to eq(away_team)
        expect(away_stat.stats_data).to eq('MIN' => '30', 'PTS' => '22', 'REB' => '5')
        expect(away_stat.starter).to eq(away_player_starter)
      end

      it 'caches the game stats and issues only one request' do
        first_result = game.player_game_stats
        second_result = game.player_game_stats

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
        expect_any_instance_of(Kernel).to receive(:warn).with(/Failed to fetch game summary for/)
        subject
      end

      it { is_expected.to eq([]) }
    end
  end

  describe '#game_summary_response' do
    subject { game.game_summary_response }

    let(:game) do
      described_class.new(
        id: game_id,
        home_team: home_team,
        away_team: away_team,
        date: DateTime.now,
        league: league
      )
    end

    let(:game_id) { Faker::Number.unique.number(digits: 10).to_s }
    let(:home_team) { instance_double(EspnPub::Entities::Team) }
    let(:away_team) { instance_double(EspnPub::Entities::Team) }
    let(:league_name) { EspnPub::Entities::League::NAME::NBA }
    let(:sport) { EspnPub::Entities::League::NAME_TO_SPORT[league_name] }
    let(:league) { instance_double(EspnPub::Entities::League, sport: sport, league_name: league_name) }
    let(:status) { 200 }
    let(:summary_response) { { 'boxscore' => {}, 'header' => {} } }
    let(:path) { "/apis/site/v2/sports/#{sport}/#{league_name}/summary?event=#{game_id}" }

    before do
      stub_request(:get, "https://site.web.api.espn.com#{path}")
        .to_return(status: status, body: summary_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'sends a request to the ESPN summary path' do
      expect_any_instance_of(EspnPub::Client).to receive(:send_request).with(path).and_return(summary_response)
      subject
    end

    it 'returns the summary response' do
      expect(subject).to eq(summary_response)
    end

    it 'caches the response and issues only one request' do
      first_result = game.game_summary_response
      second_result = game.game_summary_response

      expect(a_request(:get, "https://site.web.api.espn.com#{path}")).to have_been_made.once
      expect(first_result).to eq(second_result)
    end

    context 'when the request is not successful' do
      let(:status) { 500 }
      let(:summary_response) { 'internal_error' }

      it 'logs a warning' do
        expect_any_instance_of(Kernel).to receive(:warn).with(/Failed to fetch game summary for/)
        subject
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#minutes' do
    subject { game.minutes }

    let(:game) do
      described_class.new(
        id: game_id,
        home_team: home_team,
        away_team: away_team,
        date: DateTime.now,
        league: league
      )
    end

    let(:game_id) { Faker::Number.unique.number(digits: 10).to_s }
    let(:home_team) { instance_double(EspnPub::Entities::Team) }
    let(:away_team) { instance_double(EspnPub::Entities::Team) }
    let(:league_name) { EspnPub::Entities::League::NAME::NBA }
    let(:sport) { EspnPub::Entities::League::NAME_TO_SPORT[league_name] }
    let(:league) { instance_double(EspnPub::Entities::League, sport: sport, league_name: league_name) }
    let(:status) { 200 }
    let(:linescores) { Array.new(period_count) { {} } }
    let(:period_count) { 4 }
    let(:summary_response) do
      {
        'header' => {
          'competitions' => [
            {
              'competitors' => [
                { 'linescores' => linescores }
              ]
            }
          ]
        }
      }
    end
    let(:path) { "/apis/site/v2/sports/#{sport}/#{league_name}/summary?event=#{game_id}" }

    before do
      stub_request(:get, "https://site.web.api.espn.com#{path}")
        .to_return(status: status, body: summary_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns 48 minutes for a regulation game' do
      expect(subject).to eq(48)
    end

    context 'when the game has overtime periods' do
      let(:period_count) { 6 }

      it 'adds five minutes for each overtime period' do
        expect(subject).to eq(58)
      end
    end

    context 'when period data is missing' do
      let(:summary_response) { {} }

      it 'returns the regulation length' do
        expect(subject).to eq(48)
      end
    end

    it 'caches the minutes and issues only one request' do
      first_result = game.minutes
      second_result = game.minutes

      expect(a_request(:get, "https://site.web.api.espn.com#{path}")).to have_been_made.once
      expect(first_result).to eq(second_result)
    end
  end

  describe '#team_game_stats' do
    subject { game.team_game_stats }

    let(:game) do
      described_class.new(
        id: game_id,
        home_team: home_team,
        away_team: away_team,
        date: DateTime.now,
        league: league
      )
    end

    let(:game_id) { Faker::Number.unique.number(digits: 10).to_s }
    let(:home_team_id) { Faker::Number.unique.number(digits: 5).to_s }
    let(:away_team_id) { Faker::Number.unique.number(digits: 5).to_s }
    let(:home_team) { instance_double(EspnPub::Entities::Team, id: home_team_id) }
    let(:away_team) { instance_double(EspnPub::Entities::Team, id: away_team_id) }
    let(:league_name) { EspnPub::Entities::League::NAME::NBA }
    let(:sport) { EspnPub::Entities::League::NAME_TO_SPORT[league_name] }
    let(:league) { instance_double(EspnPub::Entities::League, sport: sport, league_name: league_name) }
    let(:status) { 200 }
    let(:boxscore_teams) do
      [
        {
          'team' => { 'id' => home_team_id },
          'statistics' => [
            { 'label' => 'FG', 'displayValue' => '42-88' },
            { 'label' => 'Rebounds', 'displayValue' => '51' },
            { 'label' => 'Points', 'displayValue' => '112' }
          ]
        },
        {
          'team' => { 'id' => away_team_id },
          'statistics' => [
            { 'label' => 'FG', 'displayValue' => '39-85' },
            { 'label' => 'Rebounds', 'displayValue' => '45' },
            { 'label' => 'Points', 'displayValue' => '105' }
          ]
        }
      ]
    end
    let(:summary_response) { { 'boxscore' => { 'teams' => boxscore_teams } } }
    let(:path) { "/apis/site/v2/sports/#{sport}/#{league_name}/summary?event=#{game_id}" }

    before do
      stub_request(:get, "https://site.web.api.espn.com#{path}")
        .to_return(status: status, body: summary_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns TeamGameStat objects mapped from the boxscore' do
      expect(subject.size).to eq(2)
      expect(subject).to all(be_a(EspnPub::Entities::TeamGameStat))

      home_stat, away_stat = subject

      expect(home_stat.team).to eq(home_team)
      expect(home_stat.stats_data).to eq('FG' => '42-88', 'Rebounds' => '51')
      expect(away_stat.team).to eq(away_team)
      expect(away_stat.stats_data).to eq('FG' => '39-85', 'Rebounds' => '45')
    end

    it 'caches the team stats and issues only one request' do
      first_result = game.team_game_stats
      second_result = game.team_game_stats

      expect(a_request(:get, "https://site.web.api.espn.com#{path}")).to have_been_made.once
      expect(first_result).to eq(second_result)
    end

    context 'when the expected response data is missing' do
      let(:summary_response) { {} }

      it { is_expected.to eq([]) }
    end

    context 'when the request is not successful' do
      let(:status) { 500 }
      let(:summary_response) { 'internal_error' }

      it 'logs a warning' do
        expect_any_instance_of(Kernel).to receive(:warn).with(/Failed to fetch game summary for/)
        subject
      end

      it { is_expected.to eq([]) }
    end
  end
end
