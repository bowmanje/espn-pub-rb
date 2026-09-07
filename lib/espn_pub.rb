# frozen_string_literal: true

# Namespace for the ESPN public API client library.
#
# This gem exposes entities and a client for fetching leagues, teams,
# players, and games from ESPN's public API.

require_relative 'espn_pub/version'
require_relative 'espn_pub/client'
require_relative 'espn_pub/entities/base'
require_relative 'espn_pub/entities/league'
require_relative 'espn_pub/entities/team'
require_relative 'espn_pub/entities/venue'
require_relative 'espn_pub/entities/player'
require_relative 'espn_pub/entities/game'

module EspnPub
end
# --- IGNORE ---
