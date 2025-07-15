# API Testing Guide

This guide documents the testing approach and lessons learned while validating the cyber.trackr.live OpenAPI specification.

## Testing Strategy

We use three levels of testing to ensure our OpenAPI specification is accurate:

1. **Syntax Validation** - Ensure the spec is valid OpenAPI 3.1.1
2. **Completeness Checks** - Verify all endpoints and schemas are documented
3. **Live Validation** - Test against the real API to ensure accuracy

## Key Lessons Learned

### 1. Faraday URL Construction

When using Faraday with a base URL that includes a path (like `/api`), be careful with leading slashes:

```ruby
# WRONG - This goes to https://cyber.trackr.live/ (ignores /api)
client = Faraday.new(url: 'https://cyber.trackr.live/api')
response = client.get('/')  # Leading slash overwrites base path!

# CORRECT - Use full path
client = Faraday.new(url: 'https://cyber.trackr.live')
response = client.get('/api')
```

### 2. Redirect Handling

The API redirects from `/api/` to `/api` (trailing slash removed). Faraday needs proper middleware setup:

```ruby
Faraday.new do |f|
  f.headers['Accept'] = 'application/json'
  f.response :json, content_type: /\bjson$/  # Parse JSON first
  f.response :follow_redirects              # Then handle redirects
end
```

**Important**: The order matters! Put JSON parsing before redirect following.

### 3. JSON Parsing After Redirects

When Faraday follows redirects, the JSON middleware might not automatically parse the response. Solution:

```ruby
def parse_response(response)
  response.body.is_a?(String) ? JSON.parse(response.body) : response.body
end
```

### 4. Error Response Patterns

The API has specific error behaviors:
- **404**: Invalid endpoints (e.g., `/api/invalid`)
- **500**: Invalid parameter formats (e.g., `V-INVALID`, `CCI-INVALID`)

This is documented in our tests:

```ruby
def test_parameter_validation
  # Invalid V-ID returns 500, not 404
  response = @client.get('/api/stig/.../V-INVALID')
  assert_equal 500, response.status
  
  # Invalid endpoint returns 404
  response = @client.get('/api/invalid')
  assert_equal 404, response.status
end
```

## Running Tests

### Quick Validation

```bash
# Just validate the OpenAPI spec syntax
ruby test/openapi_validation_test.rb
```

### Full Test Suite

```bash
# Run all tests including live API validation
ruby test/openapi_validation_test.rb && \
ruby test/spec_completeness_test.rb && \
ruby test/live_api_validation_test.rb
```

### Debugging API Issues

If tests fail, enable request logging:

```ruby
# In test/live_api_validation_test.rb, uncomment:
f.response :logger # Log requests for debugging
```

### Testing with curl

Always test endpoints with curl first to understand the actual behavior:

```bash
# Test JSON response
curl -s -H "Accept: application/json" "https://cyber.trackr.live/api" | jq .

# Check headers
curl -I -H "Accept: application/json" "https://cyber.trackr.live/api/"

# Test specific endpoint
curl -s "https://cyber.trackr.live/api/stig/Juniper_SRX_Services_Gateway_ALG/3/3" | jq .
```

## Test File Descriptions

### `openapi_validation_test.rb`
- Uses `openapi3_parser` gem for validation
- Checks OpenAPI 3.1.1 compliance
- Validates nullable syntax (`anyOf` with `type: "null"`)
- Ensures all schema references resolve

### `spec_completeness_test.rb`
- Verifies all required endpoints exist
- Checks schema completeness
- Validates parameter patterns are consistent
- Ensures examples match their patterns

### `live_api_validation_test.rb`
- Tests against real cyber.trackr.live API
- Validates response structures
- Samples actual data
- Verifies error handling

## Common Issues and Solutions

### Issue: Getting HTML instead of JSON

**Symptom**: `JSON::ParserError: unexpected character: '<!DOCTYPE'`

**Causes**:
1. Missing `Accept: application/json` header
2. Incorrect URL path construction
3. Not following redirects

**Solution**: Check all three items above.

### Issue: Parameter validation returns unexpected status

**Symptom**: Expected 404 but got 500

**Solution**: The API returns 500 for invalid parameter formats. Update tests and documentation to reflect actual behavior.

### Issue: Tests pass individually but fail together

**Symptom**: Warnings appear in wrong tests

**Solution**: Tests run in random order. Use clear test names in output:
```ruby
puts "\n[#{__method__}] Test output here"
```

## Best Practices

1. **Always test with curl first** - Understand actual API behavior
2. **Check both with and without trailing slashes** - APIs may redirect
3. **Test error cases** - Invalid parameters reveal API patterns
4. **Use proper assertions** - Don't just print, assert expected behavior
5. **Document actual behavior** - Even if it's not ideal (like 500 for invalid params)

## Continuous Validation

To ensure the spec stays accurate:

1. Run tests before any spec changes
2. Update tests when discovering new API behaviors
3. Document any quirks or unexpected behaviors
4. Keep example data up-to-date