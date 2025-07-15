# Contributing to cyber-trackr-live

Thank you for your interest in contributing to cyber-trackr-live! This project provides an OpenAPI specification and Ruby client for the cyber.trackr.live API.

## 🚀 Quick Start

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/cyber-trackr-live.git
cd cyber-trackr-live

# Install dependencies
bundle install              # Ruby dependencies
npm install                # Node dependencies (optional - for docs)

# Run tests
bundle exec rake test      # Unit tests
bundle exec rake test:all  # All tests including integration
```

## 🛠️ Development Setup

### Prerequisites

- Ruby 3.3+ (check `.ruby-version`)
- Node.js 22+ (check `.nvmrc`) - optional, only for OpenAPI docs
- Docker (for client generation)

### Environment Setup

```bash
# Using rbenv
rbenv install 3.3.0
rbenv local 3.3.0

# Using nvm (for docs development)
nvm install
nvm use

# Or using asdf
asdf install
```

## 📝 Development Workflows

### Working on the OpenAPI Specification

The OpenAPI spec is the source of truth for the API documentation and client generation.

```bash
# 1. Edit the spec
vi openapi/openapi.yaml

# 2. Validate your changes
bundle exec rake test:openapi
spectral lint openapi/openapi.yaml

# 3. Preview the docs
npm run docs:dev
# Opens at http://localhost:4000

# 4. Regenerate the Ruby client
make generate

# 5. Run tests to ensure compatibility
bundle exec rake test
```

#### OpenAPI Best Practices

- Use OpenAPI 3.1.1 features (proper null handling with `anyOf`)
- Include examples for all schemas
- Add operation IDs for clean client generation
- Document all error responses
- Keep descriptions clear and concise

### Ruby Client Development

#### Generated Code

The Ruby client in `lib/cyber_trackr_client/` is generated from the OpenAPI spec. **Do not edit these files directly**.

To fix issues in generated code:
1. Update the OpenAPI spec if the issue is in the API definition
2. Use RuboCop cops in `lib/rubocop/cop/` for post-generation fixes
3. Add helper methods in `lib/cyber_trackr_helper/`

#### Helper Development

```bash
# Work on helper methods
vi lib/cyber_trackr_helper.rb

# Run tests
bundle exec ruby test/cyber_trackr_helper_test.rb

# Test interactively
bundle exec irb -I lib -r cyber_trackr_helper
client = CyberTrackrHelper::Client.new
client.list_stigs
```

#### Testing

```bash
# Run specific test file
bundle exec ruby test/content_type_fix_test.rb

# Run all unit tests
bundle exec rake test:unit

# Run integration tests (requires API access)
bundle exec rake test:integration

# Generate coverage report
bundle exec rake coverage
```

### Documentation Development

#### API Documentation (Scalar)

```bash
# Start local docs server
npm run docs:dev

# Build static docs
npm run docs:build

# Update Scalar configuration
vi scalar.config.json
```

#### Ruby Documentation (YARD)

```bash
# Generate YARD docs
bundle exec yard doc

# Preview at http://localhost:8808
bundle exec yard server

# Update documentation
vi lib/cyber_trackr_helper.rb  # Add YARD comments
```

## 🧪 Testing Guidelines

### Test Structure

```
test/
├── unit/                    # Fast, isolated tests
│   ├── content_type_fix_test.rb
│   └── cyber_trackr_helper_test.rb
├── openapi/                # OpenAPI validation
│   ├── openapi_validation_test.rb
│   └── spec_completeness_test.rb
└── integration/            # Live API tests
    └── live_integration_test.rb
```

### Writing Tests

```ruby
# Unit test example
class HelperTest < Minitest::Test
  def test_list_stigs_filters_srgs
    mock_documents_list  # Use test helpers
    
    stigs = @client.list_stigs
    
    assert_equal 2, stigs.size
    refute stigs.key?(:Application_Security_Requirements_Guide)
  end
end
```

### Mocking API Responses

Always use the test helpers from `test/test_helper.rb`:

```ruby
# Good - uses proper mock structure
mock_documents_list(sample_document_list)

# Bad - incomplete mock missing required fields
stub_request(:get, url).to_return(body: {}.to_json)
```

## 📋 Contribution Types

### Bug Reports 🐛

Use GitHub Issues with:
- Clear reproduction steps
- Version information (Ruby, gem version)
- Error messages and stack traces
- Minimal code example

### Feature Requests 💡

- Open an issue first to discuss
- Explain the use case
- Consider API compatibility
- Propose implementation approach

### Pull Requests 🔄

1. **Fork and branch** from `main`
2. **Make focused changes** - one feature/fix per PR
3. **Add tests** for new functionality
4. **Update docs** as needed
5. **Run all checks**:
   ```bash
   bundle exec rake test
   bundle exec rubocop
   bundle exec rake test:openapi
   ```
6. **Update changelogs**:
   - `CHANGELOG-GEM.md` for Ruby changes
   - `CHANGELOG-OPENAPI.md` for spec changes
7. **Version updates** (maintainers only):
   - Do NOT bump version in PRs
   - Versions are bumped during release process
   - If you modified `openapi/openapi.yaml`, regenerate client

## 🌍 Cross-Platform Development

This gem supports multiple platforms and architectures:

### Supported Platforms
- **Linux**: x86_64, aarch64 (ARM), musl (Alpine)
- **macOS**: Intel (x86_64), ARM (arm64)
- **Windows**: x64 (mingw-ucrt)
- **Ruby**: Generic Ruby platform

### Adding Platform Support

When adding new dependencies that have native extensions, update `Gemfile.lock` for all platforms:

```bash
# Add common platforms
bundle lock --add-platform x86_64-linux
bundle lock --add-platform x86_64-darwin
bundle lock --add-platform arm64-darwin-24
bundle lock --add-platform x64-mingw-ucrt
bundle lock --add-platform aarch64-linux
bundle lock --add-platform x86_64-linux-musl
bundle lock --add-platform ruby

# Verify all platforms are present
grep -A 10 "PLATFORMS" Gemfile.lock
```

### CI/CD Testing Matrix

Our CI tests across multiple platforms and Ruby versions:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    ruby-version: ['3.1', '3.2', '3.3']
```

This ensures the gem works correctly across all supported environments.

### Platform-Specific Issues

Common issues and solutions:

**Bundle installation fails on CI:**
```bash
# Error: "Your bundle only supports platforms ['arm64-darwin-24'] but your local platform is x86_64-linux"
# Solution: Add the missing platform to Gemfile.lock
bundle lock --add-platform x86_64-linux
```

**Native extension compilation fails:**
- Check if the gem has platform-specific versions
- Ensure all required platforms are in Gemfile.lock
- Update gem to a version that supports the target platform

## 🚦 CI/CD Pipeline

All PRs must pass:

- **Unit Tests** - Ruby tests must pass on Linux, macOS, and Windows
- **Linting** - RuboCop with no violations
- **OpenAPI Validation** - Spec must be valid
- **Security Checks** - No vulnerable dependencies
- **Documentation** - Must build successfully

## 📦 Release Process

Maintainers handle releases:

1. **Version Bump**
   - Use rake tasks to bump version:
     - `bundle exec rake version:major` - For breaking changes (2.0.0)
     - `bundle exec rake version:minor` - For new features (1.1.0)
     - `bundle exec rake version:patch` - For bug fixes (1.0.1)
   - Regenerate client: `make generate`
   - This updates `lib/cyber_trackr_client/version.rb` automatically
   - Commit all changes together

2. **Update Changelogs**
   - Add entries to `CHANGELOG-GEM.md` for Ruby/gem changes
   - Add entries to `CHANGELOG-OPENAPI.md` for API spec changes
   - Follow [Keep a Changelog](https://keepachangelog.com/) format

3. **Create Release**
   - Run: `bundle exec rake prepare_release`
   - This checks version consistency and creates a tag
   - Push the tag: `git push origin v{version}`
   - GitHub Actions automatically:
     - Publishes gem to RubyGems.org
     - Deploys docs to GitHub Pages
     - Creates GitHub release

### Version Management

**IMPORTANT**: The version in `openapi/openapi.yaml` is the single source of truth.

```yaml
# openapi/openapi.yaml
info:
  version: 1.0.0  # Update this version
```

Never manually edit `lib/cyber_trackr_client/version.rb` - it's generated!

## 🔒 Security

- Never commit credentials or tokens
- Report security issues to saf-security@mitre.org
- Run `bundle audit` before submitting PRs
- Be cautious with user input handling

## 📚 Resources

- [OpenAPI 3.1.1 Specification](https://spec.openapis.org/oas/v3.1.0)
- [Scalar Documentation](https://github.com/scalar/scalar)
- [RuboCop Style Guide](https://rubocop.org/)
- [cyber.trackr.live API](https://cyber.trackr.live)

## 🤝 Code of Conduct

Please follow our [Code of Conduct](CODE_OF_CONDUCT.md) in all interactions.

## 📄 License

By contributing, you agree that your contributions will be licensed under the Apache-2.0 license.