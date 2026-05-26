# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Entities::Game do
  describe '#initialize' do
    subject do
      described_class.new(
        id: game_id,
        home_team: home_team,
        away_team: away_team,
        date: game_date
      )
    end

    let(:game_id) { Faker::Number.unique.number(digits: 10).to_s }
    let(:home_team) { instance_double(EspnPub::Entities::Team) }
    let(:away_team) { instance_double(EspnPub::Entities::Team) }
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
end
