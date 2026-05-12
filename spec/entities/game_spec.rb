# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Entities::Game do
  describe '#initialize' do
    subject do
      described_class.new(
        id: game_id,
        home_team_id: home_team_id,
        away_team_id: away_team_id,
        date: game_date
      )
    end

    let(:game_id) { Faker::Number.unique.number(digits: 10).to_s }
    let(:home_team_id) { Faker::Number.number(digits: 5).to_s }
    let(:away_team_id) { Faker::Number.number(digits: 5).to_s }
    let(:game_date) { DateTime.now }

    it 'has the correct game_id' do
      expect(subject.id).to eq(game_id)
    end

    it 'has the correct home_team_id' do
      expect(subject.home_team_id).to eq(home_team_id)
    end

    it 'has the correct away_team_id' do
      expect(subject.away_team_id).to eq(away_team_id)
    end

    it 'has the correct date' do
      expect(subject.date).to eq(game_date)
    end

    it 'has a client from Base' do
      expect(subject.client).to be_a(EspnPub::Client)
    end
  end
end
