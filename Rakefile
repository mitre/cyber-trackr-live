# frozen_string_literal: true

# A Rakefile defines tasks to help maintain your project.
# Rake provides several task templates that are useful.

# Load release tasks
Dir.glob('tasks/*.rake').each { |r| import r }

#------------------------------------------------------------------#
#                    Test Runner Tasks
#------------------------------------------------------------------#

# This task template will make a task named 'test', and run
# the tests that it finds.
require 'rake/testtask'

#------------------------------------------------------------------#
#                    Two-Stage Testing Pattern
#------------------------------------------------------------------#

# Stage 1: Fast tests (no gem build needed)
# These tests validate OpenAPI spec, syntax, and completeness
Rake::TestTask.new('test:stage1') do |t|
  t.libs.push 'lib'
  t.test_files = FileList[
    'test/openapi_validation_test.rb',
    'test/spec_completeness_test.rb',
    'test/comprehensive_openapi_test.rb'
  ]
  t.verbose = true
  t.warning = false
end

# Stage 2A: Helper tests (with WebMock for mocking)
Rake::TestTask.new('test:stage2a') do |t|
  t.libs.push 'lib'
  t.test_files = FileList[
    'test/cyber_trackr_helper_test.rb'
  ]
  t.verbose = true
  t.warning = false
end

# Stage 2B: Live integration tests (without WebMock - real HTTP calls)
desc 'Run live integration tests (makes real HTTP calls)'
task 'test:stage2b' do
  puts '🌐 Running live integration tests...'
  
  # Run each integration test separately to avoid WebMock conflicts
  live_tests = [
    'test/live_api_validation_test.rb',
    'test/integration/live_integration_test.rb'
  ]
  
  live_tests.each do |test_file|
    puts "   Running #{test_file}..."
    system("bundle exec ruby -I\"lib\" #{test_file}") or abort("❌ Live integration test failed: #{test_file}")
  end
  
  puts '✅ Live integration tests completed'
end

# Two-stage testing workflow
desc 'Run two-stage testing pattern (Stage 1: fast validation, Stage 2: integration)'
task 'test:two_stage' do
  puts '🚀 Starting Two-Stage Testing Pattern'
  puts ''
  
  # Stage 1: Fast validation (no gem build needed)
  puts '📋 Stage 1: Fast Validation Tests'
  puts '   - OpenAPI specification validation'
  puts '   - Specification completeness checks'
  puts '   - Comprehensive OpenAPI tests'
  puts '   - Content-Type fix validation'
  puts ''
  
  Rake::Task['test:stage1'].invoke
  puts '✅ Stage 1 tests passed!'
  puts ''
  
  # Stage 2: Integration tests (requires building local gem)
  puts '📦 Stage 2: Integration Tests (with local gem)'
  puts '   - Building local gem for testing...'
  
  # Build local gem
  system('gem build cyber_trackr_live.gemspec') or abort('❌ Failed to build gem for Stage 2 testing')
  puts '   ✅ Local gem built successfully'
  
  puts '   - Running Stage 2A: Helper tests (with mocking)...'
  Rake::Task['test:stage2a'].invoke
  puts '   ✅ Stage 2A: Helper tests passed!'
  
  puts '   - Running Stage 2B: Live integration tests (real HTTP calls)...'
  Rake::Task['test:stage2b'].invoke
  puts '   ✅ Stage 2B: Live integration tests passed!'
  
  puts '✅ Stage 2 tests completed!'
  puts ''
  
  # Cleanup
  Dir.glob('cyber_trackr_live-*.gem').each { |f| File.delete(f) }
  puts '🧹 Cleaned up test artifacts'
  puts ''
  puts '🎉 Two-stage testing complete!'
end

# Default test task - runs Stage 1 only (fast)
Rake::TestTask.new do |t|
  t.libs.push 'lib'
  t.test_files = FileList[
    'test/openapi_validation_test.rb',
    'test/spec_completeness_test.rb',
    'test/comprehensive_openapi_test.rb'
  ]
  t.verbose = true
  t.warning = false
end

# Aliases for compatibility
task 'test:unit' => 'test:stage1'
task 'test:openapi' => 'test:stage1'
task 'test:integration' => 'test:stage2b'
task 'test:stage2' => ['test:stage2a', 'test:stage2b']

# All tests including integration
Rake::TestTask.new('test:all') do |t|
  t.libs.push 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
  t.warning = false
end

#------------------------------------------------------------------#
#                    Code Style Tasks
#------------------------------------------------------------------#
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:lint) do |t|
  # Use our local .rubocop.yml configuration
  t.options = ['--display-cop-names', '--config', '.rubocop.yml']
end

#------------------------------------------------------------------#
#                    Security Tasks
#------------------------------------------------------------------#

desc 'Run dependency vulnerability scan'
task 'security:dependencies' do
  puts 'Running bundler-audit dependency scan...'
  system('bundle exec bundle-audit update') or puts 'Failed to update vulnerability database'
  system('bundle exec bundle-audit check') or abort('Vulnerable dependencies found')
end

desc 'Run all security checks'
task security: %w[security:dependencies]

#------------------------------------------------------------------#
#                    Load Additional Tasks
#------------------------------------------------------------------#
Dir['tasks/*.rake'].each { |f| load f }

#------------------------------------------------------------------#
#                    Documentation Tasks
#------------------------------------------------------------------#
begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb']
    t.options = ['--no-private']
    t.stats_options = ['--list-undoc']
  end
rescue LoadError
  desc 'YARD documentation task'
  task :yard do
    puts 'YARD is not available. Run `bundle install` to install it.'
  end
end

#------------------------------------------------------------------#
#                    Bundler Gem Tasks
#------------------------------------------------------------------#
# Enable bundler gem tasks for local release preparation
require 'bundler/gem_tasks'

# Version bump tasks
namespace :version do
  desc 'Bump major version (X.0.0)'
  task :major do
    bump_version(:major)
  end

  desc 'Bump minor version (x.X.0)'
  task :minor do
    bump_version(:minor)
  end

  desc 'Bump patch version (x.x.X)'
  task :patch do
    bump_version(:patch)
  end

  def bump_version(type)
    # Read current version from OpenAPI spec
    openapi_path = 'openapi/openapi.yaml'
    content = File.read(openapi_path)
    current_version = content.match(/^\s*version:\s*(.+)$/)[1].strip

    # Parse version
    major, minor, patch = current_version.split('.').map(&:to_i)

    # Bump appropriate part
    case type
    when :major
      major += 1
      minor = 0
      patch = 0
    when :minor
      minor += 1
      patch = 0
    when :patch
      patch += 1
    end

    new_version = "#{major}.#{minor}.#{patch}"

    # Update OpenAPI spec
    new_content = content.gsub(/^(\s*version:\s*)(.+)$/, "\\1#{new_version}")
    File.write(openapi_path, new_content)

    puts "✓ Bumped version from #{current_version} to #{new_version} in openapi/openapi.yaml"
    puts ''
    puts 'Next steps:'
    puts "1. Run 'make generate' to regenerate the client"
    puts '2. Update CHANGELOG-OPENAPI.md and/or CHANGELOG-GEM.md'
    puts '3. Commit all changes'
    puts "4. Run 'bundle exec rake prepare_release'"
  end
end

# Simple release preparation task
desc 'Prepare release (check versions, tag, and push)'
task :prepare_release do
  puts 'Preparing release...'

  # Read version from OpenAPI spec (single source of truth)
  openapi_content = File.read('openapi/openapi.yaml')
  openapi_version = openapi_content.match(/^\s*version:\s*(.+)$/)[1].strip

  # Check if generated version matches
  require_relative 'lib/cyber_trackr_client/version'
  if openapi_version != CyberTrackrClient::VERSION
    abort "❌ Version mismatch! OpenAPI: #{openapi_version}, Generated: #{CyberTrackrClient::VERSION}\nRun 'make generate' to regenerate the client."
  end

  puts "✓ Version #{openapi_version} is consistent"

  # Check for uncommitted changes
  abort '❌ Uncommitted changes found. Please commit all changes first.' unless system('git diff --quiet && git diff --cached --quiet')

  # Create and push tag
  tag = "v#{openapi_version}"
  puts "Creating tag #{tag}..."

  abort "❌ Tag #{tag} already exists" if system("git tag -l #{tag} | grep -q #{tag}")

  system("git tag -a #{tag} -m 'Release version #{openapi_version}'") or abort('Failed to create tag')
  puts "✓ Tag created. Push with: git push origin #{tag}"
  puts ''
  puts 'Next steps:'
  puts "1. git push origin #{tag}"
  puts '2. GitHub Actions will automatically publish to RubyGems'
end
