# Cyber Trackr Helper

A convenience wrapper around the generated Cyber Trackr API client that provides helper methods for common workflows.

## What This Provides

The helper adds these conveniences on top of the generated client:

1. **Complete STIG fetching** - Downloads all control details with progress callbacks
2. **STIG/SRG filtering** - Separates mixed results from the `/stig` endpoint
3. **Document searching** - Search by keyword and type
4. **Latest version lookup** - Find the most recent version of any document
5. **Batch operations** - Download multiple STIGs at once
6. **Control filtering** - Get controls by severity level

## Usage

```ruby
require_relative 'cyber_trackr_helper'

# Create a client
client = CyberTrackrHelper::Client.new

# Search for documents
juniper_stigs = client.search_documents('juniper', type: :stig)

# Get latest version
latest = client.get_latest_version('Juniper_SRX_Services_Gateway_ALG')

# Fetch complete STIG with progress
complete_stig = client.fetch_complete_stig('Juniper_SRX_Services_Gateway_ALG', '3', '3') do |current, total, vuln_id|
  puts "Fetching #{current}/#{total}: #{vuln_id}"
end

# Filter controls by severity
high_controls = client.fetch_controls_by_severity('Juniper_SRX_Services_Gateway_ALG', '3', '3', 'high')
```

## Key Methods

### Document Operations

- `list_stigs()` - Get all STIGs (filters out SRGs)
- `list_srgs()` - Get all SRGs (filters out STIGs)
- `search_documents(keyword, type: :all)` - Search by keyword
- `get_latest_version(name)` - Find newest version

### STIG Operations

- `fetch_complete_stig(name, version, release)` - Download with all control details
- `fetch_controls_by_severity(name, version, release, severity)` - Filter by severity
- `generate_compliance_summary(name, version, release)` - Count controls by severity

### Batch Operations

- `batch_download_stigs(stig_list, output_dir)` - Download multiple STIGs

### CCI/RMF Operations

- `get_ccis_for_rmf_control(control, revision)` - Find CCIs that map to an RMF control

## Why Not a Full Gem?

This is intentionally a simple Ruby file rather than a gem because:

1. **Minimal overhead** - Just one file to require
2. **Easy customization** - Modify for your specific needs
3. **No dependencies** - Just needs the generated client
4. **Clear code** - Easy to understand and extend

## Examples

See `examples/use_helper.rb` for a complete example of using the helper methods.