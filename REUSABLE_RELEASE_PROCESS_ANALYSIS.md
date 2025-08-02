# Reusable Release Process Analysis

## Current Components

### Generic (Reusable) Components
1. **Dual-Mode Rake Release Task**
   - ✅ Local mode: Create/push tags, trigger CI
   - ✅ CI mode: Detect OIDC, skip duplicate publication
   - ✅ Proven train-juniper pattern

2. **OIDC Trusted Publishing Integration**
   - ✅ GitHub Actions workflow with proper permissions
   - ✅ `rubygems/configure-rubygems-credentials@v1.0.0`
   - ✅ First release vs ongoing release patterns

3. **Version Management**
   - ✅ Single source of truth pattern
   - ✅ Version consistency validation
   - ✅ Semantic versioning support

4. **Automated Changelog Generation**
   - ✅ Git-cliff integration
   - ✅ Conventional commits
   - ✅ Release notes generation

5. **Quality Gates**
   - ✅ Testing, linting, security audits
   - ✅ GitHub release creation
   - ✅ Workflow monitoring

### Project-Specific Components
1. **OpenAPI Client Generation**
   - ❌ Very specific to OpenAPI projects
   - ❌ Docker + OpenAPI Generator integration
   - ❌ Version synchronization with spec

2. **Documentation Building**
   - ❌ VitePress-specific
   - ❌ Package.json version syncing
   - ❌ Static site deployment

3. **Multi-File Version Sources**
   - ❌ Our specific file structure
   - ❌ OpenAPI spec as source of truth

## Reusability Options

### Option 1: GitHub Action (Recommended)
**Structure**: Composite GitHub Action
**Usage**: 
```yaml
- uses: mitre/gem-release-action@v1
  with:
    version-source: 'lib/my_gem/version.rb'
    changelog-paths: 'lib/**,test/**'
    pre-release-command: 'bundle exec rake test'
```

**Pros**:
- Easy to use across projects
- Centralized updates
- GitHub marketplace distribution
- Built-in OIDC integration

**Cons**:
- GitHub-specific
- Limited customization

### Option 2: Rake Gem
**Structure**: `mitre-gem-release` gem
**Usage**:
```ruby
# Gemfile
gem 'mitre-gem-release', group: :development

# Rakefile  
require 'mitre/gem/release/tasks'
```

**Pros**:
- Maximum flexibility
- Ruby ecosystem native
- Easy customization

**Cons**:
- Requires more setup
- Still need GitHub Actions integration

### Option 3: Template Repository
**Structure**: GitHub template with all files
**Usage**: Click "Use this template"

**Pros**:
- Complete setup
- Easy to customize after copying
- All components included

**Cons**:
- Manual updates needed
- Divergence over time
- No centralized improvements

### Option 4: Hybrid Approach (Recommended)
**Structure**: GitHub Action + Template + Documentation

**Components**:
1. **GitHub Action**: Core release logic
2. **Template Files**: `.github/workflows/`, `cliff.toml`, `tasks/release.rake`
3. **Documentation**: Setup guide with examples

**Pros**:
- Best of all approaches
- Easy adoption
- Centralized updates for core logic
- Customizable for project needs

## Required Configuration

### Minimum Required:
```yaml
# .github/workflows/release-tag.yml
- uses: mitre/gem-release-action@v1
  with:
    gem-name: 'my_gem'
    version-source: 'lib/my_gem/version.rb'
```

### Full Configuration:
```yaml
- uses: mitre/gem-release-action@v1
  with:
    gem-name: 'my_gem'
    version-source: 'lib/my_gem/version.rb'
    changelog-paths: 'lib/**,test/**'
    pre-release-command: 'bundle exec rake test'
    post-release-command: 'bundle exec rake docs:build'
    ruby-version: '3.3'
    node-version: '18'
    skip-oidc: false
    create-github-release: true
    custom-release-notes: 'docs/release-notes'
```

## Implementation Plan

### Phase 1: Extract Generic Components
1. Create `mitre/gem-release-action` repository
2. Extract dual-mode rake task logic
3. Create configurable GitHub Action
4. Test with cyber-trackr-live

### Phase 2: Template and Documentation
1. Create template repository with examples
2. Documentation for different project types:
   - Pure Ruby gems
   - OpenAPI projects  
   - Rails applications
   - CLI tools

### Phase 3: Ecosystem Integration
1. Publish to GitHub Marketplace
2. Create `mitre-gem-release` Ruby gem for local development
3. Integration guides for common MITRE project patterns

## Benefits for MITRE Projects

1. **Standardization**: All projects use same proven patterns
2. **Security**: OIDC trusted publishing by default
3. **Reliability**: Battle-tested train-juniper pattern
4. **Maintenance**: Central updates benefit all projects
5. **Onboarding**: New projects get professional release process instantly

## Success Metrics

- Number of MITRE projects using the action
- Reduction in release-related issues
- Time saved on release process setup
- Adoption of OIDC trusted publishing across projects

## Next Steps

1. ✅ Document current process (completed)
2. 🔄 Review documentation for cleanup opportunities
3. ⏳ Create proof-of-concept GitHub Action
4. ⏳ Test with 2-3 different project types
5. ⏳ Publish and document for MITRE ecosystem