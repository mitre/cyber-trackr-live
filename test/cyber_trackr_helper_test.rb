# frozen_string_literal: true

require_relative 'test_helper'
require 'webmock/minitest' # WebMock for mocking HTTP requests in helper tests
require 'cyber_trackr_helper'

class HelperTest < Minitest::Test
  include TestHelper

  def setup
    @client = CyberTrackrHelper::Client.new
  end

  def test_stig_srg_detection
    # SRGs should be detected
    assert @client.is_srg?('Application_Security_Requirements_Guide')
    assert @client.is_srg?('Some_Technology_(SRG)')
    assert @client.is_srg?('Network_SRG')

    # STIGs should not be detected as SRGs
    refute @client.is_srg?('Juniper_SRX_Services_Gateway_ALG')
    refute @client.is_srg?('Windows_10')
    refute @client.is_srg?('RHEL_9_STIG')
  end

  def test_list_filtering
    mock_documents_list

    # Test STIG filtering
    stigs = @client.list_stigs
    assert_equal 2, stigs.size
    assert stigs.key?(:Juniper_SRX_Services_Gateway_ALG)
    assert stigs.key?(:Windows_10)

    # Test SRG filtering
    srgs = @client.list_srgs
    assert_equal 2, srgs.size
    assert srgs.key?(:Application_Security_Requirements_Guide)
    assert srgs.key?(:Network_Security_Requirements_Guide)
  end

  def test_document_search
    mock_documents_list

    # Case-insensitive search
    results = @client.search_documents('JUNIPER')
    assert_equal 1, results.size
    assert results.key?(:Juniper_SRX_Services_Gateway_ALG)

    # Search with type filter
    results = @client.search_documents('security', type: :srg)
    assert_equal 2, results.size  # Both SRGs have "Security" in name

    results = @client.search_documents('security', type: :stig)
    assert_equal 0, results.size  # No STIGs have "Security" in name
  end

  def test_latest_version_selection
    mock_documents_list

    # Document with multiple versions
    latest = @client.get_latest_version('Juniper_SRX_Services_Gateway_ALG')
    assert_equal '3', latest.version
    assert_equal '3', latest.release

    # Non-existent document
    assert_nil @client.get_latest_version('NonExistent')
  end

  def test_fetch_complete_stig_with_progress
    title = 'Juniper_SRX_Services_Gateway_ALG'
    version = '3'
    release = '3'

    # Mock the initial document fetch
    mock_document(title, version, release, sample_document_detail(num_requirements: 3))

    # Mock individual requirement fetches
    mock_requirement(title, version, release, 'V-214518')
    mock_requirement(title, version, release, 'V-214519')
    mock_requirement(title, version, release, 'V-214520')

    # Track progress
    progress_updates = []

    result = @client.fetch_complete_stig(title, version, release, delay: 0) do |current, total, vuln_id|
      progress_updates << { current: current, total: total, vuln_id: vuln_id }
    end

    # Verify we got complete data
    assert_equal 3, result[:requirements].size
    assert result[:requirements]['V-214518'][:'check-text']
    assert result[:requirements]['V-214518'][:'fix-text']

    # Verify progress callbacks
    assert_equal 3, progress_updates.size
    assert_equal 1, progress_updates[0][:current]
    assert_equal 3, progress_updates[0][:total]
    assert_equal 'V-214518', progress_updates[0][:vuln_id]
  end

  def test_compliance_summary_generation
    title = 'Test_STIG'
    version = '1'
    release = '1'

    # Create a document with known severity distribution
    doc = sample_document_detail
    doc['requirements'] = {
      'V-1' => { 'title' => 'High 1', 'severity' => 'high', 'rule' => 'SV-1r1_rule', 'link' => '/stig/Test_STIG/1/1/V-1' },
      'V-2' => { 'title' => 'High 2', 'severity' => 'high', 'rule' => 'SV-2r1_rule', 'link' => '/stig/Test_STIG/1/1/V-2' },
      'V-3' => { 'title' => 'Medium 1', 'severity' => 'medium', 'rule' => 'SV-3r1_rule', 'link' => '/stig/Test_STIG/1/1/V-3' },
      'V-4' => { 'title' => 'Medium 2', 'severity' => 'medium', 'rule' => 'SV-4r1_rule', 'link' => '/stig/Test_STIG/1/1/V-4' },
      'V-5' => { 'title' => 'Medium 3', 'severity' => 'medium', 'rule' => 'SV-5r1_rule', 'link' => '/stig/Test_STIG/1/1/V-5' },
      'V-6' => { 'title' => 'Low 1', 'severity' => 'low', 'rule' => 'SV-6r1_rule', 'link' => '/stig/Test_STIG/1/1/V-6' }
    }

    mock_document(title, version, release, doc)

    summary = @client.generate_compliance_summary(title, version, release)

    assert_equal 6, summary[:total]
    assert_equal 2, summary[:by_severity][:high]
    assert_equal 3, summary[:by_severity][:medium]
    assert_equal 1, summary[:by_severity][:low]
  end

  def test_controls_by_severity_filtering
    title = 'Test_STIG'
    version = '1'
    release = '1'

    # Create mixed severity controls
    doc = sample_document_detail
    doc['requirements'] = {
      'V-1' => { 'title' => 'High 1', 'severity' => 'high', 'rule' => 'SV-1r1_rule', 'link' => '/stig/Test_STIG/1/1/V-1' },
      'V-2' => { 'title' => 'Medium 1', 'severity' => 'medium', 'rule' => 'SV-2r1_rule', 'link' => '/stig/Test_STIG/1/1/V-2' },
      'V-3' => { 'title' => 'High 2', 'severity' => 'high', 'rule' => 'SV-3r1_rule', 'link' => '/stig/Test_STIG/1/1/V-3' },
      'V-4' => { 'title' => 'Low 1', 'severity' => 'low', 'rule' => 'SV-4r1_rule', 'link' => '/stig/Test_STIG/1/1/V-4' }
    }

    mock_document(title, version, release, doc)

    # Filter high severity
    high_controls = @client.fetch_controls_by_severity(title, version, release, 'high')
    assert_equal 2, high_controls.size
    assert_equal 'High 1', high_controls[0].title
    assert_equal 'High 2', high_controls[1].title

    # Filter medium severity (case insensitive)
    medium_controls = @client.fetch_controls_by_severity(title, version, release, 'MEDIUM')
    assert_equal 1, medium_controls.size
    assert_equal 'Medium 1', medium_controls[0].title
  end
end
