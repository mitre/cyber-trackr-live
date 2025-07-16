# frozen_string_literal: true

# Windows compatibility fix for openapi_first gem
#
# The openapi_first gem fails on Windows because it uses File.absolute_path()
# which returns paths with drive letters (D:/path) that URI::File.build()
# cannot handle properly.
#
# This monkey patch fixes the issue by normalizing Windows paths to use
# forward slashes and removing the drive letter when building URIs.

require 'openapi_first'

module OpenapiFirst
  class Builder
    private

    def build_schemer_config(filepath:, meta_schema:)
      result = JSONSchemer.configuration.clone

      # Windows path fix: normalize the directory path for URI building
      dir = if filepath
              File.absolute_path(File.dirname(filepath))
            else
              Dir.pwd
            end

      # Convert Windows paths to URI-compatible format
      # Remove drive letter and normalize slashes for all platforms
      normalized_dir = dir.gsub('\\', '/').gsub(/^[A-Za-z]:/, '')

      # Ensure we have a leading slash for absolute paths
      normalized_dir = "/#{normalized_dir}" unless normalized_dir.start_with?('/')

      result.base_uri = URI::File.build({ path: "#{normalized_dir}/" })
      result.ref_resolver = JSONSchemer::CachedResolver.new do |uri|
        FileLoader.load(uri.path)
      end
      result.meta_schema = meta_schema
      result.insert_property_defaults = true
      result
    end
  end
end
