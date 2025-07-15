# OpenAPI Specification Changelog

All notable changes to the cyber.trackr.live OpenAPI specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and the OpenAPI specification uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-15

### Added
- Initial OpenAPI 3.1.1 specification for cyber.trackr.live API
- Complete endpoint documentation for STIG/SRG access
- Document listing and retrieval endpoints
- Individual requirement endpoints
- Comprehensive schema definitions with examples
- Server variables for different environments
- Operation IDs for clean client generation
- Links between related operations
- Code examples for multiple languages

### Known Issues
- API returns `text/html` Content-Type for some JSON responses (server bug)
- Some date fields may contain leading spaces
- Requirements endpoint returns object format, not array