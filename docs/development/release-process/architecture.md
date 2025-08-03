# Release Architecture

This document explains how the cyber-trackr-live release system works internally.

## OpenAPI as Source of Truth

The **OpenAPI specification** (`openapi/openapi.yaml`) is the single source of truth for versioning:

```yaml
info:
  version: 1.0.0  # Change ONLY here - everything else syncs from this
```

## Version Synchronization Flow

```mermaid
graph TD
    A[openapi/openapi.yaml<br/>SOURCE OF TRUTH] --> B[OpenAPI Generator]
    B --> C[lib/cyber_trackr_client/version.rb<br/>GENERATED]
    C --> D[cyber_trackr_live.gemspec<br/>reads version.rb]
    A --> E[Rake Task]
    E --> F[package.json<br/>SYNCED]
    A --> G[Git Tags<br/>v{version}]
```

### File Dependencies

```
openapi/openapi.yaml (SOURCE OF TRUTH)
    ├── lib/cyber_trackr_client/ (GENERATED - never edit)
    │   └── version.rb (GENERATED from OpenAPI)
    ├── cyber_trackr_live.gemspec (reads from version.rb)
    ├── package.json (synced by rake task)
    ├── site/index.html (GENERATED - Scalar docs)
    └── git tags (created from OpenAPI version)
```

## Dual-Mode Release Process

The `bundle exec rake release` task operates in two modes:

### Local Mode (Developer Machine)
```ruby
if tag_exists_locally?
  # CI mode - skip (OIDC handles publication)
else
  # Local mode - create and push tag
  create_tag(version)
  push_tag_to_github
  trigger_github_actions
  exit  # Don't publish gem locally
end
```

### CI Mode (GitHub Actions)
```ruby
if ENV['CI'] && oidc_configured?
  # Skip gem publication
  # OIDC trusted publishing handles it
  log "Gem will be published via OIDC"
end
```

## GitHub Actions Workflow

The `.github/workflows/release-tag.yml` workflow:

```yaml
on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    permissions:
      contents: write     # Create GitHub Release
      id-token: write    # OIDC trusted publishing
    
    steps:
      # 1. Setup environment
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
      
      # 2. Run quality checks
      - run: bundle exec rake test
      - run: bundle exec rubocop
      
      # 3. Configure OIDC and publish
      - uses: rubygems/configure-rubygems-credentials@v1
      - run: bundle exec rake release  # Detects CI, skips duplicate
```

## OIDC Trusted Publishing

### How It Works

1. **GitHub Actions** generates a temporary OIDC token
2. **RubyGems** validates the token against configured publisher
3. **Gem publishes** without any stored API keys

### Configuration

Trusted publisher configuration on RubyGems.org:
- **Repository**: `mitre/cyber-trackr-live`
- **Workflow**: `release-tag.yml`
- **Environment**: (none)
- **Gem**: `cyber_trackr_live`

### Security Benefits

- No API keys to rotate or leak
- GitHub identity verification
- Audit trail of all publications
- Automatic permission management

## Changelog Generation

Git-cliff generates three types of changelogs:

### 1. OpenAPI Changelog
```toml
# cliff-openapi.toml
[git]
filter_commits = true
tag_pattern = "v[0-9]*"
path_filter = ["docs/**", "openapi/**"]
```

### 2. Ruby Gem Changelog
```toml
# cliff-gem.toml
[git]
filter_commits = true
tag_pattern = "v[0-9]*"
path_filter = ["lib/**", "test/**"]
```

### 3. Release Notes
```toml
# cliff-release.toml
[changelog]
header = """
# Release v{{ version }}

## Installation
\```bash
gem install cyber_trackr_live -v {{ version }}
\```
"""
```

## Rake Task Workflow

The `release:patch/minor/major` tasks perform these steps:

```ruby
def prepare_release(bump_type)
  # 1. Check prerequisites
  ensure_clean_working_directory
  ensure_on_main_branch
  
  # 2. Update version
  update_openapi_version(bump_type)
  sync_package_json_version
  
  # 3. Regenerate everything
  regenerate_ruby_client
  build_documentation
  
  # 4. Validate
  run_tests
  run_linting
  check_version_consistency
  
  # 5. Generate changelogs
  generate_openapi_changelog
  generate_gem_changelog
  generate_release_notes
  
  # 6. Commit
  commit_all_changes("Bump version to #{new_version}")
end
```

## Version Consistency Validation

The `version_check` task ensures all versions match:

```ruby
def check_version_consistency
  openapi_version = extract_from_yaml('openapi/openapi.yaml')
  gem_version = extract_from_gemspec('cyber_trackr_live.gemspec')
  package_version = extract_from_json('package.json')
  
  unless all_equal?(openapi_version, gem_version, package_version)
    raise "Version mismatch detected!"
  end
end
```

## Why This Architecture?

### Benefits
- **Single source of truth** - No version confusion
- **Fully automated** - One command releases everything
- **Secure** - OIDC eliminates API key management
- **Reliable** - Proven pattern from other projects
- **No race conditions** - Clear separation of responsibilities

### Design Decisions
- **OpenAPI-first** - Specification drives everything
- **Dual-mode logic** - Works locally and in CI
- **Git-cliff** - Conventional commits → beautiful changelogs
- **OIDC** - Modern, secure gem publication