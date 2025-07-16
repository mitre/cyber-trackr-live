# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cyber_trackr_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'cyber_trackr_live'
  spec.version       = CyberTrackrClient::VERSION
  spec.authors       = ['MITRE Corporation']
  spec.email         = ['saf@mitre.org']
  spec.summary       = 'OpenAPI specification and Ruby client for cyber.trackr.live API'
  spec.description   = 'Provides OpenAPI 3.1.1 specification and Ruby client for accessing DISA STIGs, SRGs, RMF controls, CCIs, and SCAP data via the cyber.trackr.live API'
  spec.homepage      = 'https://github.com/mitre/cyber-trackr-live'
  spec.license       = 'Apache-2.0'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/mitre/cyber-trackr-live/issues',
    'changelog_uri' => 'https://github.com/mitre/cyber-trackr-live/blob/main/CHANGELOG-GEM.md',
    'documentation_uri' => 'https://mitre.github.io/cyber-trackr-live/',
    'homepage_uri' => 'https://github.com/mitre/cyber-trackr-live',
    'source_code_uri' => 'https://github.com/mitre/cyber-trackr-live',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = %w[
    README-GEM.md cyber_trackr_live.gemspec LICENSE.md NOTICE.md CHANGELOG-GEM.md
    CODE_OF_CONDUCT.md CONTRIBUTING.md SECURITY.md
  ] + Dir.glob('lib/**/*', File::FNM_DOTMATCH).reject { |f| File.directory?(f) } +
               Dir.glob('openapi/**/*', File::FNM_DOTMATCH).reject { |f| File.directory?(f) } +
               Dir.glob('examples/**/*', File::FNM_DOTMATCH).reject { |f| File.directory?(f) }

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.2.0'

  # Use the gem-specific README for RubyGems.org
  spec.extra_rdoc_files = ['README-GEM.md']
  spec.rdoc_options = ['--main', 'README-GEM.md']

  # Runtime dependencies
  spec.add_dependency 'typhoeus', '~> 1.4'
  spec.add_dependency 'yard', '~> 0.9'

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
