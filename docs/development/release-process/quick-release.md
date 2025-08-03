# Quick Release Guide

This guide provides the essential commands for releasing cyber-trackr-live. For detailed explanations, see the [Architecture](./architecture.md) documentation.

## Prerequisites Check

```bash
# Ensure you're on main and up to date
git checkout main
git pull origin main
git status  # Should show no changes

# Ensure tests pass
bundle exec rake test
npm run docs:validate

# Verify Docker is running
docker --version
```

## Release Commands

### Patch Release (Bug Fixes)

```bash
# 1. Prepare the release (updates version, regenerates everything)
bundle exec rake release:patch

# 2. Push changes
git push origin main

# 3. Create tag and trigger release
bundle exec rake release
```

### Minor Release (New Features)

```bash
# 1. Prepare the release
bundle exec rake release:minor

# 2. Push changes
git push origin main

# 3. Create tag and trigger release
bundle exec rake release
```

### Major Release (Breaking Changes)

```bash
# 1. Prepare the release
bundle exec rake release:major

# 2. Push changes
git push origin main

# 3. Create tag and trigger release
bundle exec rake release
```

## What Happens Automatically

When you run `bundle exec rake release:patch/minor/major`:
- ✅ Updates version in `openapi/openapi.yaml`
- ✅ Syncs `package.json` version
- ✅ Regenerates Ruby client
- ✅ Runs all tests
- ✅ Generates changelogs
- ✅ Creates release notes
- ✅ Builds documentation
- ✅ Commits changes

When you run `bundle exec rake release`:
- ✅ Creates git tag
- ✅ Pushes tag to GitHub
- ✅ Triggers GitHub Actions

GitHub Actions then:
- ✅ Runs tests
- ✅ Creates GitHub Release
- ✅ Publishes gem to RubyGems
- ✅ Deploys documentation

## Monitoring the Release

After pushing the tag, monitor progress at:
- **Actions**: https://github.com/mitre/cyber-trackr-live/actions
- **Releases**: https://github.com/mitre/cyber-trackr-live/releases
- **RubyGems**: https://rubygems.org/gems/cyber_trackr_live

## Quick Troubleshooting

- **"Working directory not clean"** → Commit or stash changes first
- **"Must be on main branch"** → Run `git checkout main`
- **Version check fails** → Run `bundle exec rake version_check` for details
- **Tests failing** → Fix issues before releasing

For more help, see [Troubleshooting](./troubleshooting.md).