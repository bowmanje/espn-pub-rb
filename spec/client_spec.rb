# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Client do
  let(:base_uri) { 'https://site.api.espn.com/' }
  let(:version) { 'v2' }
  let(:league) { 'nba' }
  let(:client) { described_class.new(base_uri: base_uri, version: version, league: league) }

  describe '#initialize' do
    it 'exposes uri, version, and league' do
      expect(client.uri).to be_a(URI)
      expect(client.uri.to_s).to eq(base_uri)
      expect(client.version).to eq(version)
      expect(client.league).to eq(league)
    end
  end

  describe '#send_request' do
    let(:path) { '/apis/site/v2/sports/basketball/nba/teams' }
    let(:response_body) do
      {
        'sports' => [
          {
            'leagues' => [
              {
                'teams' => [
                  { 'displayName' => Faker::Sports::Basketball.team }
                ]
              }
            ]
          }
        ]
      }.to_json
    end

    it 'returns parsed JSON when the response code is 200' do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      expect(client.send_request(path)).to eq(JSON.parse(response_body))
    end

    it 'raises NotExpectedResponseCodeError for non-200 responses' do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: 500, body: 'server error')

      expect { client.send_request(path) }
        .to raise_error(EspnPub::Client::NotExpectedResponseCodeError, 'Unexpected response code: 500')
    end
  end
end
