# Testing Overview

The cyber-trackr-live project uses a comprehensive testing strategy to ensure reliability and accuracy.

## Testing Architecture

We employ a **two-tier testing architecture** that separates concerns:

- **[Two-Tier Testing](./two-tier-testing.md)** - Architectural overview of our testing approach
- **[API Testing Guide](./api-testing.md)** - Practical guide for testing the API

## Quick Commands

```bash
# Validate OpenAPI specification
npm run docs:validate

# Run Ruby tests
bundle exec rake test

# Run all tests
bundle exec rake test:all

# Run live API tests
bundle exec rake test:live
```

## Testing Philosophy

1. **Separation of Concerns** - OpenAPI validation separate from API behavior testing
2. **Fast Feedback** - Quick validation catches errors early
3. **Comprehensive Coverage** - Both specification and implementation tested
4. **Cross-Platform** - Tests run on Windows, macOS, and Linux

## Next Steps

- **Understanding the architecture?** → [Two-Tier Testing](./two-tier-testing.md)
- **Running tests?** → [API Testing Guide](./api-testing.md)
- **Troubleshooting?** → [Release Troubleshooting](../release-process/troubleshooting.md)