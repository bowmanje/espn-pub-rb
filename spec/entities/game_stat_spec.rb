require 'spec_helper'

RSpec.describe EspnPub::Entities::GameStat do
  describe '#initialize' do
    subject do
      described_class.new(player: player, team: team, stats_data: stats_data)
    end

    let(:player) { instance_double(EspnPub::Entities::Player) }
    let(:team) { instance_double(EspnPub::Entities::Team) }
    let(:stats_data) { { "points" => 10 } }

    it 'has the correct player' do
      expect(subject.player).to eq(player)
    end
    
    it 'has the correct team' do
      expect(subject.team).to eq(team)
    end

    it 'has the correct stats_data' do
      expect(subject.stats_data).to eq(stats_data)
    end
  end
end