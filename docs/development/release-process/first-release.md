# First Release Setup

This guide covers the one-time setup required for the very first release of a new gem.

## Overview

The first release requires manual steps to establish trust between GitHub Actions and RubyGems.org. After this initial setup, all future releases are fully automated.

## Step 1: Manual Gem Publication

For the **very first release only**, you must manually publish the gem:

```bash
# Build the gem
gem build cyber_trackr_live.gemspec

# Push to RubyGems.org (requires account and ownership)
gem push cyber_trackr_live-1.0.0.gem
```

### Prerequisites
- RubyGems.org account
- Gem ownership (or be added as owner)
- Valid `.gem` credentials locally

## Step 2: Configure OIDC Trusted Publishing

After the gem exists on RubyGems.org, set up trusted publishing:

1. **Navigate to pending publishers**:
   ```
   https://rubygems.org/profile/oidc/pending_trusted_publishers
   ```

2. **Add trusted publisher** with these exact values:
   - **Repository URL**: `https://github.com/mitre/cyber-trackr-live`
   - **Workflow filename**: `release-tag.yml`
   - **Environment**: (leave blank)
   - **Gem name**: `cyber_trackr_live`

3. **Click** "Create Pending trusted publisher"

4. **Verify** the publisher appears in your list

## Step 3: Activate Trusted Publisher

The pending publisher becomes active when:
1. A GitHub Actions workflow runs with matching configuration
2. The workflow successfully authenticates via OIDC

To activate:
```bash
# Create a patch release
bundle exec rake release:patch
git push origin main

# Trigger the workflow
bundle exec rake release
```

The GitHub Actions workflow will:
- Detect the OIDC configuration
- Authenticate with RubyGems
- Publish the gem automatically
- Activate the trusted publisher

## Verification

After the first automated release:

1. **Check RubyGems.org**:
   - Go to https://rubygems.org/gems/cyber_trackr_live
   - Verify new version is published
   - Check "Trusted Publishers" tab shows GitHub configuration

2. **Check GitHub Actions**:
   - Go to https://github.com/mitre/cyber-trackr-live/actions
   - Verify workflow completed successfully
   - Check "Configure RubyGems credentials" step shows success

3. **Check trusted publisher status**:
   - Go to https://rubygems.org/profile/oidc/trusted_publishers
   - Publisher should now show as "Active" (not "Pending")

## Why This Pattern?

### Security Benefits
- **No API keys** stored in GitHub Secrets
- **Cryptographic proof** of release source
- **Audit trail** of all publications

### One-Time Setup
- First release establishes trust
- All future releases are automatic
- No maintenance required

## Troubleshooting First Release

### "Gem already exists" Error
- Someone else already published version 1.0.0
- Increment version and try again

### "Unauthorized" Error
- Ensure you have gem ownership
- Check your RubyGems credentials

### Trusted Publisher Not Activating
- Verify workflow filename matches exactly
- Check repository URL has no typos
- Ensure gem name matches exactly

### OIDC Authentication Failing
- Check `id-token: write` permission in workflow
- Verify `rubygems/configure-rubygems-credentials@v1` action
- Check no conflicting gem credentials in CI

## After First Release

Once the trusted publisher is active:
- ✅ All future releases are automated
- ✅ No manual gem publication needed
- ✅ No API keys required
- ✅ GitHub Actions handles everything

Follow the [Quick Release Guide](./quick-release.md) for all subsequent releases.