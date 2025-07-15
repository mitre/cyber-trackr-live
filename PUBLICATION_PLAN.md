# Cyber Trackr API - Publication Plan

## Overview
Plan to publish the cyber.trackr.live OpenAPI specification and Ruby client as a standalone project with modern API documentation using Scalar.

## Project Structure

### 1. Repository: `mitre/cyber-trackr-api`
```
cyber-trackr-api/
├── .github/
│   └── workflows/
│       ├── test.yml              # Run tests on PR
│       ├── release.yml           # Build & publish gem
│       └── docs.yml              # Deploy Scalar docs
├── lib/
│   ├── cyber_trackr_api.rb      # Main entry point
│   └── cyber_trackr_api/
│       ├── version.rb            # Version constant
│       ├── client.rb             # Generated client wrapper
│       └── helper.rb             # Helper methods (from cyber_trackr_helper.rb)
├── spec/                         # RSpec tests (converted from minitest)
│   ├── spec_helper.rb
│   ├── helper_spec.rb
│   └── integration/
│       └── live_api_spec.rb
├── docs/
│   ├── index.html               # Scalar documentation
│   └── CNAME                    # Custom domain (optional)
├── scripts/
│   ├── generate_client.sh       # Regenerate from OpenAPI
│   └── post_generate.rb         # Fix nil check issues
├── examples/
│   ├── fetch_stig.rb
│   ├── search_documents.rb
│   └── compliance_summary.rb
├── .gitignore
├── .rubocop.yml                 # Ruby style guide
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── Gemfile
├── LICENSE                      # Apache-2.0
├── openapi.yaml                 # The OpenAPI specification
├── cyber_trackr_api.gemspec
├── Rakefile
├── README.md
└── VERSION                      # Gem version (1.0.0)
```

## Implementation Steps

### Phase 1: Fix Remaining Issues (Week 1)
1. **Fix HTML Response Bug**
   - Investigate Faraday redirect handling
   - Add follow_redirects configuration
   - Test with problematic endpoints

2. **Automate Post-Generation Fixes**
   ```ruby
   # scripts/post_generate.rb
   # Automatically fix date nil check after client generation
   ```

### Phase 2: Create GitHub Repository (Week 1)
1. **Initialize Repository**
   - Create `mitre/cyber-trackr-api`
   - Set up branch protection
   - Add CODEOWNERS file

2. **Move and Refactor Code**
   - Convert cyber_trackr_helper.rb → lib/cyber_trackr_api/helper.rb
   - Create proper module structure
   - Add version management

3. **Convert Tests to RSpec**
   - More standard in Ruby community
   - Better matcher support
   - Cleaner syntax

### Phase 3: Set Up Documentation (Week 2)
1. **Scalar Documentation**
   ```html
   <!-- docs/index.html -->
   <!DOCTYPE html>
   <html>
   <head>
     <title>Cyber Trackr API - DISA STIG/SRG Data</title>
     <meta charset="utf-8">
     <meta name="viewport" content="width=device-width, initial-scale=1">
   </head>
   <body>
     <script id="api-reference" data-url="../openapi.yaml"></script>
     <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
   </body>
   </html>
   ```

2. **GitHub Pages Deployment**
   - Enable GitHub Pages from docs/
   - Optional: Set up custom domain (e.g., cyber-trackr-api.mitre.org)

### Phase 4: Gem Structure (Week 2)
1. **Gemspec Configuration**
   ```ruby
   # cyber_trackr_api.gemspec
   Gem::Specification.new do |spec|
     spec.name          = "cyber_trackr_api"
     spec.version       = CyberTrackrApi::VERSION
     spec.authors       = ["MITRE Corporation"]
     spec.email         = ["saf@groups.mitre.org"]
     
     spec.summary       = "Ruby client for cyber.trackr.live STIG/SRG API"
     spec.description   = "Access DISA STIGs, SRGs, RMF controls, and CCIs programmatically"
     spec.homepage      = "https://github.com/mitre/cyber-trackr-api"
     spec.license       = "Apache-2.0"
     
     spec.metadata = {
       "bug_tracker_uri" => "https://github.com/mitre/cyber-trackr-api/issues",
       "changelog_uri" => "https://github.com/mitre/cyber-trackr-api/blob/main/CHANGELOG.md",
       "documentation_uri" => "https://mitre.github.io/cyber-trackr-api/",
       "homepage_uri" => "https://github.com/mitre/cyber-trackr-api",
       "source_code_uri" => "https://github.com/mitre/cyber-trackr-api"
     }
     
     spec.files = Dir[
       "lib/**/*",
       "openapi.yaml",
       "README.md",
       "LICENSE",
       "CHANGELOG.md"
     ]
     
     spec.require_paths = ["lib"]
     spec.required_ruby_version = ">= 2.7"
     
     # Runtime dependencies
     spec.add_dependency "typhoeus", "~> 1.4"
     spec.add_dependency "json", "~> 2.0"
     
     # Development dependencies
     spec.add_development_dependency "bundler", "~> 2.0"
     spec.add_development_dependency "rake", "~> 13.0"
     spec.add_development_dependency "rspec", "~> 3.12"
     spec.add_development_dependency "webmock", "~> 3.19"
     spec.add_development_dependency "rubocop", "~> 1.50"
   end
   ```

### Phase 5: CI/CD Setup (Week 3)
1. **GitHub Actions - Testing**
   ```yaml
   # .github/workflows/test.yml
   name: Test
   on: [push, pull_request]
   
   jobs:
     test:
       runs-on: ubuntu-latest
       strategy:
         matrix:
           ruby: ['2.7', '3.0', '3.1', '3.2']
       steps:
         - uses: actions/checkout@v4
         - uses: ruby/setup-ruby@v1
           with:
             ruby-version: ${{ matrix.ruby }}
             bundler-cache: true
         - run: bundle exec rake spec
         - run: bundle exec rubocop
   ```

2. **GitHub Actions - Release**
   ```yaml
   # .github/workflows/release.yml
   name: Release
   on:
     push:
       tags: ['v*']
   
   jobs:
     release:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: ruby/setup-ruby@v1
           with:
             ruby-version: '3.2'
             bundler-cache: true
         
         - name: Generate Client
           run: ./scripts/generate_client.sh
         
         - name: Post-Process Generated Code
           run: ruby scripts/post_generate.rb
         
         - name: Run Tests
           run: bundle exec rake spec
         
         - name: Build Gem
           run: gem build *.gemspec
         
         - name: Publish to RubyGems
           run: |
             mkdir -p ~/.gem
             echo -e "---\n:rubygems_api_key: ${RUBYGEMS_API_KEY}" > ~/.gem/credentials
             chmod 0600 ~/.gem/credentials
             gem push *.gem
           env:
             RUBYGEMS_API_KEY: ${{ secrets.RUBYGEMS_API_KEY }}
         
         - name: Create GitHub Release
           uses: softprops/action-gh-release@v1
           with:
             files: cyber_trackr_api-*.gem
   ```

### Phase 6: Documentation & Examples (Week 3)
1. **README.md**
   - Installation instructions
   - Quick start guide
   - Link to Scalar docs
   - Badge for gem version, CI status

2. **Example Scripts**
   - Fetching complete STIGs
   - Searching for documents
   - Generating compliance reports
   - Batch downloading

### Phase 7: Launch (Week 4)
1. **Pre-Launch Checklist**
   - [ ] All tests passing
   - [ ] Documentation complete
   - [ ] Examples working
   - [ ] Scalar docs deployed
   - [ ] RubyGems account ready

2. **Launch Steps**
   - Tag v1.0.0
   - Push gem to RubyGems
   - Announce on MITRE SAF channels
   - Create blog post/announcement

## Future Enhancements

### Version 1.1
- Caching layer for API responses
- Retry logic with exponential backoff
- Progress bars for batch operations
- Export to Excel/CSV formats

### Version 2.0
- Async/concurrent fetching
- GraphQL wrapper (if API supports it)
- Command-line tool
- Docker image with pre-built client

## Success Metrics
- Number of gem downloads
- GitHub stars/forks
- Community contributions
- Integration into other MITRE tools

## Notes
- Keep OpenAPI spec as source of truth
- Automate as much as possible
- Follow semantic versioning
- Maintain backward compatibility