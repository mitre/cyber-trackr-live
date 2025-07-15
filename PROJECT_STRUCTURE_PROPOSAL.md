# Project Structure Proposal: cyber-trackr-api

## Repository Structure Decision

Based on research and best practices, I recommend a **monorepo structure** that includes:
- OpenAPI specification
- Ruby client gem
- Documentation site (Scalar)
- Examples and utilities

### Advantages of Monorepo:
1. **Single source of truth** - Spec and client are always in sync
2. **Atomic updates** - Changes to spec and client in same PR
3. **Simplified CI/CD** - One workflow for everything
4. **Better discoverability** - Users find everything in one place
5. **Easier maintenance** - No cross-repo coordination needed

## Proposed Directory Structure

```
cyber-trackr-api/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       ├── ci.yml                  # Main CI workflow
│       ├── docs.yml                # Scalar docs deployment
│       ├── release.yml             # Gem release on tag
│       └── security.yml            # Security scanning
├── docs/
│   ├── api/                        # YARD-generated API docs
│   ├── guides/                     # User guides
│   │   ├── getting-started.md
│   │   ├── authentication.md
│   │   └── advanced-usage.md
│   └── release-notes/              # Version-specific notes
├── examples/
│   ├── basic_usage.rb
│   ├── fetch_complete_stig.rb
│   └── compliance_report.rb
├── lib/
│   ├── cyber_trackr_client/        # Generated client code
│   ├── cyber_trackr_helper/        # Helper utilities
│   └── rubocop/                    # Custom cops for post-gen
├── openapi/
│   ├── openapi.yaml                # Main OpenAPI spec
│   ├── components/                 # Reusable components
│   └── examples/                   # Request/response examples
├── scripts/
│   ├── generate_client.sh          # Client generation
│   ├── post_generate_fix.rb        # Post-gen fixes
│   └── validate_spec.rb            # Spec validation
├── spec/                           # RSpec tests (migration from minitest)
│   ├── cyber_trackr_client/
│   ├── cyber_trackr_helper/
│   └── spec_helper.rb
├── tasks/                          # Rake tasks
│   ├── docs.rake
│   ├── generate.rake
│   └── release.rake
├── .env.example                    # Environment template
├── .gitignore
├── .rubocop.yml                    # Main RuboCop config
├── .rubocop_post_generate.yml      # Post-gen RuboCop config
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md              # From train-juniper
├── CONTRIBUTING.md
├── Gemfile
├── LICENSE.md                      # Apache-2.0
├── NOTICE.md                       # MITRE attribution
├── README.md
├── Rakefile
├── SECURITY.md
└── cyber_trackr_api.gemspec        # Gem specification

.private/                           # Git-ignored
├── session-history/                # Development artifacts
└── recovery-files/                 # Context preservation
```

## Key Files to Create

### 1. cyber_trackr_api.gemspec
```ruby
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cyber_trackr_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'cyber_trackr_api'
  spec.version       = CyberTrackrClient::VERSION
  spec.authors       = ['MITRE Corporation']
  spec.email         = ['saf@mitre.org']
  spec.summary       = 'Ruby client for cyber.trackr.live API'
  spec.description   = 'Provides Ruby client access to DISA STIGs, SRGs, RMF controls, CCIs, and SCAP data via the cyber.trackr.live API'
  spec.homepage      = 'https://github.com/mitre/cyber-trackr-api'
  spec.license       = 'Apache-2.0'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/mitre/cyber-trackr-api/issues',
    'changelog_uri' => 'https://github.com/mitre/cyber-trackr-api/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://mitre.github.io/cyber-trackr-api/',
    'homepage_uri' => 'https://github.com/mitre/cyber-trackr-api',
    'source_code_uri' => 'https://github.com/mitre/cyber-trackr-api',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = %w[
    README.md cyber_trackr_api.gemspec LICENSE.md NOTICE.md CHANGELOG.md
    CODE_OF_CONDUCT.md CONTRIBUTING.md SECURITY.md
  ] + Dir.glob('lib/**/*', File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.1.0'

  # Runtime dependencies
  spec.add_dependency 'typhoeus', '~> 1.4'
  
  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'bundler-audit', '~> 0.9'
end
```

### 2. .github/workflows/ci.yml
```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  RUBY_VERSION: '3.3'

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby: ['3.1', '3.2', '3.3']
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true
          
      - name: Validate OpenAPI spec
        run: bundle exec rake spec:validate
        
      - name: Generate client
        run: ./scripts/generate_client.sh
        
      - name: Run tests
        run: bundle exec rspec
        
      - name: Run linting
        run: bundle exec rubocop
        
      - name: Check coverage
        run: bundle exec rake coverage:check
```

### 3. .github/workflows/docs.yml
```yaml
name: Deploy Docs

on:
  push:
    branches: [ main ]
  release:
    types: [ published ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          
      - name: Install Scalar CLI
        run: npm install -g @scalar/cli
        
      - name: Build Scalar docs
        run: scalar bundle openapi/openapi.yaml -o docs/api.html
        
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
```

### 4. Rakefile
```ruby
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

# Test tasks
RSpec::Core::RakeTask.new(:spec)

# Linting
RuboCop::RakeTask.new

# Documentation
YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
  t.options = ['--no-private']
end

# Load additional tasks
Dir['tasks/*.rake'].each { |f| load f }

# Default task
task default: %i[spec rubocop]

# OpenAPI tasks
namespace :openapi do
  desc 'Validate OpenAPI specification'
  task :validate do
    sh 'npx @openapitools/openapi-generator-cli validate -i openapi/openapi.yaml'
  end
  
  desc 'Generate Ruby client'
  task :generate do
    sh './scripts/generate_client.sh'
  end
  
  desc 'Generate Scalar documentation'
  task :docs do
    sh 'npx @scalar/cli bundle openapi/openapi.yaml -o docs/api.html'
  end
end

# Release preparation
desc 'Prepare for release'
task prepare_release: %w[spec rubocop openapi:validate openapi:generate]
```

## Migration Steps

1. **Create new GitHub repository**: `mitre/cyber-trackr-api`
2. **Initialize with basic structure**
3. **Migrate existing code**:
   - Move OpenAPI spec to `openapi/`
   - Move generated client to `lib/cyber_trackr_client/`
   - Move helper to `lib/cyber_trackr_helper/`
   - Convert tests from minitest to RSpec
4. **Set up CI/CD workflows**
5. **Configure GitHub Pages for docs**
6. **Set up RubyGems publishing**
7. **Create initial release**

## Timeline Estimate

- Week 1: Repository setup and migration
- Week 2: CI/CD and documentation
- Week 3: Testing and refinement
- Week 4: Initial release

## Next Steps

1. Run cleanup script to prepare current code
2. Create GitHub repository
3. Begin migration following this structure
4. Set up Scalar documentation
5. Configure automated workflows