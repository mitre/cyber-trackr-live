# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module InspecXccdfMapper
  # Client for cyber.trackr.live API
  # Based on the OpenAPI specification in docs/cyber-trackr-openapi.yaml
  class CyberTrackrClient
    BASE_URL = 'https://cyber.trackr.live/api'
    DEFAULT_TIMEOUT = 30
    RATE_LIMIT_DELAY = 0.1 # 100ms between requests

    attr_reader :rate_limit_delay, :timeout

    def initialize(rate_limit_delay: RATE_LIMIT_DELAY, timeout: DEFAULT_TIMEOUT)
      @rate_limit_delay = rate_limit_delay
      @timeout = timeout
      @last_request_time = Time.now - rate_limit_delay
    end

    # Get API documentation
    def api_info
      get('/')
    end

    # List all STIGs and SRGs (mixed in API)
    # Returns hash with STIG/SRG names as keys, version arrays as values
    def list_all_documents
      get('/stig')
    end

    # List only STIGs (filters out SRGs)
    def list_stigs
      all_docs = list_all_documents
      all_docs.reject { |name, _| is_srg?(name) }
    end

    # List only SRGs (filters out STIGs)  
    def list_srgs
      all_docs = list_all_documents
      all_docs.select { |name, _| is_srg?(name) }
    end

    # Get STIG details with all requirements
    def get_stig(title, version, release)
      get("/stig/#{encode_path(title)}/#{version}/#{release}")
    end

    # Get detailed control information
    def get_control(title, version, release, vuln_id)
      get("/stig/#{encode_path(title)}/#{version}/#{release}/#{vuln_id}")
    end

    # List RMF controls
    def list_rmf_controls(revision = 5)
      get("/rmf/#{revision}")
    end

    # Get RMF control details
    def get_rmf_control(revision, control)
      get("/rmf/#{revision}/#{control}")
    end

    # List CCIs
    def list_ccis
      get('/cci')
    end

    # Get CCI details
    def get_cci(item)
      get("/cci/#{item}")
    end

    # Fetch complete STIG with all control details
    def fetch_complete_stig(title, version, release, &block)
      stig = get_stig(title, version, release)
      return nil unless stig && stig['requirements']

      total = stig['requirements'].size
      completed_requirements = {}

      stig['requirements'].each_with_index do |(vuln_id, summary), index|
        yield(index + 1, total, vuln_id) if block_given?
        
        begin
          control_details = get_control(title, version, release, vuln_id)
          completed_requirements[vuln_id] = summary.merge(control_details)
        rescue => e
          # Keep original summary if fetch fails
          completed_requirements[vuln_id] = summary.merge('_error' => e.message)
        end
      end

      stig.merge('requirements' => completed_requirements)
    end

    private

    def get(path)
      enforce_rate_limit
      
      uri = URI.join(BASE_URL, path)
      
      response = Net::HTTP.start(uri.host, uri.port, 
                                use_ssl: true, 
                                read_timeout: timeout,
                                open_timeout: timeout) do |http|
        request = Net::HTTP::Get.new(uri)
        request['Accept'] = 'application/json'
        request['User-Agent'] = 'InSpec-XCCDF-Mapper/1.0'
        http.request(request)
      end

      case response.code
      when '200'
        JSON.parse(response.body)
      when '404'
        raise NotFoundError, "Resource not found: #{path}"
      when '500'
        error = JSON.parse(response.body) rescue {}
        raise ServerError, error['detail'] || "Server error: #{response.code}"
      else
        raise ApiError, "HTTP #{response.code}: #{response.message}"
      end
    rescue Net::ReadTimeout, Net::OpenTimeout
      raise TimeoutError, "Request timed out after #{timeout} seconds"
    end

    def enforce_rate_limit
      elapsed = Time.now - @last_request_time
      sleep_time = rate_limit_delay - elapsed
      sleep(sleep_time) if sleep_time > 0
      @last_request_time = Time.now
    end

    def encode_path(component)
      # URL encode but keep forward slashes
      component.gsub(' ', '_').gsub('/', '_')
    end

    # Determine if a document name is an SRG vs STIG
    def is_srg?(document_name)
      srg_patterns = [
        /Security.*Requirements.*Guide/i,
        /\(SRG\)/,
        /_SRG$/,
        # Specific known SRG patterns
        /^Application_Layer_Gateway.*Security_Requirements_Guide/,
        /^Application_Server_Security_Requirements_Guide/,
        /^Database_Security_Requirements_Guide/,
        /^Network_Device_Management_Security_Requirements_Guide/,
        /^Operating_System_Security_Requirements_Guide/,
        /^AAA.*Security_Requirements_Guide/,
        /^Central_Log_Server_Security_Requirements_Guide/,
        /^DNS_Server_Security_Requirements_Guide/,
        /^Email_Services_Security_Requirements_Guide/,
        /^General_Purpose_Operating_System_Security_Requirements_Guide/,
        /^Multifunction_Device_or_Network_Function_Virtualization_Security_Requirements_Guide/,
        /^Network_Infrastructure_Security_Requirements_Guide/,
        /^Traditional_Security_Requirements_Guide/,
        /^VPN_Gateway_Security_Requirements_Guide/,
        /^Web_Server_Security_Requirements_Guide/
      ]
      
      srg_patterns.any? { |pattern| document_name.match?(pattern) }
    end

    # Classify a requirement as technology-generic (SRG) vs vendor-specific (STIG)
    def is_generic_requirement?(control_detail)
      # SRG requirements have SRG- group patterns and generic language
      group = control_detail['group']
      check_text = control_detail['check-text'] || ''
      fix_text = control_detail['fix-text'] || ''
      
      return true if group&.start_with?('SRG-')
      
      # Generic language patterns (no vendor-specific commands)
      generic_patterns = [
        /configure the \w+ to/i,
        /verify the \w+ is configured/i,
        /the \w+ must be configured/i
      ]
      
      vendor_specific_patterns = [
        /show configuration/i,
        /set \w+/i,
        /\$ \w+/,  # Shell commands
        />\s*\w+/,  # CLI prompts
        /\/etc\//,   # File paths
        /systemctl/,
        /grep/
      ]
      
      has_generic = generic_patterns.any? { |p| check_text.match?(p) || fix_text.match?(p) }
      has_vendor_specific = vendor_specific_patterns.any? { |p| check_text.match?(p) || fix_text.match?(p) }
      
      has_generic && !has_vendor_specific
    end

    # Custom error classes
    class ApiError < StandardError; end
    class NotFoundError < ApiError; end
    class ServerError < ApiError; end
    class TimeoutError < ApiError; end
  end
end