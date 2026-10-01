# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Entities::TeamGameStat do
  describe '#initialize' do
    subject do
      described_class.new(team: team, stats_data: stats_data)
    end

    let(:team) { instance_double(EspnPub::Entities::Team) }
    let(:stats_data) { { 'Assists' => 10 } }

    it 'has the correct team' do
      expect(subject.team).to eq(team)
    end

    it 'has the correct stats_data' do
      expect(subject.stats_data).to eq(stats_data)
    end
  end
end
