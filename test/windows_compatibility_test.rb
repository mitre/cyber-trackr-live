#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'openapi_first'
require 'yaml'

class WindowsCompatibilityTest < Minitest::Test
  def setup
    @spec_file = 'openapi/openapi.yaml'
    @contents = YAML.load_file(@spec_file)
  end

  def test_openapi_first_parse_with_nil_filepath_works
    # This test ensures we don't regress to the broken Windows path handling
    # by accidentally using a filepath parameter that causes URI::InvalidComponentError

    # Our working approach - should always work
    definition = OpenapiFirst.parse(@contents, filepath: nil)
    assert_instance_of OpenapiFirst::Definition, definition
    assert_equal 'Cyber Trackr API', definition['info']['title']
  end

  def test_openapi_first_parse_with_windows_style_path_fails
    # This test documents the known issue in openapi_first gem
    # If this test starts passing, it means the upstream bug was fixed

    # Simulate Windows absolute path that causes the bug
    windows_path = 'D:/a/cyber-trackr-live/cyber-trackr-live/openapi/openapi.yaml'

    # On non-Windows systems, this might work, but on Windows it fails
    # We test this to ensure we're aware when the upstream bug is fixed
    if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
      # On Windows, this should fail with URI::InvalidComponentError
      assert_raises(URI::InvalidComponentError) do
        OpenapiFirst.parse(@contents, filepath: windows_path)
      end
    else
      # On non-Windows, this might work but we document the issue
      # This test serves as documentation of the cross-platform issue
      result = OpenapiFirst.parse(@contents, filepath: windows_path)
      assert_instance_of OpenapiFirst::Definition, result
    end
  end

  def test_all_test_files_use_filepath_nil_workaround
    # Ensure all our test files use the filepath: nil workaround
    test_files = [
      'test/openapi_validation_test.rb',
      'test/spec_completeness_test.rb',
      'test/comprehensive_openapi_test.rb'
    ]

    test_files.each do |file|
      content = File.read(file)

      # Should use OpenapiFirst.parse with filepath: nil
      assert_match(/OpenapiFirst\.parse\(.*filepath:\s*nil/, content,
                   "#{file} should use 'filepath: nil' to avoid Windows path issues")

      # Should NOT use OpenapiFirst.load (which uses filepath internally)
      refute_match(/OpenapiFirst\.load\(/, content,
                   "#{file} should not use OpenapiFirst.load (causes Windows path issues)")
    end
  end

  def test_workaround_preserves_functionality
    # Ensure our workaround doesn't break expected functionality
    definition = OpenapiFirst.parse(@contents, filepath: nil)

    # Should still have all the expected OpenAPI spec content
    assert_equal '3.1.1', definition['openapi']
    assert_equal 'Cyber Trackr API', definition['info']['title']
    assert_includes definition['paths'].keys, '/stig'
    assert_includes definition['paths'].keys, '/cci'

    # Should still be able to validate (this exercises the internal URI handling)
    # This internally uses the base_uri that was causing the Windows issue
    router = definition.instance_variable_get(:@router)
    assert_instance_of OpenapiFirst::Router, router
  end
end
