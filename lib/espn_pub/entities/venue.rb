# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a team's home venue (stadium or arena).
    class Venue < Base
      attr_reader :id,
                  :full_name,
                  :short_name,
                  :city,
                  :state,
                  :zip_code,
                  :country,
                  :indoor,
                  :grass

      # Initialize a Venue entity.
      #
      # @param id [String] The venue identifier.
      # @param full_name [String, nil] The venue's full name.
      # @param short_name [String, nil] The venue's short name.
      # @param city [String, nil] The venue's city.
      # @param state [String, nil] The venue's state or province.
      # @param zip_code [String, nil] The venue's postal code.
      # @param country [String, nil] The venue's country.
      # @param indoor [Boolean, nil] Whether the venue is indoors.
      # @param grass [Boolean, nil] Whether the venue has a grass surface.
      def initialize(id:, full_name: nil, short_name: nil, city: nil, state: nil, zip_code: nil, country: nil,
                     indoor: nil, grass: nil)
        @id = id
        @full_name = full_name
        @short_name = short_name
        @city = city
        @state = state
        @zip_code = zip_code
        @country = country
        @indoor = indoor
        @grass = grass
        super()
      end

      # Build a Venue from ESPN API venue data.
      #
      # @param data [Hash, nil] Raw venue data from the API.
      # @return [Venue, nil] A Venue instance, or nil when data is absent.
      def self.from_api(data)
        return nil unless data

        new(
          id: data['id'],
          full_name: data['fullName'],
          short_name: data['shortName'],
          city: data.dig('address', 'city'),
          state: data.dig('address', 'state'),
          zip_code: data.dig('address', 'zipCode'),
          country: data.dig('address', 'country'),
          indoor: data['indoor'],
          grass: data['grass']
        )
      end
    end
  end
end
