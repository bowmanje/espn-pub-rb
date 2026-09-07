# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Entities::Team do
  let(:team_id) { Faker::Number.unique.number(digits: 2).to_s }
  let(:name) { Faker::Sports::Basketball.team.split(' ').last }
  let(:location) { Faker::Address.city }
  let(:abbreviation) { Faker::Alphanumeric.alpha(number: 3).upcase }
  let(:sport) { EspnPub::Entities::League::NAME_TO_SPORT[league] }
  let(:league) { EspnPub::Entities::League::NAME::NBA }
  let(:positions) { %w[G F C] }
  let(:venue_id) { Faker::Number.unique.number(digits: 4).to_s }
  let(:venue_name) { Faker::Company.name }
  let(:venue_city) { Faker::Address.city }
  let(:venue_state) { Faker::Address.state_abbr }
  let(:venue) do
    EspnPub::Entities::Venue.new(
      id: venue_id,
      full_name: venue_name,
      city: venue_city,
      state: venue_state,
      indoor: true,
      grass: false
    )
  end

  describe '#initialize' do
    subject do
      described_class.new(
        id: team_id,
        name: name,
        location: location,
        abbreviation: abbreviation,
        sport: sport,
        league: league
      )
    end

    it 'has the correct id' do
      expect(subject.id).to eq(team_id)
    end

    it 'has the correct name' do
      expect(subject.name).to eq(name)
    end

    it 'has the correct location' do
      expect(subject.location).to eq(location)
    end

    it 'has the correct abbreviation' do
      expect(subject.abbreviation).to eq(abbreviation)
    end

    it 'has the correct sport' do
      expect(subject.sport).to eq(sport)
    end

    it 'has the correct league' do
      expect(subject.league).to eq(league)
    end

    it 'defaults venue to nil' do
      expect(subject.venue).to be_nil
    end

    context 'when venue is provided' do
      subject do
        described_class.new(
          id: team_id,
          name: name,
          location: location,
          abbreviation: abbreviation,
          sport: sport,
          league: league,
          venue: venue
        )
      end

      it 'has the correct venue' do
        expect(subject.venue).to eq(venue)
      end
    end

    it 'has a client from Base' do
      expect(subject.client).to be_a(EspnPub::Client)
    end
  end

  describe '.fetch_by_id' do
    subject { described_class.fetch_by_id(id: team_id, sport: sport, league: league) }

    let(:path) { "/apis/site/v2/sports/#{sport}/#{league}/teams/#{team_id}" }
    let(:status) { 200 }
    let(:team_response) do
      {
        'team' => {
          'id' => team_id,
          'name' => name,
          'location' => location,
          'abbreviation' => abbreviation,
          'franchise' => {
            'venue' => {
              'id' => venue_id,
              'fullName' => venue_name,
              'address' => {
                'city' => venue_city,
                'state' => venue_state
              },
              'indoor' => true,
              'grass' => false
            }
          }
        }
      }
    end

    before do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: status, body: team_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'sends a request to the correct path' do
      expect_any_instance_of(EspnPub::Client).to receive(:send_request).with(path).and_return(team_response)
      subject
    end

    context 'when the request is successful' do
      context 'when team data is present' do
        it 'returns a Team instance with correct attributes' do
          expect(subject).to be_a(EspnPub::Entities::Team)
          expect(subject.id).to eq(team_id)
          expect(subject.name).to eq(name)
          expect(subject.location).to eq(location)
          expect(subject.abbreviation).to eq(abbreviation)
          expect(subject.sport).to eq(sport)
          expect(subject.league).to eq(league)
          expect(subject.venue).to be_a(EspnPub::Entities::Venue)
          expect(subject.venue.id).to eq(venue_id)
          expect(subject.venue.full_name).to eq(venue_name)
          expect(subject.venue.city).to eq(venue_city)
          expect(subject.venue.state).to eq(venue_state)
          expect(subject.venue.indoor).to be(true)
          expect(subject.venue.grass).to be(false)
        end
      end

      context 'when venue data is missing' do
        let(:team_response) do
          {
            'team' => {
              'id' => team_id,
              'name' => name,
              'location' => location,
              'abbreviation' => abbreviation
            }
          }
        end

        it 'returns a Team with a nil venue' do
          expect(subject.venue).to be_nil
        end
      end

      context 'when team data is missing' do
        let(:team_response) { {} }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end

    context 'when the request is not successful' do
      let(:status) { 500 }
      let(:team_response) { 'internal_error' }

      it 'logs a warning' do
        expect_any_instance_of(Kernel).to receive(:warn).with(/Failed to fetch team data for/)
        subject
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#players' do
    subject { team.players }

    let(:team) do
      described_class.new(
        id: team_id,
        name: name,
        location: location,
        abbreviation: abbreviation,
        sport: sport,
        league: league
      )
    end

    let(:roster_payload) do
      [
        {
          'id' => Faker::Number.unique.number(digits: 5).to_s,
          'firstName' => Faker::Name.first_name,
          'lastName' => Faker::Name.last_name,
          'position' => { 'abbreviation' => positions.sample }
        },
        {
          'id' => Faker::Number.unique.number(digits: 5).to_s,
          'firstName' => Faker::Name.first_name,
          'lastName' => Faker::Name.last_name,
          'position' => { 'abbreviation' => positions.sample }
        },
        {
          'id' => Faker::Number.unique.number(digits: 5).to_s,
          'firstName' => Faker::Name.first_name,
          'lastName' => Faker::Name.last_name,
          'position' => { 'abbreviation' => positions.sample }
        }
      ]
    end

    let(:status) { 200 }
    let(:roster_response) do
      {
        'athletes' => roster_payload
      }
    end

    let(:path) { "/apis/site/v2/sports/basketball/nba/teams/#{team_id}/roster" }

    before do
      stub_request(:get, "https://site.api.espn.com#{path}")
        .to_return(status: status, body: roster_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'sends a request to the ESPN roster path' do
      expect_any_instance_of(EspnPub::Client).to receive(:send_request).with(path).and_return(roster_response)
      subject
    end

    context 'when the request is successful' do
      it 'maps athlete data to Player attributes correctly' do
        subject.each_with_index do |player, idx|
          expect(player).to be_a(EspnPub::Entities::Player)

          athlete_data = roster_payload[idx]
          expect(player.id).to eq(athlete_data['id'])
          expect(player.first_name).to eq(athlete_data['firstName'])
          expect(player.last_name).to eq(athlete_data['lastName'])
          expect(player.position).to eq(athlete_data.dig('position', 'abbreviation'))
          expect(player.team_id).to eq(team.id)
        end
      end

      it 'caches the roster and issues only one request' do
        first_result = team.players
        second_result = team.players

        expect(a_request(:get, "https://site.api.espn.com#{path}")).to have_been_made.once
        expect(first_result).to eq(second_result)
      end
    end

    context 'when the request is not successful' do
      let(:roster_response) { 'internal_error' }
      let(:status) { 500 }

      it 'logs a warning' do
        expect_any_instance_of(Kernel).to receive(:warn).with(/Failed to fetch roster for team/)
        subject
      end

      it { is_expected.to eq([]) }
    end
  end

  describe '#full_name' do
    subject { team.full_name }

    let(:team) do
      described_class.new(
        id: team_id,
        name: name,
        location: location,
        abbreviation: abbreviation,
        sport: sport,
        league: league
      )
    end

    it { is_expected.to eq("#{location} #{name}") }
  end
end
