# Development Guide

This section covers development and implementation details for the cyber.trackr.live OpenAPI project.

## Getting Started

- **[OpenAPI Development](./openapi-development.md)** - Working with the OpenAPI specification
- **[API Testing](./api-testing.md)** - Testing approaches and strategies

## Architecture

- **[Two-Tier Testing](./architecture/two-tier-testing.md)** - Separation of spec validation and behavior testing
- **[Faraday Migration](./architecture/faraday-migration.md)** - Windows compatibility through HTTP client migration
- **[Windows Compatibility](./architecture/windows-compatibility.md)** - Cross-platform development considerations
- **[Validation Cleanup](./architecture/validation-cleanup.md)** - Removing duplicate validation layers

## Key Principles

1. **OpenAPI-First**: Specification drives all generated artifacts
2. **Separation of Concerns**: Different tools for different validation layers
3. **Cross-Platform**: Solutions work on Windows, macOS, and Linux
4. **Automation**: Minimize manual processes through tooling