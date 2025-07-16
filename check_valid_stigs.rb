#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'cyber_trackr_client'

# Check what STIGs are actually available
client = CyberTrackrClient::DocumentsApi.new

puts '🔍 Checking available STIGs...'
begin
  docs = client.list_all_documents
  puts "Found #{docs.size} documents"

  # Look for common ones
  # Find Ubuntu STIGs
  ubuntu_stigs = docs.keys.select { |k| k.to_s.include?('Ubuntu') }
  puts "Ubuntu STIGs found: #{ubuntu_stigs.join(', ')}"

  common_stigs = %w[
    Windows_10
    Red_Hat_Enterprise_Linux_9
    Cisco_IOS_XE_Switch_L2S
    Juniper_SRX_Services_Gateway_NDM
  ]

  common_stigs.each do |stig|
    if docs.key?(stig.to_sym)
      version_info = docs[stig.to_sym].first
      puts "✅ #{stig}: #{version_info.version} v#{version_info.release}"
    else
      puts "❌ #{stig}: Not found"
    end
  end
rescue StandardError => e
  puts "Error: #{e.message}"
end
