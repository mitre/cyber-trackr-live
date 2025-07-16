# frozen_string_literal: true

source 'https://rubygems.org'

# OpenAPI validation with full 3.1 support

# HTTP client for API testing
gem 'faraday', '~> 2.0'
gem 'faraday-follow_redirects', '~> 0.3'

# Generated client dependencies
gem 'typhoeus', '~> 1.0'

# Documentation generation
gem 'yard', '~> 0.9'

# Development tools
group :development, :test do
  gem 'minitest', '~> 5.0'
  gem 'rake', '~> 13.0'
  gem 'rubocop', '~> 1.50' # For post-generation fixes
  gem 'rubocop-ast', '~> 1.28' # Required for custom cops
  gem 'webmock', '~> 3.0' # For mocking HTTP requests
end
