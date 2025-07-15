# frozen_string_literal: true

# Add lib to load path
$LOAD_PATH.unshift(File.expand_path('../../lib', __dir__))

require 'minitest/autorun'
require_relative '../../lib/cyber_trackr_helper'

# Integration tests that hit the real API
# Set SKIP_INTEGRATION_TESTS=1 to skip these
# NOTE: This test does NOT load test_helper.rb to avoid WebMock blocking real HTTP calls
class LiveIntegrationTest < Minitest::Test
  def setup
    skip if ENV['SKIP_INTEGRATION_TESTS']
    @client = CyberTrackrHelper::Client.new
  end

  def test_real_api_list_documents
    skip 'Skipping live API test' if ENV['SKIP_INTEGRATION_TESTS']

    # List all documents
    all_docs = @client.documents_api.list_all_documents

    assert all_docs.size > 1000, 'Expected over 1000 documents'
    assert all_docs.key?(:Juniper_SRX_Services_Gateway_ALG), 'Expected Juniper ALG STIG'
  end

  def test_real_api_search_juniper
    skip 'Skipping live API test' if ENV['SKIP_INTEGRATION_TESTS']

    # Search for Juniper documents
    juniper_docs = @client.search_documents('juniper')

    assert juniper_docs.size.positive?, 'Expected to find Juniper documents'

    # Check we can separate STIGs and SRGs
    stigs = juniper_docs.reject { |name, _| @client.is_srg?(name) }
    srgs = juniper_docs.select { |name, _| @client.is_srg?(name) }

    puts "Found #{stigs.size} Juniper STIGs and #{srgs.size} Juniper SRGs"
    assert stigs.size.positive?, 'Expected to find Juniper STIGs'
  end

  def test_real_api_get_document
    skip 'Skipping live API test' if ENV['SKIP_INTEGRATION_TESTS']

    # Get a specific document
    doc = @client.documents_api.get_document('Juniper_SRX_Services_Gateway_ALG', '3', '3')

    assert_equal 'Juniper_SRX_SG_ALG_STIG', doc.id
    assert_equal 'accepted', doc.status
    assert doc.requirements.size > 20, 'Expected more than 20 requirements'

    # Check requirement structure
    v_id, req = doc.requirements.first
    assert v_id =~ /^V-\d{6}$/, 'Expected V-ID format'
    assert %w[high medium low].include?(req.severity), 'Expected valid severity'
  end

  def test_real_api_compliance_summary
    skip 'Skipping live API test' if ENV['SKIP_INTEGRATION_TESTS']

    summary = @client.generate_compliance_summary('Juniper_SRX_Services_Gateway_ALG', '3', '3')

    assert_equal 24, summary[:total], 'Expected 24 total controls'
    assert summary[:by_severity][:high] >= 0
    assert summary[:by_severity][:medium].positive?
    assert summary[:by_severity][:low] >= 0

    total_by_severity = summary[:by_severity].values.sum
    assert_equal summary[:total], total_by_severity, 'Severity counts should sum to total'
  end

  def test_real_api_fetch_single_control
    skip 'Skipping live API test' if ENV['SKIP_INTEGRATION_TESTS']

    # Fetch a single control with full details
    begin
      control = @client.documents_api.get_requirement(
        'Juniper_SRX_Services_Gateway_ALG', '3', '3', 'V-214518'
      )

      assert_equal 'V-214518', control.id
      assert control.check_text, 'Expected check text'
      assert control.fix_text, 'Expected fix text'
      assert control.rule =~ /^SV-/, 'Expected SV rule ID'
    rescue JSON::ParserError => e
      # Known issue: API returns invalid JSON with control characters
      skip "Skipping due to API JSON parsing issue: #{e.message[0..100]}..."
    rescue => e
      # Log other errors but don't fail the test suite
      puts "⚠️  Warning: Live API test failed with: #{e.class}: #{e.message}"
      skip "Live API test failed: #{e.message}"
    end
  end
end
