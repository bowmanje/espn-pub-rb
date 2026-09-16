# frozen_string_literal: true

module EspnPub
  module Entities
    # Represents a team's home venue (stadium or arena).
    class Venue < Base
      attr_reader :id,
                  :full_name,
                  :short_name,
                  :address_data,
                  :indoor,
                  :grass

      # Initialize a Venue entity.
      #
      # @param id [String] The venue identifier.
      # @param full_name [String, nil] The venue's full name.
      # @param short_name [String, nil] The venue's short name.
      # @param address_data [Hash, nil] The venue's address data.
      # @param indoor [Boolean, nil] Whether the venue is indoors.
      # @param grass [Boolean, nil] Whether the venue has a grass surface.
      def initialize(id:, full_name: nil, short_name: nil, indoor: nil, grass: nil, address_data: {})
        @id = id
        @full_name = full_name
        @short_name = short_name
        @address_data = address_data
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
          address_data: data['address'],
          indoor: data['indoor'],
          grass: data['grass']
        )
      end
    end
  end
end
