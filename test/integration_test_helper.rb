# frozen_string_literal: true

# Add lib to load path
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'minitest/autorun'

# Integration test helper - does NOT load WebMock
# This allows real HTTP connections for integration tests
module IntegrationTestHelper
  # Skip integration tests if environment variable is set
  def skip_if_integration_disabled
    skip if ENV['SKIP_INTEGRATION_TESTS']
  end

  # Helper method to check if we should skip live API tests
  def skip_live_api_tests?
    ENV['SKIP_INTEGRATION_TESTS'] == '1'
  end
end