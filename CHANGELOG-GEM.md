---
title: Ruby Gem Changelog
description: Version history and changes for the cyber_trackr_live Ruby gem
---

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial OpenAPI 3.1.1 specification for cyber.trackr.live API
- Ruby client generated from OpenAPI specification
- Helper utilities for common API operations
- RuboCop custom cop for Content-Type header workaround
- Comprehensive test suite with minitest
- Examples for basic usage and STIG fetching
- Post-generation fix workflow for client code
- Documentation for API usage and development

### Fixed
- Content-Type header issue where API returns text/html for JSON responses
- Automatic detection and handling of HTML responses with JSON body

## [1.0.0] - TBD

### Added
- Complete OpenAPI specification covering all cyber.trackr.live endpoints
- Generated Ruby client with full API coverage
- Helper methods for fetching complete STIGs and requirements
- Documentation and examples