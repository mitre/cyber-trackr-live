# Ruby Client Examples

Comprehensive real-world examples for the cyber.trackr.live Ruby client, covering everything from basic usage to advanced enterprise integration patterns.

## 🚀 **Getting Started**

### Basic Client Initialization

```ruby
require 'cyber_trackr_live'

# Initialize helper client (recommended)
helper = CyberTrackrHelper.new

# Initialize with rate limiting for production
helper = CyberTrackrHelper.new(
  delay: 0.1,     # 100ms between requests
  timeout: 30     # 30 second timeout
)

# Direct API client (advanced usage)
client = CyberTrackrClient::DefaultApi.new
```

## 📋 **Document Discovery**

### List Available Documents

```ruby
# Get all STIGs (excludes SRGs)
stigs = helper.list_stigs
puts "📋 Found #{stigs.count} STIGs available"

# Get all SRGs (Security Requirements Guides)  
srgs = helper.list_srgs
puts "📋 Found #{srgs.count} SRGs available"

# Get all documents (STIGs + SRGs)
all_docs = helper.list_all_documents
puts "📋 Total documents: #{all_docs.count}"
```

### Search and Filter Documents

```ruby
# Search by keyword in title
windows_docs = helper.search_documents('Windows')
windows_docs.each do |id, doc|
  puts "🪟 #{doc[:title]} (v#{doc[:version]})"
end

# Filter STIGs by technology
juniper_stigs = helper.list_stigs.select do |id, info|
  info[:title].downcase.include?('juniper')
end

puts "🔧 Found #{juniper_stigs.count} Juniper STIGs:"
juniper_stigs.each do |id, info|
  puts "  • #{info[:title]} (v#{info[:version]}.#{info[:release]})"
end
```

### Technology Stack Analysis

```ruby
# Analyze your technology stack
tech_stack = ['Windows', 'Linux', 'Apache', 'MySQL', 'Docker']

compliance_overview = {}
tech_stack.each do |tech|
  matching_stigs = helper.list_stigs.select do |id, info|
    info[:title].downcase.include?(tech.downcase)
  end
  
  compliance_overview[tech] = {
    stig_count: matching_stigs.count,
    stigs: matching_stigs
  }
end

puts "🏢 Technology Stack Compliance Overview:"
compliance_overview.each do |tech, data|
  puts "  #{tech}: #{data[:stig_count]} STIGs available"
end
```

## Working with STIGs

### Get STIG Information

```ruby
# Get basic STIG metadata
stig_info = client.get_document('U_MS_Windows_10_STIG')
puts "Title: #{stig_info[:title]}"
puts "Version: #{stig_info[:version]}"
puts "Released: #{stig_info[:released]}"
puts "Description: #{stig_info[:description]}"
```

### Fetch Complete STIG

```ruby
# Get STIG with all requirements
complete_stig = client.fetch_complete_stig('U_MS_Windows_10_STIG')

puts "STIG: #{complete_stig[:title]}"
puts "Requirements: #{complete_stig[:requirements].size}"

# Access requirements
complete_stig[:requirements].each do |v_id, requirement|
  puts "#{v_id}: #{requirement[:title]}"
  puts "  Severity: #{requirement[:severity]}"
  puts "  Check: #{requirement[:check][0..100]}..." if requirement[:check]
end
```

## Requirement Analysis

### Filter by Severity

```ruby
stig = client.fetch_complete_stig('U_MS_Windows_10_STIG')

# Group by severity
by_severity = stig[:requirements].group_by { |_, req| req[:severity] }

puts "High: #{by_severity['high']&.size || 0}"
puts "Medium: #{by_severity['medium']&.size || 0}"  
puts "Low: #{by_severity['low']&.size || 0}"
```

### Find Specific Requirements

```ruby
stig = client.fetch_complete_stig('U_MS_Windows_10_STIG')

# Find requirements containing specific keywords
password_reqs = stig[:requirements].select do |v_id, req|
  req[:title]&.downcase&.include?('password') ||
  req[:check]&.downcase&.include?('password')
end

puts "Found #{password_reqs.size} password-related requirements:"
password_reqs.each do |v_id, req|
  puts "  #{v_id}: #{req[:title]}"
end
```

## 🚨 **Error Handling & Reliability**

### Graceful Error Handling

```ruby
require 'cyber_trackr_live'

helper = CyberTrackrHelper.new

begin
  # Try to fetch non-existent STIG
  stig = helper.fetch_complete_stig('NONEXISTENT_STIG', '1', '1')
rescue CyberTrackrHelper::NotFoundError => e
  puts "❌ STIG not found: #{e.message}"
rescue CyberTrackrHelper::APIError => e
  puts "❌ API error: #{e.message}"
rescue Net::TimeoutError => e
  puts "⏰ Request timeout: #{e.message}"
rescue JSON::ParserError => e
  puts "📄 JSON parsing error: #{e.message}"
rescue StandardError => e
  puts "❌ Unexpected error: #{e.message}"
end
```

### Retry Logic

```ruby
def fetch_with_retry(client, stig_id, max_retries = 3)
  retries = 0
  
  begin
    client.fetch_complete_stig(stig_id)
  rescue CyberTrackrHelper::APIError => e
    retries += 1
    if retries <= max_retries
      puts "Retry #{retries}/#{max_retries} for #{stig_id}"
      sleep(1)
      retry
    else
      raise e
    end
  end
end
```

## Bulk Operations

### Fetch Multiple STIGs

```ruby
stig_ids = ['U_MS_Windows_10_STIG', 'U_MS_Windows_Server_2019_STIG']
results = {}

stig_ids.each do |stig_id|
  begin
    puts "Fetching #{stig_id}..."
    results[stig_id] = client.fetch_complete_stig(stig_id)
    puts "  Success: #{results[stig_id][:requirements].size} requirements"
  rescue => e
    puts "  Error: #{e.message}"
    results[stig_id] = nil
  end
end

# Analyze results
total_requirements = results.values.compact.sum { |stig| stig[:requirements].size }
puts "Total requirements across all STIGs: #{total_requirements}"
```

### Export to JSON

```ruby
require 'json'

# Fetch STIG and export
stig = client.fetch_complete_stig('U_MS_Windows_10_STIG')

# Clean filename
filename = stig[:title].gsub(/[^\w\s-]/, '').gsub(/\s+/, '_') + '.json'

File.write(filename, JSON.pretty_generate(stig))
puts "Exported to #{filename}"
```

## Advanced Usage

### Custom HTTP Configuration

```ruby
# Access underlying Faraday client for custom configuration
client = CyberTrackrHelper::Client.new

# The client uses Faraday internally - you can access it if needed
# (This is an advanced use case)
raw_response = client.instance_variable_get(:@client).get('/api/stig')
puts "Status: #{raw_response.status}"
```

### Rate Limiting Analysis

```ruby
# Monitor API calls with timing
start_time = Time.now
stigs = client.list_stigs
duration = Time.now - start_time

puts "Listed #{stigs.size} STIGs in #{duration.round(2)} seconds"
puts "Average: #{(duration / stigs.size).round(3)}s per STIG"
```

## Integration Examples

### With InSpec

```ruby
require 'cyber_trackr_helper'

# In an InSpec control
control 'stig-compliance-check' do
  title 'Verify STIG requirements are available'
  
  client = CyberTrackrHelper::Client.new
  
  describe 'Windows 10 STIG' do
    stig = client.get_document('U_MS_Windows_10_STIG')
    
    it 'should be available' do
      expect(stig).not_to be_nil
    end
    
    it 'should have requirements' do
      requirements = client.get_requirements('U_MS_Windows_10_STIG')
      expect(requirements.size).to be > 0
    end
  end
end
```

### Enterprise Compliance Dashboard

```ruby
# Enterprise-grade compliance monitoring service
class ComplianceDashboard
  def initialize
    @helper = CyberTrackrHelper.new(
      delay: 0.1,     # Rate limiting for production
      timeout: 30     # 30 second timeout
    )
  end
  
  def generate_compliance_report(technology_stack)
    report = {
      timestamp: Time.now,
      technologies: {},
      summary: {}
    }
    
    technology_stack.each do |tech|
      puts "📊 Analyzing #{tech} compliance..."
      
      # Find all STIGs for this technology
      matching_stigs = @helper.list_stigs.select do |id, info|
        info[:title].downcase.include?(tech.downcase)
      end
      
      # Analyze requirements for each STIG
      tech_summary = {
        stig_count: matching_stigs.count,
        total_requirements: 0,
        severity_breakdown: { 'high' => 0, 'medium' => 0, 'low' => 0 },
        recent_stigs: []
      }
      
      matching_stigs.first(3).each do |id, info|
        begin
          stig = @helper.fetch_complete_stig(id, info[:version], info[:release])
          
          tech_summary[:total_requirements] += stig[:requirements].count
          
          # Count by severity
          stig[:requirements].each do |_, req|
            severity = req[:severity]&.downcase || 'unknown'
            tech_summary[:severity_breakdown][severity] = 
              (tech_summary[:severity_breakdown][severity] || 0) + 1
          end
          
          tech_summary[:recent_stigs] << {
            title: stig[:title],
            version: stig[:version],
            release: stig[:release],
            requirement_count: stig[:requirements].count
          }
          
        rescue => e
          puts "⚠️  Error analyzing #{id}: #{e.message}"
        end
      end
      
      report[:technologies][tech] = tech_summary
    end
    
    # Generate summary
    report[:summary] = {
      total_stigs: report[:technologies].values.sum { |t| t[:stig_count] },
      total_requirements: report[:technologies].values.sum { |t| t[:total_requirements] },
      technologies_covered: report[:technologies].keys.count
    }
    
    report
  end
  
  def print_report(report)
    puts "🏢 Enterprise Compliance Report"
    puts "=" * 50
    puts "Generated: #{report[:timestamp]}"
    puts ""
    
    puts "📊 Summary:"
    puts "  Technologies: #{report[:summary][:technologies_covered]}"
    puts "  STIGs: #{report[:summary][:total_stigs]}"
    puts "  Requirements: #{report[:summary][:total_requirements]}"
    puts ""
    
    report[:technologies].each do |tech, data|
      puts "🔧 #{tech.upcase}:"
      puts "  STIGs available: #{data[:stig_count]}"
      puts "  Total requirements: #{data[:total_requirements]}"
      puts "  Severity breakdown:"
      puts "    High: #{data[:severity_breakdown]['high']}"
      puts "    Medium: #{data[:severity_breakdown]['medium']}"
      puts "    Low: #{data[:severity_breakdown]['low']}"
      puts ""
    end
  end
end

# Usage
dashboard = ComplianceDashboard.new
tech_stack = ['Windows', 'Linux', 'Apache', 'MySQL']
report = dashboard.generate_compliance_report(tech_stack)
dashboard.print_report(report)
```

### Rails Integration

```ruby
# In a Rails model or service
class StigService
  def initialize
    @helper = CyberTrackrHelper.new
  end
  
  def latest_windows_stigs
    @helper.list_stigs.select do |id, info|
      info[:title].downcase.include?('windows')
    end.sort_by { |_, info| info[:released] }.reverse.first(10)
  end
  
  def requirement_summary(stig_id, version, release)
    stig = @helper.fetch_complete_stig(stig_id, version, release)
    
    {
      title: stig[:title],
      total_requirements: stig[:requirements].count,
      by_severity: stig[:requirements].group_by { |_, req| req[:severity] }
                      .transform_values(&:count)
    }
  end
end
```