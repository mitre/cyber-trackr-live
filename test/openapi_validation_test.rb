#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'openapi_first'
require 'yaml'

class OpenAPIValidationTest < Minitest::Test
  def setup
    @spec_file = 'openapi/openapi.yaml'
    # Load file content directly to avoid Windows path issues
    contents = YAML.load_file(@spec_file)
    @definition = OpenapiFirst.parse(contents, filepath: nil)
    @spec = @definition.instance_variable_get(:@resolved)
  end

  def test_spec_is_valid
    # OpenAPI First loads successfully if spec is valid
    # If there were errors, OpenapiFirst.load would have raised an exception
    refute_nil @spec
    assert_kind_of Hash, @spec
  end

  def test_openapi_version
    assert_equal '3.1.1', @spec['openapi'], 'Should use OpenAPI 3.1.1'
  end

  def test_has_required_info
    info = @spec['info']
    assert info['title'], 'Should have title'
    assert info['version'], 'Should have version'
    assert info['description'], 'Should have description'
  end

  def test_has_servers
    assert @spec['servers'].any?, 'Should have at least one server'
    assert_equal 'https://cyber.trackr.live/api', @spec['servers'].first['url']
  end

  def test_all_paths_have_operations
    @spec['paths'].each do |path, path_item|
      operations = %w[get post put patch delete head options trace].select { |op| path_item.key?(op) }
      assert operations.any?, "Path #{path} should have at least one operation"
    end
  end

  def test_parameter_patterns
    # Check inline parameters for pattern validation
    vuln_endpoints = [
      '/stig/{title}/{version}/{release}/{vuln}',
      '/scap/{title}/{version}/{release}/{vuln}'
    ]

    vuln_endpoints.each do |path|
      path_item = @spec['paths'][path]
      next unless path_item

      get_op = path_item['get']
      vuln_param = get_op['parameters']&.find { |p| p['name'] == 'vuln' }

      assert vuln_param, "#{path} should have vuln parameter"
      assert_equal '^V-\\d{6}$', vuln_param['schema']['pattern'], 'Vuln parameter should have correct pattern'
    end

    # Check CCI parameter pattern
    cci_path = @spec['paths']['/cci/{item}']
    if cci_path
      get_op = cci_path['get']
      item_param = get_op['parameters']&.find { |p| p['name'] == 'item' }

      assert item_param, 'CCI endpoint should have item parameter'
      assert_equal '^CCI-\\d{6}$', item_param['schema']['pattern'], 'CCI parameter should have correct pattern'
    end
  end

  def test_all_operations_have_responses
    @spec['paths'].each do |path, path_item|
      %w[get post put patch delete].each do |method|
        operation = path_item[method]
        next unless operation

        assert operation['responses']&.any?, "#{method.upcase} #{path} should have responses"
        assert operation['responses']['200'], "#{method.upcase} #{path} should have 200 response"
      end
    end
  end

  def test_response_schemas_exist
    required_schemas = %w[
      DocumentList DocumentDetail RequirementDetail
      RmfControlList RmfControlDetail CciList CciDetail
    ]

    schemas = @spec['components']['schemas']
    required_schemas.each do |schema_name|
      assert schemas[schema_name], "Should have #{schema_name} schema"
    end
  end

  def test_nullable_fields_use_openapi31_syntax
    # Find all schemas with nullable fields
    nullable_count = 0

    @spec['components']['schemas'].each do |name, schema|
      check_nullable_syntax(schema, name) do
        nullable_count += 1
      end
    end

    assert nullable_count.positive?, 'Should have at least one nullable field using OpenAPI 3.1 syntax'
  end

  private

  def check_nullable_syntax(schema, path = '', &block)
    return unless schema

    # Check if this schema uses anyOf with null type (OpenAPI 3.1 syntax)
    yield if schema['anyOf']&.any? { |s| s['type'] == 'null' } && block_given?

    # Recursively check properties
    schema['properties']&.each do |prop_name, prop_schema|
      check_nullable_syntax(prop_schema, "#{path}.#{prop_name}", &block)
    end

    # Check array items
    check_nullable_syntax(schema['items'], "#{path}[]", &block) if schema['items']
  end
end
