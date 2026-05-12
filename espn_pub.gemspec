# frozen_string_literal: true

require_relative 'lib/espn_pub/version'

Gem::Specification.new do |spec|
  spec.name    = 'espn_pub'
  spec.version = EspnPub::VERSION
  spec.authors = ['Jeffrey Bowman']
  spec.email   = ['bowmanjeffrey12@gmail.com']
  spec.summary     = 'A Ruby client for the public ESPN API'
  spec.description = "Fetch sports data from ESPN's public API — teams, athletes, scoreboards, and more."
  spec.homepage    = 'https://github.com/bowmanje/espn-pub-rb'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'
  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage
  }

  spec.files = Dir.glob('{lib,sig}/**/*', File::FNM_DOTMATCH)
                  .reject { |f| File.directory?(f) } +
               %w[espn_pub.gemspec README.md]

  spec.require_paths = ['lib']
  spec.add_dependency 'json', '~> 2.6'
  spec.add_dependency 'net-http', '~> 0.3'
  spec.add_dependency 'uri', '~> 0.11'
  spec.add_dependency 'date', '~> 3.3'
  spec.add_development_dependency 'rake',      '~> 13.0'
  spec.add_development_dependency 'rspec',     '~> 3.13'
  spec.add_development_dependency 'rubocop',   '~> 1.65'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.23'
end
