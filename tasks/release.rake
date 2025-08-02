# frozen_string_literal: true

require 'time'
require 'yaml'
require 'json'

namespace :release do # rubocop:disable Metrics/BlockLength
  desc 'Cut a new patch release (e.g., 1.0.0 -> 1.0.1)'
  task :patch do
    release('patch')
  end

  desc 'Cut a new minor release (e.g., 1.0.0 -> 1.1.0)'
  task :minor do
    release('minor')
  end

  desc 'Cut a new major release (e.g., 1.0.0 -> 2.0.0)'
  task :major do
    release('major')
  end

  def release(type)
    # Ensure working directory is clean
    abort 'Error: Working directory is not clean. Commit or stash your changes first.' unless `git status --porcelain`.empty?

    # Ensure we're on main branch
    current_branch = `git rev-parse --abbrev-ref HEAD`.strip
    abort "Error: Must be on main branch to release (currently on #{current_branch})" unless current_branch == 'main'

    # Pull latest changes
    system('git pull origin main') or abort('Failed to pull latest changes')

    # Get current version from OpenAPI spec (source of truth)
    openapi_file = 'openapi/openapi.yaml'
    openapi_content = YAML.load_file(openapi_file)
    current_version = openapi_content['info']['version']
    puts "Current version: #{current_version}"

    # Calculate new version
    major, minor, patch = current_version.split('.').map(&:to_i)
    case type
    when 'major'
      new_version = "#{major + 1}.0.0"
    when 'minor'
      new_version = "#{major}.#{minor + 1}.0"
    when 'patch'
      new_version = "#{major}.#{minor}.#{patch + 1}"
    end
    puts "New version: #{new_version}"

    # Update OpenAPI spec (source of truth)
    openapi_content['info']['version'] = new_version
    File.write(openapi_file, YAML.dump(openapi_content))
    puts "✓ Updated #{openapi_file}"

    # Sync package.json version from OpenAPI
    sync_package_json_version(new_version)

    # Regenerate Ruby client with new version
    puts 'Regenerating Ruby client...'
    system('make generate') or abort('Failed to regenerate Ruby client')
    puts '✓ Regenerated Ruby client'

    # Update Gemfile.lock to reflect new version
    system('bundle install --quiet') or abort('Failed to update Gemfile.lock')
    puts '✓ Updated Gemfile.lock'

    # Run two-stage testing pattern
    puts 'Running two-stage testing pattern...'
    system('bundle exec rake test:two_stage') or abort('Tests failed - cannot release')
    puts '✓ Two-stage testing complete'

    # Run linting with auto-correction
    puts 'Running lint checks with auto-correction...'
    system('bundle exec rubocop --autocorrect') or abort('Lint checks failed - cannot release')
    puts '✓ Lint checks passed with auto-corrections applied'

    # Generate changelog with git-cliff
    generate_changelog_with_git_cliff(new_version)

    # Create release notes with git-cliff
    create_release_notes_with_git_cliff(new_version)

    # Regenerate documentation
    puts 'Regenerating documentation...'
    system('npm run docs:build') or abort('Failed to regenerate documentation')
    puts '✓ Regenerated documentation'

    # Commit changes
    files_to_add = [
      'openapi/openapi.yaml',
      'package.json',
      'lib/cyber_trackr_client/',
      'Gemfile.lock',
      'CHANGELOG-OPENAPI.md',
      'CHANGELOG-GEM.md',
      "docs/release-notes/v#{new_version}.md",
      'docs/.vitepress/dist/'
    ]
    system("git add #{files_to_add.join(' ')}")
    system("git commit -m 'Bump version to #{new_version}'") or abort('Failed to commit changes')

    puts "\n🎉 Release #{new_version} prepared!"
    puts "\nNext steps:"
    puts '  1. Review the changes: git show'
    puts '  2. Push commits: git push origin main'
    puts '  3. Run release: bundle exec rake release'
    puts "\nThis will:"
    puts "  - Create tag v#{new_version}"
    puts '  - Push the tag to GitHub'
    puts '  - Trigger GitHub Actions to publish gem and deploy docs'
  end

  def sync_package_json_version(version)
    package_file = 'package.json'
    package_content = JSON.parse(File.read(package_file))
    package_content['version'] = version
    File.write(package_file, "#{JSON.pretty_generate(package_content)}\n")
    puts "✓ Synced package.json version to #{version}"
  end

  def validate_version_consistency(expected_version)
    puts 'Validating version consistency...'

    # Check OpenAPI spec
    openapi_version = YAML.load_file('openapi/openapi.yaml')['info']['version']
    abort "❌ OpenAPI version mismatch: expected #{expected_version}, got #{openapi_version}" unless openapi_version == expected_version

    # Check generated client version
    client_version_file = 'lib/cyber_trackr_client/version.rb'
    if File.exist?(client_version_file)
      client_version = File.read(client_version_file)[/VERSION = ['"](.+)['"]/, 1]
      abort "❌ Client version mismatch: expected #{expected_version}, got #{client_version}" unless client_version == expected_version
    end

    # Check package.json
    package_version = JSON.parse(File.read('package.json'))['version']
    abort "❌ Package.json version mismatch: expected #{expected_version}, got #{package_version}" unless package_version == expected_version

    puts '✓ All versions are consistent'
  end

  def update_changelog(version)
    # Update OpenAPI changelog
    update_openapi_changelog(version)

    # Update gem changelog
    update_gem_changelog(version)
  end

  def update_openapi_changelog(version)
    changelog_file = 'CHANGELOG-OPENAPI.md'

    # Get OpenAPI-related changes since last tag
    last_tag = `git describe --tags --abbrev=0 2>/dev/null`.strip
    changes = if last_tag.empty?
                `git log --oneline --grep="openapi\\|spec\\|docs" --grep="API" -i`.lines.take(10)
              else
                `git log #{last_tag}..HEAD --oneline --grep="openapi\\|spec\\|docs" --grep="API" -i`.lines
              end

    # Create entry
    date = Time.now.strftime('%Y-%m-%d')
    new_section = "\n## [#{version}] - #{date}\n\n"

    if changes.any?
      new_section += "### OpenAPI Specification Changes\n\n"
      new_section += changes.map { |c| "- #{c.strip.sub(/^[a-f0-9]+ /, '')}" }.join("\n")
      new_section += "\n"
    else
      new_section += "- Version bump and maintenance updates\n"
    end

    prepend_to_changelog(changelog_file, new_section)
    puts "✓ Updated #{changelog_file}"
  end

  def update_gem_changelog(version)
    changelog_file = 'CHANGELOG-GEM.md'

    # Get gem/client-related changes since last tag
    last_tag = `git describe --tags --abbrev=0 2>/dev/null`.strip
    changes = if last_tag.empty?
                `git log --oneline --grep="gem\\|client\\|ruby\\|test" -i`.lines.take(10)
              else
                `git log #{last_tag}..HEAD --oneline --grep="gem\\|client\\|ruby\\|test" -i`.lines
              end

    # Create entry
    date = Time.now.strftime('%Y-%m-%d')
    new_section = "\n## [#{version}] - #{date}\n\n"

    if changes.any?
      new_section += "### Ruby Gem Changes\n\n"
      new_section += changes.map { |c| "- #{c.strip.sub(/^[a-f0-9]+ /, '')}" }.join("\n")
      new_section += "\n"
    else
      new_section += "- Version bump to match OpenAPI specification\n"
      new_section += "- Regenerated client with latest OpenAPI spec\n"
    end

    prepend_to_changelog(changelog_file, new_section)
    puts "✓ Updated #{changelog_file}"
  end

  def prepend_to_changelog(file, content)
    if File.exist?(file)
      existing = File.read(file)
      File.write(file, existing.sub(/(\n## )/, "#{content}\\1"))
    else
      header = "# Changelog\n\nAll notable changes to this project will be documented in this file.\n"
      File.write(file, header + content)
    end
  end

  def create_release_notes(version)
    notes_dir = 'docs/release-notes'
    FileUtils.mkdir_p(notes_dir)

    notes_file = "#{notes_dir}/v#{version}.md"

    # Get list of changes since last tag
    last_tag = `git describe --tags --abbrev=0 2>/dev/null`.strip
    changes = if last_tag.empty?
                `git log --oneline`.lines.take(15)
              else
                `git log #{last_tag}..HEAD --oneline`.lines
              end

    # Format release notes
    content = <<~NOTES
      # Release Notes for v#{version}

      Released: #{Time.now.strftime('%Y-%m-%d')}

      ## What's Changed

      #{changes.map { |c| "- #{c.strip.sub(/^[a-f0-9]+ /, '')}" }.join("\n")}

      ## Installation

      ### Ruby Gem

      ```bash
      gem install cyber_trackr_live -v #{version}
      ```

      Or add to your Gemfile:

      ```ruby
      gem 'cyber_trackr_live', '~> #{version}'
      ```

      ### OpenAPI Documentation

      The interactive API documentation is available at:
      - [GitHub Pages](https://mitre.github.io/cyber-trackr-live/)
      - [Raw OpenAPI Spec](https://raw.githubusercontent.com/mitre/cyber-trackr-live/v#{version}/openapi/openapi.yaml)

      ## Usage Example

      ```ruby
      require 'cyber_trackr_live'

      # Initialize the client
      client = CyberTrackrClient::ApiClient.new

      # Use the helper for convenience
      helper = CyberTrackrHelper.new

      # List all STIGs
      stigs = helper.list_stigs
      puts "Found \#{stigs.size} STIGs"

      # Get a complete STIG with all requirements
      complete_stig = helper.fetch_complete_stig('Juniper_SRX_Services_Gateway_ALG', '3', '3')
      puts "STIG has \#{complete_stig[:requirements].size} requirements"
      ```

      ## Full Changelog

      - [OpenAPI Changes](../reference/changelog-openapi)
      - [Ruby Gem Changes](../reference/changelog-ruby)
    NOTES

    File.write(notes_file, content)
    puts "✓ Created release notes at #{notes_file}"
  end

  # New git-cliff based changelog generation
  def generate_changelog_with_git_cliff(_version)
    puts 'Generating changelogs with git-cliff...'

    # Generate OpenAPI changelog (docs, api, spec related changes)
    system('git-cliff --include-path "openapi/**" --include-path "docs/**" ' \
           '--include-path "package.json" --include-path "*.md" --output CHANGELOG-OPENAPI.md') ||
      abort('Failed to generate OpenAPI changelog')
    puts '✓ Updated CHANGELOG-OPENAPI.md'

    # Generate Ruby gem changelog (lib, test, gem related changes)
    system('git-cliff --include-path "lib/**" --include-path "test/**" ' \
           '--include-path "*.gemspec" --include-path "Gemfile*" ' \
           '--include-path "Rakefile" --include-path "tasks/**" --output CHANGELOG-GEM.md') ||
      abort('Failed to generate gem changelog')
    puts '✓ Updated CHANGELOG-GEM.md'
  end

  def create_release_notes_with_git_cliff(version)
    notes_dir = 'docs/release-notes'
    FileUtils.mkdir_p(notes_dir)
    notes_file = "#{notes_dir}/v#{version}.md"

    # Generate release notes for this version using git-cliff
    system("git-cliff --tag v#{version} --unreleased > #{notes_file}") or abort('Failed to generate release notes')

    # Add installation and usage sections to the generated notes
    additional_content = <<~NOTES

      ## Installation

      ### Ruby Gem

      ```bash
      gem install cyber_trackr_live -v #{version}
      ```

      Or add to your Gemfile:

      ```ruby
      gem 'cyber_trackr_live', '~> #{version}'
      ```

      ### OpenAPI Documentation

      The interactive API documentation is available at:
      - [GitHub Pages](https://mitre.github.io/cyber-trackr-live/)
      - [Raw OpenAPI Spec](https://raw.githubusercontent.com/mitre/cyber-trackr-live/v#{version}/openapi/openapi.yaml)

      ## Usage Example

      ```ruby
      require 'cyber_trackr_live'

      # Initialize the client
      client = CyberTrackrClient::ApiClient.new

      # Use the helper for convenience
      helper = CyberTrackrHelper.new

      # List all STIGs
      stigs = helper.list_stigs
      puts "Found \#{stigs.size} STIGs"

      # Get a complete STIG with all requirements
      complete_stig = helper.fetch_complete_stig('Juniper_SRX_Services_Gateway_ALG', '3', '3')
      puts "STIG has \#{complete_stig[:requirements].size} requirements"
      ```

      ## Full Changelog

      - [OpenAPI Changes](../reference/changelog-openapi)
      - [Ruby Gem Changes](../reference/changelog-ruby)
    NOTES

    # Append additional content
    File.write(notes_file, File.read(notes_file) + additional_content)
    puts "✓ Created release notes at #{notes_file}"
  end

  def current_version
    YAML.load_file('openapi/openapi.yaml')['info']['version']
  end
end

desc 'Show current version from OpenAPI spec'
task :version do
  puts YAML.load_file('openapi/openapi.yaml')['info']['version']
end

desc 'Validate version consistency across all files'
task :version_check do
  openapi_version = YAML.load_file('openapi/openapi.yaml')['info']['version']

  puts "OpenAPI version: #{openapi_version}"

  # Check client version if generated
  client_version_file = 'lib/cyber_trackr_client/version.rb'
  if File.exist?(client_version_file)
    client_version = File.read(client_version_file)[/VERSION = ['"](.+)['"]/, 1]
    puts "Client version: #{client_version}"
    puts client_version == openapi_version ? '✓ Client version matches' : '❌ Client version mismatch'
  else
    puts '⚠️  Client not generated yet'
  end

  # Check package.json
  package_version = JSON.parse(File.read('package.json'))['version']
  puts "Package.json version: #{package_version}"
  puts package_version == openapi_version ? '✓ Package.json version matches' : '❌ Package.json version mismatch'
end

# Override the default Bundler release task for GitHub Actions integration
desc 'Tag and push release (GitHub Actions handles gem publication)'
task :release do
  # Ensure we're on main branch
  current_branch = `git rev-parse --abbrev-ref HEAD`.strip
  abort "Error: Must be on main branch to release (currently on #{current_branch})" unless current_branch == 'main'

  # Get current version from OpenAPI spec
  version = YAML.load_file('openapi/openapi.yaml')['info']['version']
  tag = "v#{version}"

  # Check if tag already exists
  existing_tags = `git tag -l #{tag}`.strip
  if existing_tags.empty?
    # Create and push tag
    system("git tag #{tag}") or abort("Failed to create tag #{tag}")
    system("git push origin #{tag}") or abort("Failed to push tag #{tag}")

    puts "✅ Tagged #{tag}"
    puts '✅ Pushed tag to GitHub'
    puts ''
    puts '🚀 GitHub Actions will now:'
    puts '   - Run all tests'
    puts '   - Validate OpenAPI spec'
    puts '   - Deploy documentation to GitHub Pages'
    puts '   - Publish gem to RubyGems.org'
    puts ''
    puts '📦 Monitor the release at: https://github.com/mitre/cyber-trackr-live/actions'
  else
    # Tag exists, we're in GitHub Actions
    puts "Tag #{tag} already exists - running in GitHub Actions"

    # Check if we're using OIDC trusted publishing (preferred method)
    if ENV['GITHUB_ACTIONS'] && ENV['GEM_HOST_API_KEY']
      puts '✅ OIDC trusted publishing detected - gem publication handled by rubygems/configure-rubygems-credentials'
      puts '✅ Release process complete!'
    else
      # Fallback to manual gem publication if OIDC not available
      puts 'No OIDC detected - proceeding with manual gem build and push'

      # Build the gem in pkg/ directory
      FileUtils.mkdir_p('pkg')
      gem_file = "cyber_trackr_live-#{version}.gem"
      system("gem build cyber_trackr_live.gemspec -o pkg/#{gem_file}") or abort('Failed to build gem')

      # Push to RubyGems from pkg/ directory
      system("gem push pkg/#{gem_file}") or abort('Failed to push gem to RubyGems')

      puts "✅ Published #{gem_file} to RubyGems.org"
    end
  end
end
