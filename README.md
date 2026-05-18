# espn-pub-rb

`espn_pub` is a lightweight Ruby client for the public ESPN API. It provides a simple interface for fetching league teams, team rosters, players, and game scoreboards.

## Features

- Fetch NBA and NFL teams
- Retrieve team rosters and player metadata
- Query league scoreboards for a specific date
- Wraps ESPN public API endpoints with Ruby objects

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'espn_pub'
```

Then run:

```bash
bundle install
```

Or install directly with:

```bash
gem install espn_pub
```

## Requirements

- Ruby `>= 3.3.0`

## Usage

Require the gem and instantiate entities directly:

```ruby
require 'espn_pub'

league = EspnPub::Entities::League.new(EspnPub::Entities::League::NAME::NBA)
```

### Fetch teams for a league

```ruby
teams = league.teams
puts teams.map(&:name)
```

### Fetch a team's roster

```ruby
team = teams.first
players = team.players
players.each do |player|
  puts "#{player.full_name} (#{player.position})"
end
```

### Fetch games for a league

```ruby
require 'date'

games = league.games(date: Date.today)
games.each do |game|
  puts "Game ID: #{game.id} | Home: #{game.home_team_id} | Away: #{game.away_team_id} | Date: #{game.date}"
end
```

### Use the raw client directly

```ruby
client = EspnPub::Client.new(
  base_uri: EspnPub::Client::BASE_URI,
  version: EspnPub::Client::API_VERSION
)

response = client.send_request('/apis/site/v2/sports/basketball/nba/teams')
puts response['sports'][0]['leagues'][0]['teams'].map { |team| team.dig('team', 'name') }
```

## Error handling

The client raises `EspnPub::Client::UnexpectedResponseCodeError` when the API response status is not `200`.

```ruby
begin
  client.send_request('/invalid/path')
rescue EspnPub::Client::UnexpectedResponseCodeError => e
  warn "API request failed: #{e.message}"
end
```

## Development

Clone the repository and install development dependencies:

```bash
git clone https://github.com/bowmanje/espn-pub-rb.git
cd espn-pub-rb
bundle install
```

Run the test suite with:

```bash
bundle exec rspec
```

## License

`espn_pub` is licensed under the MIT License.
