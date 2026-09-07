# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Entities::Base do
  describe '#initialize' do
    subject { described_class.new }

    it 'calls init_client' do
      expect_any_instance_of(described_class).to receive(:init_client)
      subject
    end
  end

  describe '#init_client' do
    subject { described_class.new.send :init_client }

    it 'returns a new client instance' do
      expect(subject).to be_a(EspnPub::Client)
    end

    it 'initializes client with correct base URI and version' do
      expect(subject.uri.to_s).to eq('https://site.api.espn.com')
    end

    it 'initializes client with correct version' do
      expect(subject.version).to eq('v2')
    end
  end
end
