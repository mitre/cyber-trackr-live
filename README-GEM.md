# cyber_trackr_live

Ruby client for the cyber.trackr.live API - Access DISA STIGs, SRGs, RMF controls, CCIs, and SCAP data.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cyber_trackr_live'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cyber_trackr_live

## Usage

### Basic Usage

```ruby
require 'cyber_trackr_helper'

# Initialize the helper client
client = CyberTrackrHelper::Client.new

# List all STIGs
stigs = client.list_stigs
stigs.each do |name, versions|
  puts "#{name}: #{versions.first.version}R#{versions.first.release}"
end

# Fetch a complete STIG with all requirements
stig = client.fetch_complete_stig('Juniper_SRX_Services_Gateway_ALG', '3', '3')
puts "#{stig[:title]} has #{stig[:requirements].count} requirements"

# Search for documents
results = client.search_documents('firewall')
```

### Direct API Client Usage

```ruby
require 'cyber_trackr_client'

# Configure the client
CyberTrackrClient.configure do |config|
  config.host = 'cyber.trackr.live'
  config.base_path = '/api'
end

# Use the API directly
api = CyberTrackrClient::DocumentsApi.new
documents = api.list_all_documents
```

## API Documentation

Full API documentation is available at: https://mitre.github.io/cyber-trackr-live/

## Features

- Full access to cyber.trackr.live API
- Helper methods for common workflows
- Automatic retry and error handling
- Progress callbacks for long operations
- Type-safe Ruby objects

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://opensource.org/licenses/Apache-2.0).