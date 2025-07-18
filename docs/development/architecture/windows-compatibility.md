# Windows Compatibility

## Problem Statement

Many Ruby gems struggle with Windows compatibility due to:
- Native extensions requiring compilation tools
- External library dependencies (like libcurl.dll)
- Path handling differences
- CI/CD complexity

## Our Solution: Faraday

This project uses **Faraday** as the HTTP client for maximum Windows compatibility:

```ruby
# ✅ Good - Uses Faraday (built into Ruby)
gem 'faraday', '~> 2.0'
gem 'faraday-multipart', '~> 1.0'

# ❌ Avoided - typhoeus (requires libcurl.dll on Windows)
# gem 'typhoeus'
```

## Benefits

### No External Dependencies
- **Pure Ruby implementation** using Net::HTTP (built into Ruby)
- **No libcurl.dll required** - eliminates Windows CI/CD issues
- **Cross-platform compatibility** - works identically on Windows, macOS, Linux

### Proven Reliability
- **Widely adopted** - More stable and mature than alternatives
- **Consistent** - Same HTTP client used in tests and generated client
- **Future-proof** - Less likely to break with OS updates

## CI/CD Testing

Our GitHub Actions CI/CD pipeline tests across:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    ruby-version: ['3.2', '3.3', '3.4']
```

**Results**: ✅ All tests pass on all platforms and Ruby versions

## Development on Windows

### Prerequisites
- Ruby 3.2+ (recommend RubyInstaller for Windows)
- Git for Windows
- No additional dependencies required

### Setup
```bash
# Clone repository
git clone https://github.com/mitre/cyber-trackr-live.git
cd cyber-trackr-live

# Install dependencies (pure Ruby, no compilation needed)
bundle install

# Run tests
bundle exec rake test
```

### Common Issues Avoided

**Before (with typhoeus)**:
```
LoadError: Could not open library 'libcurl': Failed with error 126: 
The specified module could not be found.
```

**After (with Faraday)**:
```
✅ All tests passing across all platforms
```

## OpenAPI Client Generation

The generated client uses Faraday via the `--library=faraday` flag:

```bash
# Automatic in our generation script
./scripts/generate_client.sh  
```

This ensures the generated client has the same Windows compatibility benefits.

## Best Practices

When adding new dependencies:

1. **Prefer pure Ruby** over native extensions
2. **Test on Windows** in addition to Unix systems  
3. **Check gem platforms** before adding dependencies
4. **Use GitHub Actions matrix** for cross-platform CI/CD

## Related Documentation

- [Faraday Migration Guide](/development/architecture/faraday-migration) - Technical details of the migration
- [Contributing Guide](/reference/contributing) - Development setup for all platforms