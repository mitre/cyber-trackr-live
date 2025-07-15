# Testing the Cyber Trackr API Tools

## Test Structure

We focus on testing what matters:

1. **Helper Methods** (`test/helper_test.rb`) - Unit tests for our convenience methods
2. **Integration Tests** (`test/integration/live_integration_test.rb`) - Optional tests against the real API

We DON'T test the generated client because:
- It's auto-generated from our validated OpenAPI spec
- The generator itself is well-tested
- We trust the generated code

## Running Tests

### Quick Test (Helper only, with mocks)
```bash
ruby test/helper_test.rb
```

### Full Test Suite
```bash
ruby test/run_tests.rb
```

### Skip Integration Tests
```bash
SKIP_INTEGRATION_TESTS=1 ruby test/run_tests.rb
```

## Test Dependencies

Add to your Gemfile:
```ruby
group :test do
  gem 'minitest'
  gem 'webmock'
end
```

## What We Test

### Helper Methods
- STIG/SRG detection logic
- Document filtering (separating STIGs from SRGs)
- Search functionality
- Latest version selection
- Complete STIG fetching with progress
- Compliance summary generation
- Control filtering by severity

### Integration (Optional)
- Real API connectivity
- Actual document counts
- Live data structure validation
- Real compliance summaries

## Writing New Tests

Use the test helper for common mocking:

```ruby
require_relative 'test_helper'

class MyTest < Minitest::Test
  include TestHelper
  
  def test_something
    # Use helper methods like:
    mock_documents_list
    mock_document('STIG_Name', '1', '1')
    mock_requirement('STIG_Name', '1', '1', 'V-123456')
  end
end
```