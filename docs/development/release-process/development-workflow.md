# Development Workflow

This guide covers the day-to-day development workflow when making changes to the cyber-trackr-live project.

## Making API Changes

When modifying the OpenAPI specification:

```bash
# 1. Edit the OpenAPI spec
vim openapi/openapi.yaml

# 2. Validate immediately (catch errors early)
npm run docs:validate

# 3. If valid, regenerate everything
make generate           # Ruby client
npm run docs:build     # Documentation

# 4. Test the changes
bundle exec rake test
bundle exec rubocop

# 5. Commit with conventional commit message
git add .
git commit -m "feat(api): add new endpoint for feature X"
```

### Important: Order Matters!

Always follow this sequence:
1. **Edit** OpenAPI spec first
2. **Validate** before regenerating
3. **Regenerate** all dependent code
4. **Test** everything works
5. **Commit** when all tests pass

## Version Management

### Where Versions Live

```
openapi/openapi.yaml              # SOURCE OF TRUTH - edit here
├── lib/cyber_trackr_client/
│   └── version.rb               # GENERATED - never edit
├── cyber_trackr_live.gemspec    # Reads from version.rb
├── package.json                 # SYNCED by rake task
└── git tags (v1.0.0)           # Created during release
```

### Checking Version Consistency

```bash
# Verify all versions match
bundle exec rake version_check

# Output shows all version locations
# ✓ OpenAPI: 1.0.3
# ✓ Gem: 1.0.3
# ✓ Package: 1.0.3
```

### Never Edit Generated Files

These files are ALWAYS regenerated:
- `lib/cyber_trackr_client/**/*` - Entire client directory
- `site/index.html` - Scalar documentation
- Any file marked `# DO NOT EDIT`

## Common Development Tasks

### Adding a New Endpoint

```bash
# 1. Add endpoint to OpenAPI spec
vim openapi/openapi.yaml

# 2. Add path, operation, schemas as needed
# 3. Validate the spec
npm run docs:validate

# 4. Regenerate and test
make generate
bundle exec rake test

# 5. Add helper method if needed
vim lib/cyber_trackr_helper.rb

# 6. Test the helper
bundle exec rake test:helper

# 7. Commit with descriptive message
git commit -m "feat(api): add /api/newEndpoint for feature X"
```

### Fixing a Bug

```bash
# 1. Write a failing test
vim test/cyber_trackr_helper_test.rb

# 2. Run test to confirm it fails
bundle exec rake test

# 3. Fix the bug
vim lib/cyber_trackr_helper.rb

# 4. Verify test passes
bundle exec rake test

# 5. Run all tests
bundle exec rake test:all

# 6. Commit with fix message
git commit -m "fix(helper): correct data parsing in fetch_complete_stig"
```

### Updating Documentation

```bash
# 1. Edit documentation
vim docs/development/some-guide.md

# 2. Preview changes
npm run docs:dev
# Open http://localhost:5173

# 3. Build to verify no errors
npm run docs:build

# 4. Commit documentation
git commit -m "docs: improve release process documentation"
```

## Conventional Commits

Use conventional commit messages for automatic changelog generation:

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation only
- **style**: Code style (formatting, semicolons, etc)
- **refactor**: Code change that neither fixes nor adds feature
- **perf**: Performance improvement
- **test**: Adding or correcting tests
- **chore**: Maintenance tasks

### Examples
```bash
# Feature
git commit -m "feat(api): add pagination to /api/stigs endpoint"

# Bug fix
git commit -m "fix(client): handle null values in response data"

# Documentation
git commit -m "docs: add troubleshooting guide for Windows users"

# Breaking change (major version)
git commit -m "feat(api)!: change response format for /api/ccis

BREAKING CHANGE: Response now returns array instead of object"
```

## Testing Strategy

### Before Committing

Always run these checks:

```bash
# 1. OpenAPI validation
npm run docs:validate

# 2. Ruby tests
bundle exec rake test

# 3. Linting
bundle exec rubocop

# 4. Version consistency
bundle exec rake version_check
```

### Test Types

```bash
# Fast unit tests only
bundle exec rake test:stage1

# Full test suite
bundle exec rake test:all

# Live API tests (requires internet)
bundle exec rake test:live

# Helper method tests
bundle exec rake test:helper
```

## Working with Branches

### Feature Development

```bash
# 1. Create feature branch
git checkout -b feature/new-endpoint

# 2. Make changes following workflow above

# 3. Push branch
git push origin feature/new-endpoint

# 4. Create PR on GitHub

# 5. After approval, merge to main
```

### Important: Releases Only from Main

- Never release from feature branches
- Always merge to main first
- Then follow [Quick Release Guide](./quick-release.md)

## Regeneration Commands

### Full Regeneration

```bash
# Regenerate everything
make clean generate

# Or individually:
make generate        # Ruby client
npm run docs:build  # Documentation
```

### Partial Updates

```bash
# Just validate OpenAPI
npm run docs:validate

# Just run tests
bundle exec rake test

# Just build docs
npm run docs:build
```

## Best Practices

1. **Validate early and often** - Catch OpenAPI errors immediately
2. **Test after regenerating** - Ensure generated code works
3. **Use conventional commits** - Enable automatic changelogs
4. **Keep changes focused** - One feature/fix per commit
5. **Document breaking changes** - Use BREAKING CHANGE in commit
6. **Run full test suite** - Before pushing changes

## Quick Reference

```bash
# Daily workflow
npm run docs:validate    # Validate OpenAPI
make generate           # Regenerate client
bundle exec rake test   # Run tests
git commit -m "..."    # Commit with conventional message

# Before releasing
bundle exec rake test:all      # Full test suite
bundle exec rake version_check # Verify versions
bundle exec rubocop           # Check code style
```