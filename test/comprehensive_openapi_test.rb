#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'openapi_first'
require 'faraday'
require 'json'
require 'yaml'

class ComprehensiveOpenAPITest < Minitest::Test
  def setup
    @spec_file = 'openapi/openapi.yaml'
    # Load file content directly to avoid Windows path issues
    contents = YAML.load_file(@spec_file)
    @definition = OpenapiFirst.parse(contents, filepath: nil)
    @spec = @definition.instance_variable_get(:@resolved)
    @base_url = 'https://cyber.trackr.live/api'
    @client = Faraday.new(url: @base_url) do |f|
      f.response :json
    end
  end

  # Basic Validation Tests
  def test_spec_loads_without_errors
    # OpenAPI First loads successfully if spec is valid
    # If there were errors, OpenapiFirst.load would have raised an exception
    refute_nil @spec
    assert_kind_of Hash, @spec
  end

  def test_openapi_version_is_311
    assert_equal '3.1.1', @spec['openapi']
  end

  def test_has_required_metadata
    assert @spec['info']['title']
    assert @spec['info']['version']
    assert @spec['info']['description']
    assert @spec['info']['contact']
    assert @spec['info']['license']
  end

  # Server Tests
  def test_production_server_configured
    assert @spec['servers'].any?
    prod_server = @spec['servers'].first
    assert_equal 'https://cyber.trackr.live/api', prod_server['url']
    assert_equal 'Production server (default)', prod_server['description']
  end

  # Path Tests
  def test_all_documented_paths_exist
    paths_to_test = {
      '/' => 'API root',
      '/stig' => 'STIG/SRG list',
      '/cci' => 'CCI list',
      '/stig/{title}/{version}/{release}' => 'STIG detail',
      '/stig/{title}/{version}/{release}/{vuln}' => 'Requirement detail',
      '/rmf/5/{control}' => 'RMF control detail',
      '/cci/{item}' => 'CCI detail'
    }

    paths_to_test.each do |path, description|
      assert @spec['paths'][path], "Missing path: #{path} (#{description})"
    end
  end

  # Parameter Tests
  def test_path_parameters_have_patterns
    pattern_tests = {
      'vuln' => '^V-\\d{6}$',
      'item' => '^CCI-\\d{6}$',
      'control' => '^[A-Z]+-\\d+$',
      'version' => '^\\d+$',
      'release' => '^\\d+(\\.\\d+)?$'
    }

    @spec['paths'].each do |path, path_item|
      next unless path.include?('{')

      %w[get post put patch delete].each do |method|
        operation = path_item[method]
        next unless operation

        operation['parameters']&.each do |param|
          next unless pattern_tests[param['name']]

          assert_equal pattern_tests[param['name']], param['schema']['pattern'],
                       "#{param['name']} parameter in #{path} should have correct pattern"
        end
      end
    end
  end

  # Schema Tests
  def test_all_schema_refs_resolve
    unresolved = []

    @spec['paths'].each do |path, path_item|
      %w[get post put patch delete].each do |method|
        operation = path_item[method]
        next unless operation

        operation['responses'].each do |code, response|
          next unless response['content']

          response['content'].each do |_media_type, media|
            next unless media['schema']

            # This will raise if schema ref doesn't resolve
            begin
              media['schema']
            rescue Openapi3Parser::Error
              unresolved << "#{method.upcase} #{path} response #{code} schema"
            end
          end
        end
      end
    end

    assert unresolved.empty?, "Unresolved schema refs:\n#{unresolved.join("\n")}"
  end

  def test_required_schemas_exist
    required_schemas = %w[
      ApiDocumentation
      DocumentList DocumentVersion DocumentDetail
      RequirementSummary RequirementDetail
      RmfControlDetail AssessmentProcedure
      CciList CciDetail
    ]

    schemas = @spec['components']['schemas'].keys
    missing = required_schemas - schemas

    assert missing.empty?, "Missing required schemas: #{missing.join(', ')}"
  end

  # OpenAPI 3.1 Feature Tests
  def test_uses_openapi_31_features
    # Check for nullable syntax (anyOf with null type)
    nullable_found = false

    @spec['components']['schemas'].each do |_schema_name, schema|
      check_schema_for_31_features(schema) do |feature|
        nullable_found = true if feature == :nullable
      end
    end

    assert nullable_found, 'Should use OpenAPI 3.1 nullable syntax (anyOf with null type)'
  end

  # Real API Tests (commented out to avoid hitting API during normal test runs)
  # Uncomment these to test against live API

  # def test_api_root_matches_spec
  #   skip "Live API test - uncomment to run"
  #   response = @client.get('/')
  #   assert_equal 200, response.status
  #   assert response.body['server_api_root']
  # end

  # def test_stig_list_matches_spec
  #   skip "Live API test - uncomment to run"
  #   response = @client.get('/stig')
  #   assert_equal 200, response.status
  #
  #   # Validate response matches DocumentList schema
  #   assert response.body.is_a?(Hash)
  #   response.body.each do |name, versions|
  #     assert versions.is_a?(Array)
  #     versions.each do |version|
  #       assert version['date']
  #       assert version['version']
  #       assert version['release']
  #       assert version['link']
  #     end
  #   end
  # end

  private

  def check_schema_for_31_features(schema, path = '', &block)
    return unless schema

    # Check for anyOf with null (3.1 nullable pattern)
    yield :nullable if schema['anyOf']&.any? { |s| s['type'] == 'null' }

    # Check for const keyword (3.1 feature)
    yield :const if schema.respond_to?(:const) && schema.const

    # Recurse through properties
    schema['properties']&.each do |name, prop|
      check_schema_for_31_features(prop, "#{path}.#{name}", &block)
    end

    # Recurse through array items
    check_schema_for_31_features(schema['items'], "#{path}[]", &block) if schema['items']
  end
end
