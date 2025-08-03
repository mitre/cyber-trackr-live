# Release Troubleshooting

Common issues and solutions for the release process.

## Pre-Release Issues

### "Working directory is not clean"

**Error**: 
```
ERROR: Working directory is not clean. Please commit or stash changes.
```

**Solution**:
```bash
# Check what's changed
git status

# Option 1: Commit changes
git add .
git commit -m "Your message"

# Option 2: Stash changes
git stash

# Option 3: Discard changes (careful!)
git checkout -- .
```

### "Must be on main branch"

**Error**:
```
ERROR: Must be on main branch to release
```

**Solution**:
```bash
# Switch to main branch
git checkout main

# Update from remote
git pull origin main
```

### "Version consistency check failed"

**Error**:
```
ERROR: Version mismatch detected
```

**Solution**:
```bash
# Check version details
bundle exec rake version_check

# Regenerate client if needed
make generate

# Sync package.json
bundle exec rake sync_package_version
```

## Test Failures

### "Tests failing after regeneration"

**Symptoms**:
- Tests pass before regeneration
- Fail after running `make generate`

**Solutions**:
1. **Validate OpenAPI spec**:
   ```bash
   npm run docs:validate
   ```

2. **Check for schema issues**:
   - Missing required fields
   - Invalid examples
   - Type mismatches

3. **Regenerate cleanly**:
   ```bash
   rm -rf lib/cyber_trackr_client
   make generate
   bundle exec rake test
   ```

### "RuboCop failures"

**Error**:
```
Offenses detected by RuboCop
```

**Solution**:
```bash
# Auto-fix what's possible
bundle exec rubocop -a

# Check remaining issues
bundle exec rubocop

# Fix manually if needed
```

## Client Generation Issues

### "Docker not found"

**Error**:
```
docker: command not found
```

**Solution**:
- Install Docker Desktop
- Ensure Docker is running
- Restart terminal after installation

### "OpenAPI Generator fails"

**Symptoms**:
- Generation starts but fails
- Partial files created

**Solutions**:
1. **Check OpenAPI validity**:
   ```bash
   npm run docs:validate
   ```

2. **Check generation logs**:
   ```bash
   # Run with verbose output
   docker run --rm -v "${PWD}:/local" \
     openapitools/openapi-generator-cli generate \
     -i /local/openapi/openapi.yaml \
     -g ruby \
     -o /local/lib/cyber_trackr_client \
     --log-to-stderr
   ```

3. **Clean and retry**:
   ```bash
   rm -rf lib/cyber_trackr_client
   make generate
   ```

## GitHub Actions Issues

### "Workflow not triggering"

**Symptoms**:
- Tag pushed but no workflow runs

**Solutions**:
1. **Check tag format**:
   ```bash
   # Must match pattern v*
   git tag  # List tags
   git tag v1.0.0  # Correct format
   ```

2. **Check workflow file exists**:
   ```bash
   ls -la .github/workflows/release-tag.yml
   ```

3. **Force push tag**:
   ```bash
   git push origin --delete v1.0.0
   git tag -d v1.0.0
   git tag v1.0.0
   git push origin v1.0.0
   ```

### "OIDC authentication failed"

**Error in Actions**:
```
Error: Could not authenticate with RubyGems
```

**Solutions**:
1. **Check trusted publisher configuration**:
   - Go to https://rubygems.org/gems/cyber_trackr_live/trusted_publishers
   - Verify repository and workflow match exactly

2. **Check workflow permissions**:
   ```yaml
   permissions:
     contents: write
     id-token: write  # Required for OIDC
   ```

3. **Verify action version**:
   ```yaml
   - uses: rubygems/configure-rubygems-credentials@v1
   ```

### "Gem publication failed"

**Error**:
```
ERROR: Gem already exists
```

**Solutions**:
1. **Version already published**:
   - Increment version
   - Try release again

2. **Check RubyGems.org**:
   ```bash
   gem list -r cyber_trackr_live
   ```

## Manual Recovery

### Regenerate Client Manually

```bash
docker run --rm \
  -v "${PWD}:/local" \
  openapitools/openapi-generator-cli generate \
  -i /local/openapi/openapi.yaml \
  -g ruby \
  --library=faraday \
  --additional-properties=gemName=cyber_trackr_client,moduleName=CyberTrackrClient \
  -o /local/lib/cyber_trackr_client
```

### Sync Versions Manually

```bash
# Get version from OpenAPI
VERSION=$(ruby -ryaml -e "puts YAML.load_file('openapi/openapi.yaml')['info']['version']")

# Update package.json
npm version $VERSION --no-git-tag-version

# Verify
bundle exec rake version_check
```

### Create GitHub Release Manually

If automated release fails:
1. Go to https://github.com/mitre/cyber-trackr-live/releases/new
2. Choose the tag you pushed
3. Copy content from `docs/release-notes/v{version}.md`
4. Publish release

### Publish Gem Manually

If OIDC fails (after first release):
```bash
# Build gem
gem build cyber_trackr_live.gemspec

# Push to RubyGems
gem push cyber_trackr_live-{version}.gem
```

## Monitoring

### Check Release Progress

- **GitHub Actions**: https://github.com/mitre/cyber-trackr-live/actions
- **Release Page**: https://github.com/mitre/cyber-trackr-live/releases
- **RubyGems**: https://rubygems.org/gems/cyber_trackr_live
- **Documentation**: https://mitre.github.io/cyber-trackr-live/

### Verify Deployment

```bash
# Check gem is available
gem list -r cyber_trackr_live

# Test installation
gem install cyber_trackr_live -v {version}

# Verify documentation updated
curl -I https://mitre.github.io/cyber-trackr-live/
```

## Getting Help

If these solutions don't work:
1. Check [GitHub Issues](https://github.com/mitre/cyber-trackr-live/issues)
2. Review [GitHub Actions logs](https://github.com/mitre/cyber-trackr-live/actions)
3. Ask in [Discussions](https://github.com/mitre/cyber-trackr-live/discussions)