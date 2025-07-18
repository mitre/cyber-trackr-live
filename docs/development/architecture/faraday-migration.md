# Faraday Migration for Windows Compatibility

## Overview

This document explains the migration from `typhoeus` to `faraday` HTTP client to resolve Windows CI/CD compatibility issues.

## Problem

The original OpenAPI-generated Ruby client used the `typhoeus` gem, which depends on `libcurl`. This created platform-specific issues:

- **Windows CI/CD failures**: `Could not open library 'libcurl'` errors on GitHub Actions Windows runners
- **Complex dependency management**: Required external system libraries
- **Platform inconsistencies**: Different behavior across Windows, macOS, and Linux

## Solution: Faraday Migration

### Why Faraday?

1. **Pure Ruby**: Uses built-in `Net::HTTP`, no external dependencies
2. **Cross-platform**: Identical behavior on all platforms
3. **OpenAPI Generator support**: Native support with `--library=faraday`
4. **Extensible**: Rich middleware ecosystem for custom requirements

### Implementation

```bash
# Updated client generation command
docker run --rm \
  -v "${PWD}:/local" \
  openapitools/openapi-generator-cli generate \
  -i /local/openapi/openapi.yaml \
  -g ruby \
  -o /local/generated-client \
  --library=faraday \
  --additional-properties=gemName=cyber_trackr_client,moduleName=CyberTrackrClient
```

### Updated Dependencies

```ruby
# Runtime dependencies in gemspec
spec.add_dependency 'faraday', '~> 2.0'
spec.add_dependency 'faraday-multipart', '~> 1.0'  
spec.add_dependency 'faraday-follow_redirects', '~> 0.3'
spec.add_dependency 'marcel', '~> 1.0'
```

## Results

- ✅ **100% CI/CD success**: All platforms (Windows, macOS, Linux) now pass
- ✅ **Simplified dependencies**: No external system requirements
- ✅ **Consistent behavior**: Identical HTTP handling across platforms
- ✅ **Maintainable**: Standard Ruby ecosystem patterns

## Key Learning

This migration demonstrates how choosing pure Ruby solutions over native dependencies can eliminate entire categories of platform compatibility issues, making the project more maintainable and reliable across diverse deployment environments.