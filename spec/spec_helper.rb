# frozen_string_literal: true

require 'bundler/setup'
require 'webmock/rspec'
require 'faker'
require_relative '../lib/espn_pub'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  WebMock.disable_net_connect!(allow_localhost: true)
end
