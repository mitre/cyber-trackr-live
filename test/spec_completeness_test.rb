#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'openapi_first'
require 'yaml'
require_relative '../lib/openapi_first_windows_fix'

class SpecCompletenessTest < Minitest::Test
  def setup
    @spec_file = 'openapi/openapi.yaml'
    # Load file content directly to avoid Windows path issues
    contents = YAML.load_file(@spec_file)
    @definition = OpenapiFirst.parse(contents, filepath: nil)
    @spec = @definition.instance_variable_get(:@resolved)
  end

  def test_all_required_endpoints_exist
    required_endpoints = [
      # API Documentation
      '/',

      # STIG/SRG endpoints
      '/stig',
      '/stig/{title}/{version}/{release}',
      '/stig/{title}/{version}/{release}/{vuln}',

      # SCAP endpoints
      '/scap',
      '/scap/{title}/{version}/{release}',
      '/scap/{title}/{version}/{release}/{vuln}',

      # RMF endpoints
      '/rmf/4',
      '/rmf/5',
      '/rmf/4/{control}',
      '/rmf/5/{control}',

      # CCI endpoints
      '/cci',
      '/cci/{item}'
    ]

    actual_endpoints = @spec['paths'].keys
    missing = required_endpoints - actual_endpoints

    assert missing.empty?, "Missing required endpoints:\n#{missing.join("\n")}"
  end

  def test_all_required_schemas_exist
    required_schemas = [
      # Core schemas
      'ApiDocumentation',
      'Error',

      # Document schemas
      'DocumentList',
      'DocumentVersion',
      'DocumentDetail',

      # Requirement schemas
      'RequirementSummary',
      'RequirementDetail',

      # RMF schemas
      'RmfControlList',
      'RmfControlDetail',
      'AssessmentProcedure',

      # CCI schemas
      'CciList',
      'CciDetail'
    ]

    actual_schemas = @spec['components']['schemas'].keys
    missing = required_schemas - actual_schemas

    assert missing.empty?, "Missing required schemas:\n#{missing.join("\n")}"
  end

  def test_all_endpoints_have_required_responses
    @spec['paths'].each do |path, path_item|
      %w[get post put patch delete].each do |method|
        operation = path_item[method]
        next unless operation

        # All endpoints should have 200 response
        assert operation['responses']['200'],
               "#{method.upcase} #{path} missing 200 response"

        # All endpoints should have response content
        response_200 = operation['responses']['200']
        assert response_200['content'],
               "#{method.upcase} #{path} 200 response missing content"

        # All responses should have JSON content
        assert response_200['content']['application/json'],
               "#{method.upcase} #{path} 200 response missing application/json content"
      end
    end
  end

  def test_all_tags_are_used
    defined_tags = @spec['tags'].map { |tag| tag['name'] }
    used_tags = []

    @spec['paths'].each do |_path, path_item|
      %w[get post put patch delete].each do |method|
        operation = path_item[method]
        next unless operation

        used_tags.concat(operation['tags']) if operation['tags']
      end
    end

    used_tags.uniq!
    unused = defined_tags - used_tags

    assert unused.empty?, "Unused tags defined: #{unused.join(', ')}"
  end

  def test_parameter_patterns_are_consistent
    param_patterns = {
      'vuln' => '^V-\\d{6}$',
      'item' => '^CCI-\\d{6}$',
      'control' => '^[A-Z]+-\\d+$',
      'version' => '^\\d+$',
      'release' => '^\\d+(\\.\\d+)?$'
    }

    @spec['paths'].each do |path, path_item|
      %w[get post put patch delete].each do |method|
        operation = path_item[method]
        next unless operation

        operation['parameters']&.each do |param|
          expected_pattern = param_patterns[param['name']]
          next unless expected_pattern

          actual_pattern = param['schema']['pattern']
          assert_equal expected_pattern, actual_pattern,
                       "Parameter '#{param['name']}' in #{method.upcase} #{path} has inconsistent pattern"
        end
      end
    end
  end

  def test_spec_metadata_is_complete
    info = @spec['info']

    assert info['title'], 'Missing info.title'
    assert info['description'], 'Missing info.description'
    assert info['version'], 'Missing info.version'
    assert info['contact'], 'Missing info.contact'
    assert info['contact']['name'], 'Missing info.contact.name'
    assert info['contact']['url'], 'Missing info.contact.url'
    assert info['license'], 'Missing info.license'
    assert info['license']['name'], 'Missing info.license.name'
    assert info['license']['url'], 'Missing info.license.url'
  end

  def test_example_values_are_realistic
    # Check that examples make sense for their context
    @spec['components']['schemas'].each do |name, schema|
      check_examples(schema, name)
    end
  end

  private

  def check_examples(schema, path)
    return unless schema

    if schema['example']
      case schema['type']
      when 'string'
        if schema['pattern']
          begin
            regex = Regexp.new(schema['pattern'])
            assert schema['example'].match?(regex),
                   "Example '#{schema['example']}' at #{path} doesn't match pattern #{schema['pattern']}"
          rescue RegexpError
            # Skip invalid regex patterns
          end
        end
      when 'array'
        assert schema['example'].is_a?(Array),
               "Example at #{path} should be an array"
      end
    end

    # Recurse
    schema['properties']&.each do |name, prop|
      check_examples(prop, "#{path}.#{name}")
    end

    check_examples(schema['items'], "#{path}[]") if schema['items']
  end
end
