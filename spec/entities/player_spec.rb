# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Entities::Player do
  let(:player_id) { Faker::Number.unique.number(digits: 7).to_s }
  let(:sport) { 'basketball' }
  let(:league) { 'nba' }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:position) { %w[G F C].sample }
  let(:team_id) { Faker::Number.number(digits: 5).to_s }
  let(:date_of_birth) { Date.new(1995, 9, 17) }
  let(:height) { "6' 3\"" }
  let(:weight) { '230 lbs' }
  let(:debut_year) { 2017 }
  let(:birthCity) { 'Tyler' }
  let(:birthState) { 'TX' }
  let(:birthCountry) { 'USA' }

  describe '#initialize' do
    subject do
      described_class.new(
        id: player_id,
        sport: sport,
        league: league,
        first_name: first_name,
        last_name: last_name,
        position: position,
        team_id: team_id,
        date_of_birth: date_of_birth,
        birthCity: birthCity,
        birthState: birthState,
        birthCountry: birthCountry,
        height: height,
        weight: weight,
        debut_year: debut_year
      )
    end

    it 'requires id' do
      expect { described_class.new(sport: sport, league: league) }.to raise_error(ArgumentError)
    end

    it 'requires sport' do
      expect { described_class.new(id: player_id, league: league) }.to raise_error(ArgumentError)
    end

    it 'requires league' do
      expect { described_class.new(id: player_id, sport: sport) }.to raise_error(ArgumentError)
    end

    it 'has the correct id' do
      expect(subject.id).to eq(player_id)
    end

    it 'has the correct sport' do
      expect(subject.sport).to eq(sport)
    end

    it 'has the correct league' do
      expect(subject.league).to eq(league)
    end

    it 'has the correct first_name' do
      expect(subject.first_name).to eq(first_name)
    end

    it 'has the correct last_name' do
      expect(subject.last_name).to eq(last_name)
    end

    it 'has the correct position' do
      expect(subject.position).to eq(position)
    end

    it 'has the correct team_id' do
      expect(subject.team_id).to eq(team_id)
    end

    it 'has the correct date_of_birth' do
      expect(subject.date_of_birth).to eq(date_of_birth)
    end

    it 'has the correct height' do
      expect(subject.height).to eq(height)
    end

    it 'has the correct weight' do
      expect(subject.weight).to eq(weight)
    end

    it 'has the correct debut_year' do
      expect(subject.debut_year).to eq(debut_year)
    end

    it 'initializes the client from Base' do
      expect(subject.client).to be_a(EspnPub::Client)
    end
  end

  describe '.fetch_by_id' do
    subject { described_class.fetch_by_id(id: player_id, sport: sport, league: league) }

    let(:path) { "/apis/common/v3/sports/#{sport}/#{league}/athletes/#{player_id}" }
    let(:status) { 200 }
    let(:athlete_response) do
      {
        'athlete' => {
          'id' => player_id,
          'firstName' => first_name,
          'lastName' => last_name,
          'dateOfBirth' => '1995-09-17T00:00:00Z',
          'birthPlace' => {
            'city' => birthCity,
            'state' => birthState,
            'country' => birthCountry
          },
          'displayHeight' => height,
          'displayWeight' => weight,
          'debutYear' => debut_year,
          'position' => { 'abbreviation' => position },
          'team' => { 'id' => team_id }
        }
      }
    end

    before do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: status, body: athlete_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'sends a request to the correct path' do
      expect_any_instance_of(EspnPub::Client).to receive(:send_request).with(path).and_return(athlete_response)
      subject
    end

    context 'when the request is successful' do
      context 'when athlete data is present' do
        it 'returns a Player instance with correct attributes' do
          expect(subject).to be_a(EspnPub::Entities::Player)
          expect(subject.id).to eq(player_id)
          expect(subject.first_name).to eq(first_name)
          expect(subject.last_name).to eq(last_name)
          expect(subject.position).to eq(position)
          expect(subject.team_id).to eq(team_id)
          expect(subject.date_of_birth).to eq(date_of_birth)
          expect(subject.birthCity).to eq(birthCity)
          expect(subject.birthState).to eq(birthState)
          expect(subject.birthCountry).to eq(birthCountry)
          expect(subject.height).to eq(height)
          expect(subject.weight).to eq(weight)
          expect(subject.debut_year).to eq(debut_year)
          expect(subject.sport).to eq(sport)
          expect(subject.league).to eq(league)
        end
      end

      context 'when athlete data is missing' do
        let(:athlete_response) { {} }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end

    context 'when the request is not successful' do
      let(:status) { 500 }
      let(:athlete_response) { 'internal_error' }

      it 'logs a warning' do
        expect_any_instance_of(Kernel).to receive(:warn).with(/Failed to fetch player data for/)
        subject
      end

      it { is_expected.to be_nil }
    end
  end

  describe '.parse_date_of_birth' do
    it 'parses ISO date strings' do
      expect(described_class.send(:parse_date_of_birth, '1995-09-17T00:00:00Z')).to eq(Date.new(1995, 9, 17))
    end

    it 'returns nil for invalid dates' do
      expect(described_class.send(:parse_date_of_birth, 'not-a-date')).to be_nil
    end

    it 'returns nil when value is nil' do
      expect(described_class.send(:parse_date_of_birth, nil)).to be_nil
    end
  end

  describe '#full_name' do
    subject { player.full_name }
    let(:player) do
      described_class.new(
        id: '1',
        sport: 'basketball',
        league: 'nba',
        first_name: first_name,
        last_name: last_name
      )
    end

    it { is_expected.to eq("#{first_name} #{last_name}") }
  end
end
