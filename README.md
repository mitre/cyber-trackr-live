# cyber-trackr-live

OpenAPI specification and Ruby client for the [cyber.trackr.live](https://cyber.trackr.live) API - providing programmatic access to DISA STIGs, SRGs, RMF controls, CCIs, and SCAP data.

## 🎯 Overview

This repository contains:
- **OpenAPI 3.1.1 Specification** - Complete API documentation for cyber.trackr.live
- **Ruby Client Library** - Generated client with helper utilities
- **Documentation** - Interactive API docs via Scalar
- **Examples** - Usage examples for common workflows

## 📚 Quick Links

- [API Documentation](https://mitre.github.io/cyber-trackr-live/) - Interactive Scalar docs
- [Ruby Gem](https://rubygems.org/gems/cyber_trackr_live) - Install with `gem install cyber_trackr_live`
- [OpenAPI Spec](openapi/openapi.yaml) - OpenAPI 3.1.1 specification
- [API Changelog](CHANGELOG-OPENAPI.md) - API specification changes
- [Gem Changelog](CHANGELOG-GEM.md) - Ruby client changes

## 💎 Installation

### Ruby Gem

```bash
gem install cyber_trackr_live
```

Or add to your Gemfile:

```ruby
gem 'cyber_trackr_live'
```

See [README-GEM.md](README-GEM.md) for detailed Ruby usage instructions.

### Using the OpenAPI Spec

The OpenAPI specification can be used to generate clients in other languages:

```bash
# Example: Generate a Python client
docker run --rm \
  -v "${PWD}:/local" \
  openapitools/openapi-generator-cli generate \
  -i /local/openapi/openapi.yaml \
  -g python \
  -o /local/generated/python
```

## 🔗 DISA Ecosystem Overview

The cyber.trackr.live API provides access to the complete DISA cybersecurity compliance hierarchy:

```
NIST RMF Controls (high-level policy framework)
    ↓ (decomposed into atomic, testable statements)
CCIs (Control Correlation Identifiers - bridge policy to implementation)
    ↓ (grouped by technology class into generic requirements)
SRGs (Security Requirements Guides - technology class "what" to do)
    ↓ (implemented as vendor-specific "how" to do it)
STIGs (Security Technical Implementation Guides - vendor/product specific)
    ↓ (automated versions for scanning tools)
SCAP (Security Content Automation Protocol documents)
```

### Key ID Types

- **V-IDs**: `V-214518` - Legacy "Vulnerability IDs", actually requirement identifiers
- **SV-IDs**: `SV-214518r997541_rule` - XCCDF rule IDs with revision tracking
- **SRG-IDs**: `SRG-NET-000015-ALG-000016` - Security Requirements Guide groupings
- **CCI-IDs**: `CCI-000213` - Control Correlation Identifiers (map to RMF controls)
- **RMF Controls**: `AC-1`, `AU-2` - Risk Management Framework controls

## 📊 API Scale & Coverage

- **1000+ STIG/SRG documents** 
- **3000+ Control Correlation Identifiers (CCIs)**
- **100+ RMF controls** in revisions 4 and 5
- **87 SCAP documents** for automated scanning
- **Complete cross-reference mappings** between all document types

## 🛠️ Development

### Prerequisites

- Ruby 3.3+ (see `.ruby-version`)
- Node.js 22+ (see `.nvmrc`)
- Docker (for client generation)

### Setup

```bash
# Clone the repository
git clone https://github.com/mitre/cyber-trackr-live.git
cd cyber-trackr-live

# Install Ruby dependencies
bundle install

# Install Node dependencies for docs (optional - only for OpenAPI docs)
npm install
```

### Development Workflows

#### Working on the OpenAPI Specification

```bash
# Validate the OpenAPI spec (using Spectral)
npm run docs:validate

# Preview API docs locally
npm run docs:dev
# Opens at http://localhost:4000

# Regenerate Ruby client after spec changes
make generate
```

#### Ruby Development

```bash
# Run tests before committing
make test

# Run linting
bundle exec rubocop

# Test the gem build
gem build cyber_trackr_live.gemspec

# Use the gem locally
bundle exec irb -I lib -r cyber_trackr_helper
```

#### Documentation Development

```bash
# Generate YARD docs for Ruby code
bundle exec yard doc

# Build complete documentation site
make docs

# Start local Scalar docs server
make docs-serve
```

### Project Structure

```
cyber-trackr-live/
├── openapi/                   # OpenAPI specification
│   └── openapi.yaml          # Main spec file
├── lib/                      # Ruby implementation
│   ├── cyber_trackr_client/  # Generated client
│   ├── cyber_trackr_helper/  # Helper utilities
│   └── rubocop/             # Custom cops
├── test/                     # Test suite
├── examples/                 # Usage examples
├── scripts/                  # Development scripts
└── docs/                     # Documentation
```

## 🧪 Testing

The project uses a two-tier testing approach with clear separation of concerns:

### OpenAPI Validation (Node.js/Spectral)
```bash
# Validate OpenAPI spec - professional-grade validation
npm run docs:validate
```

### Ruby Testing (Core Functionality)
```bash
# Run core gem tests (fast - default)
bundle exec rake test

# Run all tests including live API integration
bundle exec rake test:all

# Run live API integration tests only
bundle exec rake test:stage2b
```

### Test Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Spectral      │    │ Ruby Testing    │
│   (Node.js)     │    │                 │
│                 │    │                 │
│ • OpenAPI 3.1   │    │ • Core gem      │
│ • Syntax valid  │    │ • Helper methods│
│ • Best practice │    │ • Live API      │
│ • Custom rules  │    │ • Integration   │
│ • DISA patterns │    │ • Business logic│
└─────────────────┘    └─────────────────┘
        │                       │
        ▼                       ▼
   Static Analysis        Dynamic Testing
   (Spec Quality)         (Live API)
```

### Test Suite Details

1. **Spectral Validation** - Professional OpenAPI 3.1 validation with custom DISA rules
2. **Core Gem Tests** - Tests helper methods and gem functionality  
3. **Live API Tests** - Tests against live cyber.trackr.live API responses
4. **Integration Tests** - End-to-end workflow testing

## ⚠️ Important API Notes

### Mixed Endpoints
SRGs and STIGs are served from the same `/stig` endpoint despite being conceptually different:
- **SRGs**: Generic technology requirements (e.g., "Configure the ALG to...")
- **STIGs**: Vendor-specific implementation (e.g., "show configuration system services ssh")

Use the Ruby helper's `is_srg?()` method or name patterns to distinguish them.

### Known Issues
- **Error Codes**: Invalid parameters return 500 (not 404)
- **Date Formats**: Some dates have leading spaces or inconsistent formats

### Rate Limiting
The API appears to accept reasonable request rates, but be respectful:
- Use delays between requests (helper defaults to 100ms)
- Cache responses when possible
- Avoid unnecessary bulk downloads

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and contribution guidelines.

## 📄 License

This project is licensed under the Apache License 2.0 - see [LICENSE.md](LICENSE.md) for details.

## 🏢 Acknowledgments

Created and maintained by [MITRE](https://www.mitre.org/) as part of the Security Automation Framework (SAF).

---

*This is an unofficial, community-maintained project. Not affiliated with DISA or cyber.trackr.live.*