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
  
  describe '#initialize' do
    subject do
      described_class.new(
        id: player_id,
        sport: sport,
        league: league,
        first_name: first_name,
        last_name: last_name,
        position: position,
        team_id: team_id
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

    it 'initializes the client from Base' do
      expect(subject.client).to be_a(EspnPub::Client)
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
