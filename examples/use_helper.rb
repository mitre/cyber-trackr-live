#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../cyber_trackr_helper'

# Example: Using the Cyber Trackr Helper
client = CyberTrackrHelper::Client.new

# 1. Search for specific STIGs
puts "=== Searching for Juniper STIGs ==="
juniper_docs = client.search_documents('juniper')
juniper_docs.each do |name, versions|
  type = client.is_srg?(name) ? 'SRG' : 'STIG'
  puts "#{name} (#{type}): #{versions.size} versions"
end

# 2. Get the latest version
puts "\n=== Latest Juniper ALG STIG ==="
latest = client.get_latest_version('Juniper_SRX_Services_Gateway_ALG')
if latest
  puts "Latest version: v#{latest['version']}r#{latest['release']} (#{latest['release_date']})"
end

# 3. Generate compliance summary
puts "\n=== Compliance Summary ==="
summary = client.generate_compliance_summary('Juniper_SRX_Services_Gateway_ALG', '3', '3')
puts "Total controls: #{summary[:total]}"
puts "By severity:"
summary[:by_severity].each do |severity, count|
  puts "  #{severity.capitalize}: #{count}"
end

# 4. Fetch controls by severity
puts "\n=== High Severity Controls ==="
high_controls = client.fetch_controls_by_severity('Juniper_SRX_Services_Gateway_ALG', '3', '3', 'high')
high_controls.each do |control|
  puts "#{control.id}: #{control.requirement_title[0..60]}..."
end

# 5. Download complete STIG with progress
puts "\n=== Downloading Complete STIG ==="
complete_stig = client.fetch_complete_stig('Juniper_SRX_Services_Gateway_ALG', '3', '3') do |current, total, vuln_id|
  print "\rFetching control #{current}/#{total}: #{vuln_id}    "
end
puts "\nDownloaded #{complete_stig[:requirements].size} complete controls"

# Save to file
require 'json'
File.write('juniper_alg_complete.json', JSON.pretty_generate(complete_stig))
puts "Saved to: juniper_alg_complete.json"