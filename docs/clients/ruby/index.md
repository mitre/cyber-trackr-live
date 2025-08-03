# Ruby Client

Ruby client library for accessing the cyber.trackr.live API with comprehensive helper methods for STIG workflows.

> **New to the API?** Check out the [API Getting Started Guide](../../api-reference/getting-started.md) to understand the data model and endpoints.

## Installation

```bash
gem install cyber_trackr_live
```

Or add to your Gemfile:
```ruby
gem 'cyber_trackr_live'
```

**Requirements:** Ruby 3.2+ (see `.ruby-version`)

## Quick Start

```ruby
require 'cyber_trackr_live'

# Initialize the helper (includes generated client)
helper = CyberTrackrHelper.new

# Fetch a complete STIG
stig = helper.fetch_complete_stig('Juniper_SRX_Services_Gateway_ALG', '3', '3')

puts "STIG: #{stig[:title]}"
puts "Requirements: #{stig[:requirements].count}"

# List all available STIGs
stigs = helper.list_stigs
puts "Available STIGs: #{stigs.count}"
```

## Architecture

The Ruby client consists of two main components:

### 1. Generated Client (`CyberTrackrClient`)
- Auto-generated from OpenAPI specification
- Low-level API access with full type safety
- Handles authentication, serialization, and HTTP details
- You could [generate this yourself](../generation/overview.md), but we maintain it for you

### 2. Helper Methods (`CyberTrackrHelper`)  
- High-level convenience methods for common workflows
- Wraps generated client with business logic
- Provides simplified interfaces for complex operations
- **Unique value-add** not available in other language clients

## Key Features

- **Cross-platform compatibility** - Works on Windows, macOS, and Linux
- **Pure Ruby dependencies** - No external system requirements
- **Comprehensive error handling** - Graceful handling of API edge cases
- **Rich helper methods** - Pre-built workflows for STIG operations
- **Type safety** - Generated from OpenAPI specification
- **Extensive examples** - Real-world usage patterns

## Helper Methods

The helper provides simplified methods for common STIG workflows:

```ruby
helper = CyberTrackrHelper.new

# High-level operations
stigs = helper.list_stigs
srgs = helper.list_srgs  
documents = helper.search_documents('keyword')

# Complete STIG workflow
complete_stig = helper.fetch_complete_stig(title, version, release)

# Individual components
metadata = helper.get_stig_metadata(title, version, release)
requirements = helper.get_stig_requirements(title, version, release)
```

## Direct Client Access

For advanced use cases, access the generated client directly:

```ruby
# Direct client access
client = CyberTrackrClient::DefaultApi.new

# Low-level API calls
response = client.get_document('Juniper_SRX_Services_Gateway_ALG', '3', '3')
requirements = client.get_requirements('Juniper_SRX_Services_Gateway_ALG', '3', '3')
```

## Learn More

- **[Helper Methods](./helper-methods.md)** - Complete reference for convenience methods
- **[Examples](./examples.md)** - Real-world usage examples and patterns
- **[API Documentation](../../api-reference/getting-started.md)** - Understand the underlying API
- **[Generate Other Clients](../generation/overview.md)** - Create clients for other languages

## Support

- 📚 **Documentation**: This site and inline code comments
- 🐛 **Issues**: [GitHub Issues](https://github.com/mitre/cyber-trackr-live/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/mitre/cyber-trackr-live/discussions)