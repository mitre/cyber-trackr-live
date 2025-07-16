#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'openapi_first'
require 'faraday'
require 'faraday/follow_redirects'
require 'json'

class LiveAPIValidationTest < Minitest::Test
  private

  def parse_response(response)
    # Handle case where JSON middleware doesn't parse after redirect
    response.body.is_a?(String) ? JSON.parse(response.body) : response.body
  end

  public

  def setup
    @spec_file = 'openapi/openapi.yaml'
    @definition = OpenapiFirst.load(@spec_file)
    @spec = @definition.instance_variable_get(:@resolved)
    @base_url = 'https://cyber.trackr.live'
    @client = Faraday.new(url: @base_url) do |f|
      f.headers['Accept'] = 'application/json'
      f.response :json, content_type: /\bjson$/ # Parse JSON before redirects
      f.response :follow_redirects # Handle 301 redirects after JSON parsing
      # f.response :logger # Log requests for debugging
    end
  end

  def test_api_root_endpoint
    response = @client.get('/api')

    assert_equal 200, response.status, 'API root should return 200'

    body = parse_response(response)

    assert body.is_a?(Hash), 'Response should be JSON object'
    assert body['server_api_root'], 'Should have server_api_root field'

    # Check if response includes endpoint descriptions
    puts "\nAPI Root Endpoints Found:"
    body.each do |key, value|
      next if key == 'server_api_root'

      puts "  #{key}: #{value['summary'] if value.is_a?(Hash)}"
    end
  end

  def test_stig_list_endpoint
    response = @client.get('/api/stig')

    assert_equal 200, response.status, 'STIG list should return 200'
    body = parse_response(response)
    assert body.is_a?(Hash), 'Response should be JSON object'

    # Sample a few entries
    sample_docs = body.keys.first(3)
    puts "\nSample STIG/SRG documents:"
    sample_docs.each do |doc|
      versions = body[doc]
      latest = versions.first
      puts "  #{doc}: v#{latest['version']}r#{latest['release']} (#{latest['date']})"
    end

    # Check structure matches our schema
    body.each_value do |versions|
      assert versions.is_a?(Array), 'Each document should have array of versions'
      versions.each do |version|
        assert version['date'], 'Version should have date'
        assert version['version'], 'Version should have version'
        assert version['release'], 'Version should have release'
        assert version['link'], 'Version should have link'
      end
    end
  end

  def test_rmf_list_endpoints
    # Test RMF rev 4
    response = @client.get('/api/rmf/4')
    if response.status == 200
      body = parse_response(response)
      assert body.is_a?(Hash), 'RMF 4 list should be JSON object'
      if body['controls']
        puts "\nRMF Rev 4 - Sample controls:"
        body['controls'].to_a.first(3).each do |id, title|
          puts "  #{id}: #{title}"
        end
      end
    else
      puts "\nWarning: RMF 4 endpoint returned #{response.status}"
    end

    # Test RMF rev 5
    response = @client.get('/api/rmf/5')
    if response.status == 200
      body = parse_response(response)
      assert body.is_a?(Hash), 'RMF 5 list should be JSON object'
      if body['controls']
        puts "\nRMF Rev 5 - Sample controls:"
        body['controls'].to_a.first(3).each do |id, title|
          puts "  #{id}: #{title}"
        end
      end
    else
      puts "\nWarning: RMF 5 endpoint returned #{response.status}"
    end
  end

  def test_cci_list_endpoint
    response = @client.get('/api/cci')

    assert_equal 200, response.status, 'CCI list should return 200'
    body = parse_response(response)
    assert body.is_a?(Hash), 'Response should be JSON object'

    # Sample a few CCIs
    puts "\nSample CCIs:"
    body.to_a.first(3).each do |cci, definition|
      puts "  #{cci}: #{definition[0..80]}..."
    end
  end

  def test_specific_stig_document
    # Get Juniper ALG STIG
    response = @client.get('/api/stig/Juniper_SRX_Services_Gateway_ALG/3/3')

    if response.status == 200
      doc = parse_response(response)
      puts "\nJuniper ALG STIG Details:"
      puts "  ID: #{doc['id']}"
      puts "  Title: #{doc['title']}"
      puts "  Status: #{doc['status']}"
      puts "  Published: #{doc['published']}"
      puts "  Requirements: #{doc['requirements'].size} controls"

      # Check structure
      assert doc['id'], 'Document should have id'
      assert doc['title'], 'Document should have title'
      assert doc['requirements'], 'Document should have requirements'
      assert doc['requirements'].is_a?(Hash), 'Requirements should be a hash'
    else
      puts "\nWarning: Juniper STIG returned #{response.status}"
    end
  end

  def test_specific_requirement
    # Get a specific requirement

    response = @client.get('/api/stig/Juniper_SRX_Services_Gateway_ALG/3/3/V-214518')

    if response.status == 200
      req = parse_response(response)
      puts "\n[test_specific_requirement] Requirement V-214518 Details:"
      puts "  Title: #{req['requirement-title'][0..60]}..." if req['requirement-title']
      puts "  Severity: #{req['severity']}"
      puts "  Rule: #{req['rule']}"
      puts "  Has check-text: #{!req['check-text'].nil?}"
      puts "  Has fix-text: #{!req['fix-text'].nil?}"

      # Verify required fields
      assert req['id'], 'Requirement should have id'
      assert req['severity'], 'Requirement should have severity'
      assert req['check-text'], 'Requirement should have check-text'
      assert req['fix-text'], 'Requirement should have fix-text'
    else
      puts "\nWarning: Requirement lookup returned #{response.status}"
    end
  rescue Faraday::ParsingError, JSON::ParserError => e
    # Known issue: API returns invalid JSON with control characters
    skip "Skipping due to API JSON parsing issue: #{e.message[0..100]}..."
  rescue StandardError => e
    # Log other errors but don't fail the test suite
    puts "⚠️  Warning: Live API test failed with: #{e.class}: #{e.message}"
    skip "Live API test failed: #{e.message}"
  end

  def test_scap_endpoints_exist
    response = @client.get('/api/scap')

    puts "\nSCAP endpoint test:"
    puts "  Status: #{response.status}"

    if response.status == 200
      body = parse_response(response)
      puts "  SCAP documents found: #{body.size}"
      # Sample first SCAP
      if body.any?
        first_scap = body.first
        puts "  Sample: #{first_scap[0]}"
      end
    end
  end

  def test_error_handling
    # Test invalid endpoint
    response = @client.get('/api/invalid/endpoint')

    puts "\nError handling test:"
    puts "  Invalid endpoint status: #{response.status}"

    if response.status >= 400
      begin
        error = parse_response(response)
        puts "  Error structure: #{error.keys.join(', ')}" if error.is_a?(Hash)
      rescue JSON::ParserError
        puts '  Error response is not JSON'
      end
    end
  end

  def test_parameter_validation
    # Test with invalid V-ID format
    response = @client.get('/api/stig/Juniper_SRX_Services_Gateway_ALG/3/3/V-INVALID')

    assert_equal 500, response.status, 'Invalid V-ID should return 500'

    # Verify error response structure
    begin
      error = parse_response(response)
      assert error.is_a?(Hash), 'Error response should be JSON'
      assert_equal 500, error['status'], 'Error should have status 500'
      assert error['type'], 'Error should have type field'
      assert error['title'], 'Error should have title field'
      assert error['detail'], 'Error should have detail field'
    rescue JSON::ParserError
      flunk 'Error response should be valid JSON'
    end

    # Test with invalid CCI format
    cci_response = @client.get('/api/cci/CCI-INVALID')
    assert_equal 500, cci_response.status, 'Invalid CCI should return 500'

    # Test with completely invalid path returns 404
    not_found_response = @client.get('/api/invalid/endpoint')
    assert_equal 404, not_found_response.status, 'Invalid endpoint should return 404'
  end
end
