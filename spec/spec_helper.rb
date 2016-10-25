# frozen_string_literal: true
ENV['RAILS_ENV'] ||= 'test'

require 'coveralls'
Coveralls.wear!
require 'engine_cart'
EngineCart.load_application!

require 'active_fedora'
require 'active_fedora/noid'
require 'byebug' unless ENV['CI']

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
