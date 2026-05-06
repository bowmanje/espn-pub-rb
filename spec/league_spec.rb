# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::League do
  describe 'constants' do
    it 'defines league names for NBA and NFL' do
      expect(described_class::NAME::NBA).to eq('nba')
      expect(described_class::NAME::NFL).to eq('nfl')
    end

    it 'maps league names to sports' do
      expect(described_class::NAME_TO_SPORT['nba']).to eq('basketball')
      expect(described_class::NAME_TO_SPORT['nfl']).to eq('football')
    end
  end

  describe '#teams' do
    let(:league_name) { described_class::NAME::NBA }
    let(:league) { described_class.new(league_name) }
    let(:teams_payload) do
      [
        { 'displayName' => Faker::Sports::Basketball.team },
        { 'displayName' => Faker::Sports::Basketball.team }
      ]
    end
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

    it 'builds the ESPN teams path and returns the teams from the response' do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: 200, body: teams_response.to_json, headers: { 'Content-Type' => 'application/json' })

      expect(league.teams).to eq(teams_payload)
    end

    it 'caches the teams result and issues only one request' do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: 200, body: teams_response.to_json, headers: { 'Content-Type' => 'application/json' })

      first_result = league.teams
      second_result = league.teams

      expect(first_result).to eq(teams_payload)
      expect(second_result).to eq(teams_payload)
      expect(a_request(:get, "https://site.api.espn.com#{path}")).to have_been_made.once
    end

    it 'returns nil when the expected teams payload is missing' do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: 200, body: { 'sports' => [] }.to_json, headers: { 'Content-Type' => 'application/json' })

      fresh_league = described_class.new(league_name)

      expect(fresh_league.teams).to be_nil
    end
  end
end
