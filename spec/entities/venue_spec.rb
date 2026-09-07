# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspnPub::Entities::Venue do
  let(:venue_id) { Faker::Number.unique.number(digits: 4).to_s }
  let(:full_name) { Faker::Company.name }
  let(:short_name) { full_name.split.first }
  let(:city) { Faker::Address.city }
  let(:state) { Faker::Address.state_abbr }
  let(:zip_code) { Faker::Address.zip_code }
  let(:country) { Faker::Address.country }
  let(:indoor) { true }
  let(:grass) { false }

  describe '#initialize' do
    subject do
      described_class.new(
        id: venue_id,
        full_name: full_name,
        short_name: short_name,
        city: city,
        state: state,
        zip_code: zip_code,
        country: country,
        indoor: indoor,
        grass: grass
      )
    end

    it 'requires id' do
      expect { described_class.new(full_name: full_name) }.to raise_error(ArgumentError)
    end

    it 'has the correct id' do
      expect(subject.id).to eq(venue_id)
    end

    it 'has the correct full_name' do
      expect(subject.full_name).to eq(full_name)
    end

    it 'has the correct short_name' do
      expect(subject.short_name).to eq(short_name)
    end

    it 'has the correct city' do
      expect(subject.city).to eq(city)
    end

    it 'has the correct state' do
      expect(subject.state).to eq(state)
    end

    it 'has the correct zip_code' do
      expect(subject.zip_code).to eq(zip_code)
    end

    it 'has the correct country' do
      expect(subject.country).to eq(country)
    end

    it 'has the correct indoor' do
      expect(subject.indoor).to eq(indoor)
    end

    it 'has the correct grass' do
      expect(subject.grass).to eq(grass)
    end

    it 'initializes the client from Base' do
      expect(subject.client).to be_a(EspnPub::Client)
    end
  end

  describe '.from_api' do
    subject { described_class.from_api(api_data) }

    let(:api_data) do
      {
        'id' => venue_id,
        'fullName' => full_name,
        'shortName' => short_name,
        'address' => {
          'city' => city,
          'state' => state,
          'zipCode' => zip_code,
          'country' => country
        },
        'indoor' => indoor,
        'grass' => grass
      }
    end

    it 'returns a Venue with mapped attributes' do
      expect(subject).to be_a(described_class)
      expect(subject.id).to eq(venue_id)
      expect(subject.full_name).to eq(full_name)
      expect(subject.short_name).to eq(short_name)
      expect(subject.city).to eq(city)
      expect(subject.state).to eq(state)
      expect(subject.zip_code).to eq(zip_code)
      expect(subject.country).to eq(country)
      expect(subject.indoor).to eq(indoor)
      expect(subject.grass).to eq(grass)
    end

    context 'when data is nil' do
      let(:api_data) { nil }

      it { is_expected.to be_nil }
    end
  end
end
