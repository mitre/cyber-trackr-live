# frozen_string_literal: true

# Add lib to load path
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'minitest/autorun'
require 'json'

# WebMock is loaded only by tests that need it (cyber_trackr_helper_test.rb)
# Live integration tests should NOT load WebMock to allow real HTTP requests

# Test helper for Cyber Trackr API tests
module TestHelper
  # Sample STIG document list response
  def sample_document_list
    {
      'Juniper_SRX_Services_Gateway_ALG' => [
        {
          'version' => '3',
          'release' => '3',
          'date' => '2024-12-19',
          'link' => '/stig/Juniper_SRX_Services_Gateway_ALG/3/3',
          'released' => ' 19 Dec 2024'
        },
        {
          'version' => '2',
          'release' => '1',
          'date' => '2023-01-01',
          'link' => '/stig/Juniper_SRX_Services_Gateway_ALG/2/1',
          'released' => ' 01 Jan 2023'
        }
      ],
      'Application_Security_Requirements_Guide' => [
        {
          'version' => '5',
          'release' => '4',
          'date' => '2024-01-25',
          'link' => '/stig/Application_Security_Requirements_Guide/5/4',
          'released' => ' 25 Jan 2024'
        }
      ],
      'Windows_10' => [
        {
          'version' => '3',
          'release' => '2',
          'date' => '2024-01-01',
          'link' => '/stig/Windows_10/3/2',
          'released' => ' 01 Jan 2024'
        }
      ],
      'Network_Security_Requirements_Guide' => [
        {
          'version' => '1',
          'release' => '8',
          'date' => '2024-06-27',
          'link' => '/stig/Network_Security_Requirements_Guide/1/8',
          'released' => ' 27 Jun 2024'
        }
      ]
    }
  end

  # Sample document detail response
  def sample_document_detail(id: 'Juniper_SRX_SG_ALG_STIG', num_requirements: 24)
    {
      'id' => id,
      'title' => 'Juniper SRX Services Gateway ALG Security Technical Implementation Guide',
      'version' => '3',
      'release' => '3',
      'status' => 'accepted',
      'published' => '2024-12-19',
      'description' => 'This Security Technical Implementation Guide provides guidance for Juniper SRX Services Gateway ALG devices.', # Required field
      'notice' => 'Developed by DISA',
      'release_date' => '2024-12-19',
      'filename' => 'U_Juniper_SRX_SG_ALG_V3R3_Manual-xccdf.xml',
      'requirements' => (1..num_requirements).each_with_object({}) do |i, hash|
        v_id = "V-#{214_517 + i}"
        hash[v_id] = {
          'title' => "Requirement #{i}",
          'rule' => "SV-#{214_517 + i}r997541_rule",
          'severity' => %w[high medium low].sample,
          'link' => "/stig/#{id}/3/3/#{v_id}"
        }
      end
    }
  end

  # Sample requirement detail response
  def sample_requirement_detail(vuln_id)
    {
      'id' => vuln_id,
      'severity' => 'medium',
      'requirement-title' => 'The Juniper SRX must be configured to protect against TCP SYN floods',
      'check-text' => 'Verify the device is configured to protect against SYN floods...',
      'fix-text' => 'Configure the device to protect against SYN floods...',
      'rule' => "SV-#{vuln_id.sub('V-', '')}r997541_rule",
      'identifiers' => ['CCIRef:CCI-000213', 'CCIRef:CCI-001094'],
      'mitigation-statement' => nil
    }
  end

  # Mock the documents list endpoint
  def mock_documents_list(documents = sample_document_list)
    stub_request(:get, 'https://cyber.trackr.live/api/stig')
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: documents.to_json
      )
  end

  # Mock a specific document endpoint
  def mock_document(title, version, release, response = nil)
    response ||= sample_document_detail

    stub_request(:get, "https://cyber.trackr.live/api/stig/#{title}/#{version}/#{release}")
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: response.to_json
      )
  end

  # Mock a specific requirement endpoint
  def mock_requirement(title, version, release, vuln_id, response = nil)
    response ||= sample_requirement_detail(vuln_id)

    stub_request(:get, "https://cyber.trackr.live/api/stig/#{title}/#{version}/#{release}/#{vuln_id}")
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: response.to_json
      )
  end
end
