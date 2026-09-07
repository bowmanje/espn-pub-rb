# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Entities::League do
  describe '#initialize' do
    subject { described_class.new(name) }

    let(:name) { Faker::Color.color_name }

    it 'has the correct name' do
      expect(subject.name).to eq(name)
    end

    it 'has a client from Base' do
      expect(subject.client).to be_a(EspnPub::Client)
    end
  end

  describe 'sport' do
    subject { described_class.new(league_name).sport }

    context 'when the league is NBA' do
      let(:league_name) { described_class::NAME::NBA }

      it { is_expected.to eq('basketball') }
    end

    context 'when the league is NFL' do
      let(:league_name) { described_class::NAME::NFL }

      it { is_expected.to eq('football') }
    end
  end

  describe '#teams' do
    subject { league.teams }

    let(:league) { described_class.new(described_class::NAME::NBA) }
    let(:teams_payload) do
      [
        {
          'team' => {
            'id' => Faker::Number.number(digits: 5),
            'location' => Faker::Address.city,
            'name' => Faker::Sports::Basketball.team.split(' ').last,
            'abbreviation' => Faker::Alphanumeric.alpha(number: 3).upcase
          }
        },
        {
          'team' => {
            'id' => Faker::Number.number(digits: 5),
            'location' => Faker::Address.city,
            'name' => Faker::Sports::Basketball.team.split(' ').last,
            'abbreviation' => Faker::Alphanumeric.alpha(number: 3).upcase
          }
        }
      ]
    end

    let(:status) { 200 }
    let(:teams_response) do
      {
        'sports' => [
          {
            'leagues' => [
              {
                'teams' => teams_payload
              }
            ]
          }
        ]
      }
    end

    let(:path) { '/apis/site/v2/sports/basketball/nba/teams' }

    before do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: status, body: teams_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'sends a request to the ESPN teams path' do
      expect_any_instance_of(EspnPub::Client).to receive(:send_request).with(path).and_return(teams_response)
      subject
    end

    context 'when the request is successful' do
      it 'returns the teams from the response' do
        subject.each_with_index do |team, idx|
          expect(team).to be_a(EspnPub::Entities::Team)
          expect(team.id).to eq(teams_payload[idx].dig('team', 'id'))
          expect(team.name).to eq(teams_payload[idx].dig('team', 'name'))
          expect(team.location).to eq(teams_payload[idx].dig('team', 'location'))
          expect(team.abbreviation).to eq(teams_payload[idx].dig('team', 'abbreviation'))
        end
      end

      it 'caches the teams result and issues only one request' do
        first_result = league.teams
        second_result = league.teams

        expect(a_request(:get, "https://site.api.espn.com#{path}")).to have_been_made.once
        expect(first_result).to eq(second_result)
      end
    end

    context 'when the request is not successful' do
      let(:roster_response) { 'internal_error' }
      let(:status) { 500 }

      it 'logs a warning' do
        expect_any_instance_of(Kernel).to receive(:warn).with(/Failed to fetch teams for league/)
        subject
      end

      it { is_expected.to eq([]) }
    end
  end

  describe '#games' do
    subject { league.games(date: game_date) }

    let(:league) { described_class.new(described_class::NAME::NBA) }
    let(:sport) { league.sport }
    let(:name) { league.name }
    let(:competitor_team_1) { Faker::Number.number(digits: 5).to_s }
    let(:competitor_team_2) { Faker::Number.number(digits: 5).to_s }
    let(:competitor_team_3) { Faker::Number.number(digits: 5).to_s }
    let(:competitor_team_4) { Faker::Number.number(digits: 5).to_s }

    let(:games_payload) do
      [
        {
          'id' => Faker::Number.number(digits: 10).to_s,
          'date' => Time.now.iso8601,
          'competitions' => [
            {
              'competitors' => [
                { 'id' => competitor_team_1 },
                { 'id' => competitor_team_2 }
              ]
            }
          ]
        },
        {
          'id' => Faker::Number.number(digits: 10).to_s,
          'date' => Time.now.iso8601,
          'competitions' => [
            {
              'competitors' => [
                { 'id' => competitor_team_3 },
                { 'id' => competitor_team_4 }
              ]
            }
          ]
        }
      ]
    end

    let(:status) { 200 }
    let(:games_response) do
      {
        'events' => games_payload
      }
    end

    let(:competitor_team_path_1) { "/apis/site/v2/sports/#{sport}/#{name}/teams/#{competitor_team_1}" }
    let(:competitor_team_path_2) { "/apis/site/v2/sports/#{sport}/#{name}/teams/#{competitor_team_2}" }
    let(:competitor_team_path_3) { "/apis/site/v2/sports/#{sport}/#{name}/teams/#{competitor_team_3}" }
    let(:competitor_team_path_4) { "/apis/site/v2/sports/#{sport}/#{name}/teams/#{competitor_team_4}" }

    before do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: status, body: games_response.to_json, headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://site.api.espn.com#{competitor_team_path_1}")
        .to_return(status: status, body: { 'team' => { 'id' => competitor_team_1 } }.to_json, headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://site.api.espn.com#{competitor_team_path_2}")
        .to_return(status: status, body: { 'team' => { 'id' => competitor_team_2 } }.to_json, headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://site.api.espn.com#{competitor_team_path_3}")
        .to_return(status: status, body: { 'team' => { 'id' => competitor_team_3 } }.to_json, headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://site.api.espn.com#{competitor_team_path_4}")
        .to_return(status: status, body: { 'team' => { 'id' => competitor_team_4 } }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    context 'when the game_date is nil' do
      let(:game_date) { nil }
      let(:path) { '/apis/site/v2/sports/basketball/nba/scoreboard' }

      it 'sends a request to the ESPN games path' do
        expect(league.client).to receive(:send_request).with(path).and_return(games_response)
        subject
      end

      context 'when the request is successful' do
        it 'returns the games from the response' do
          subject.each_with_index do |game, idx|
            expect(game.id).to eq(games_payload[idx]['id'])
            expect(game.home_team.id).to eq(games_payload[idx].dig('competitions', 0, 'competitors', 0, 'id'))
            expect(game.away_team.id).to eq(games_payload[idx].dig('competitions', 0, 'competitors', 1, 'id'))
            expect(game.date).to eq(DateTime.parse(games_payload[idx]['date']))
          end
        end
      end

      context 'when the request is not successful' do
        let(:games_response) { 'internal_error' }
        let(:status) { 500 }

        it 'logs a warning' do
          expect_any_instance_of(Kernel).to receive(:warn).with(/Failed to fetch games for league/)
          subject
        end

        it { is_expected.to eq([]) }
      end
    end

    context 'when the game_date is not nil' do
      let(:game_date) { Date.today }
      let(:path) { "/apis/site/v2/sports/basketball/nba/scoreboard?dates=#{game_date.strftime('%Y%m%d')}" }

      it 'sends a request to the ESPN games path' do
        expect(league.client).to receive(:send_request).with(path).and_return(games_response)
        subject
      end
    end
  end
end
