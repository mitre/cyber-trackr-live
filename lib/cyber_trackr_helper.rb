# frozen_string_literal: true

require_relative 'cyber_trackr_client'

# Helper methods for the Cyber Trackr API
# Provides convenience methods on top of the generated client
module CyberTrackrHelper
  class Client
    attr_reader :api_client, :documents_api, :cci_api, :rmf_controls_api, :scap_api

    def initialize(config = {})
      # Configure the client
      CyberTrackrClient.configure do |c|
        c.host = config[:host] || 'cyber.trackr.live'
        c.base_path = config[:base_path] || '/api'
        c.debugging = config[:debugging] || false
        c.timeout = config[:timeout] || 30
      end

      # Initialize API interfaces
      @api_client = CyberTrackrClient::ApiClient.default
      @documents_api = CyberTrackrClient::DocumentsApi.new(@api_client)
      @cci_api = CyberTrackrClient::CCIApi.new(@api_client)
      @rmf_controls_api = CyberTrackrClient::RMFControlsApi.new(@api_client)
      @scap_api = CyberTrackrClient::SCAPApi.new(@api_client)
    end

    # Fetch a complete STIG with all control details
    # @param name [String] STIG name
    # @param version [String] Version number
    # @param release [String] Release number
    # @param delay [Float] Delay between API calls in seconds (default: 0.1)
    # @yield [current, total, vuln_id] Progress callback
    # @return [Hash] Complete STIG with all control details
    def fetch_complete_stig(name, version, release, delay: 0.1)
      # Get the base document
      doc = @documents_api.get_document(name, version, release)

      # Convert to hash for easier manipulation
      result = doc.to_hash

      # Check if we have requirements to fetch
      return result if result[:requirements].nil? || result[:requirements].empty?

      total = result[:requirements].size

      # Fetch detailed data for each requirement
      index = 0
      result[:requirements].each_key do |vuln_id|
        # Progress callback
        yield(index + 1, total, vuln_id) if block_given?

        begin
          # Fetch detailed control data
          detailed = @documents_api.get_requirement(name, version, release, vuln_id)

          # Replace summary with detailed data
          result[:requirements][vuln_id] = detailed.to_hash

          # Rate limiting
          sleep delay if delay.positive? && index < total - 1
        rescue StandardError => e
          warn "Failed to fetch details for #{vuln_id}: #{e.message}"
        end

        index += 1
      end

      result
    end

    # List all STIGs (filters out SRGs)
    # @return [Hash] Hash of STIG names to version arrays
    def list_stigs
      all_docs = @documents_api.list_all_documents
      all_docs.reject { |name, _versions| is_srg?(name) }
    end

    # List all SRGs (filters out STIGs)
    # @return [Hash] Hash of SRG names to version arrays
    def list_srgs
      all_docs = @documents_api.list_all_documents
      all_docs.select { |name, _versions| is_srg?(name) }
    end

    # Check if a document name is an SRG
    # @param name [String] Document name
    # @return [Boolean] true if SRG, false if STIG
    def is_srg?(name)
      name_str = name.to_s
      name_str.include?('Security_Requirements_Guide') ||
        name_str.include?('(SRG)') ||
        name_str.end_with?('SRG')
    end

    # Search for documents by keyword
    # @param keyword [String] Search term
    # @param type [Symbol] :all, :stig, or :srg
    # @return [Hash] Matching documents
    def search_documents(keyword, type: :all)
      all_docs = @documents_api.list_all_documents

      # Filter by type if requested
      filtered = case type
                 when :stig
                   all_docs.reject { |name, _| is_srg?(name) }
                 when :srg
                   all_docs.select { |name, _| is_srg?(name) }
                 else
                   all_docs
                 end

      # Search by keyword
      filtered.select { |name, _| name.to_s.downcase.include?(keyword.downcase) }
    end

    # Get the latest version of a document
    # @param name [String] Document name
    # @return [Hash, nil] Latest version info or nil if not found
    def get_latest_version(name)
      all_docs = @documents_api.list_all_documents
      # Handle both string and symbol keys
      versions = all_docs[name] || all_docs[name.to_sym]

      return nil if versions.nil? || versions.empty?

      # Sort by version and release, return the latest
      # Handle both hash and object formats
      versions.max_by do |v|
        if v.respond_to?(:version)
          [v.version.to_i, v.release.to_f]
        else
          [v['version'].to_i, v['release'].to_f]
        end
      end
    end

    # Fetch all controls for a specific severity
    # @param name [String] STIG name
    # @param version [String] Version number
    # @param release [String] Release number
    # @param severity [String] Severity level (low, medium, high)
    # @return [Array<Hash>] Controls matching the severity
    def fetch_controls_by_severity(name, version, release, severity)
      doc = @documents_api.get_document(name, version, release)

      doc.requirements.values.select { |req| req.severity&.downcase == severity.downcase }
    end

    # Get CCIs for a specific RMF control
    # @param control [String] RMF control ID (e.g., "AC-1")
    # @param revision [Integer] RMF revision (4 or 5)
    # @return [Array<String>] CCI IDs that map to this control
    def get_ccis_for_rmf_control(control, revision = 5)
      # Get all CCIs
      all_ccis = @cci_api.list_ccis

      # Filter CCIs that reference this control
      matching_ccis = []

      all_ccis.each_key do |cci_id|
        # Get detailed CCI info to check RMF mapping

        detailed = @cci_api.get_cci_details(cci_id)

        # Check if this CCI maps to our control
        if detailed.assessment_procedures&.any? do |ap|
          ap['control_identifier']&.upcase == control.upcase &&
          ap['nist_control_family'] == "NIST-800-53-R#{revision}"
        end
          matching_ccis << cci_id
        end
      rescue StandardError => e
        warn "Error fetching CCI #{cci_id}: #{e.message}"
      end

      matching_ccis
    end

    # Batch download multiple STIGs
    # @param stig_list [Array<Hash>] Array of hashes with :name, :version, :release keys
    # @param output_dir [String] Directory to save files
    # @param delay [Float] Delay between downloads
    # @yield [index, total, name] Progress callback
    def batch_download_stigs(stig_list, output_dir, delay: 1.0)
      require 'fileutils'
      require 'json'

      FileUtils.mkdir_p(output_dir)

      stig_list.each_with_index do |stig_info, index|
        name = stig_info[:name]
        version = stig_info[:version]
        release = stig_info[:release]

        yield(index + 1, stig_list.size, name) if block_given?

        begin
          # Fetch complete STIG
          complete_stig = fetch_complete_stig(name, version, release) do |curr, total, vuln|
            puts "  Fetching control #{curr}/#{total}: #{vuln}"
          end

          # Save to file
          filename = "#{name}_v#{version}r#{release}.json"
          filepath = File.join(output_dir, filename)

          File.write(filepath, JSON.pretty_generate(complete_stig))
          puts "Saved: #{filepath}"

          # Rate limiting between STIGs
          sleep delay if delay.positive? && index < stig_list.size - 1
        rescue StandardError => e
          warn "Failed to download #{name}: #{e.message}"
        end
      end
    end

    # Generate a compliance summary for a STIG
    # @param name [String] STIG name
    # @param version [String] Version number
    # @param release [String] Release number
    # @return [Hash] Summary with counts by severity
    def generate_compliance_summary(name, version, release)
      doc = @documents_api.get_document(name, version, release)

      summary = {
        total: doc.requirements.size,
        by_severity: {
          high: 0,
          medium: 0,
          low: 0
        }
      }

      doc.requirements.each_value do |req|
        severity = req.severity&.downcase&.to_sym
        summary[:by_severity][severity] += 1 if summary[:by_severity].key?(severity)
      end

      summary
    end
  end
end

# Example usage:
if __FILE__ == $PROGRAM_NAME
  client = CyberTrackrHelper::Client.new

  # List all STIGs
  stigs = client.list_stigs
  puts "Found #{stigs.size} STIGs"

  # Search for Juniper STIGs
  juniper_stigs = client.search_documents('juniper', type: :stig)
  puts "\nJuniper STIGs:"
  juniper_stigs.each_key do |name|
    latest = client.get_latest_version(name)
    puts "  #{name}: v#{latest['version']}r#{latest['release']}"
  end

  # Fetch a complete STIG with progress
  puts "\nFetching complete STIG..."
  complete = client.fetch_complete_stig('Juniper_SRX_Services_Gateway_ALG', '3', '3') do |curr, total, vuln|
    puts "Progress: #{curr}/#{total} - #{vuln}"
  end

  puts "Fetched #{complete[:requirements].size} complete controls"
end
