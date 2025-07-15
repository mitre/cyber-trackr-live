# OpenAPI Development Guide

This guide documents the development process for creating and maintaining the cyber.trackr.live OpenAPI specification.

## Development Approach

### 1. Discovery Phase

We started by exploring the API to understand its structure:

```bash
# Discover API root
curl -sL -H "Accept: application/json" "https://cyber.trackr.live/api/" | jq .

# Count resources
curl -sL "https://cyber.trackr.live/api/stig" | jq 'keys | length'  # 1032 STIGs/SRGs

# Explore specific endpoints
curl -sL "https://cyber.trackr.live/api/stig/Juniper_SRX_Services_Gateway_ALG/3/3" | jq 'keys'
```

### 2. Schema Development

We built schemas by examining actual API responses:

```yaml
# Example: Building RequirementDetail schema from API response
RequirementDetail:
  type: object
  required:
    - id
    - rule
    - severity
    - requirement-title
    - check-text
    - fix-text
  properties:
    id:
      type: string
      pattern: '^V-\d{6}$'
      example: "V-214518"
    # ... etc
```

### 3. Iterative Refinement

The spec was refined through multiple iterations:

1. **Initial draft** - Basic endpoints and schemas
2. **Add missing endpoints** - SCAP, RMF list endpoints
3. **Fix OpenAPI 3.1 syntax** - Nullable fields, example vs examples
4. **Document actual behavior** - 500 errors for invalid parameters

## OpenAPI 3.1.1 Specific Features

### Nullable Fields

OpenAPI 3.1 uses JSON Schema 2020-12 syntax:

```yaml
# WRONG - OpenAPI 3.0 style
mitigation-statement:
  type: ['string', 'null']

# CORRECT - OpenAPI 3.1 style
mitigation-statement:
  anyOf:
    - type: string
    - type: "null"
```

### Examples

For single values use `example`, for arrays use `example` (not `examples`):

```yaml
# Single value
severity:
  type: string
  example: "medium"

# Array value  
identifiers:
  type: array
  example: ["V-66003", "SV-80493", "CCI-000213"]
```

## Testing Philosophy

### Test-Driven Documentation

We use tests to drive documentation accuracy:

1. **Write test for expected behavior**
2. **Run against real API**
3. **Update spec to match reality**
4. **Verify with tests**

Example discovering 500 vs 404 behavior:

```ruby
# Expected behavior (failed)
assert_equal 404, response.status, "Invalid V-ID should return 404"

# Actual behavior (updated)
assert_equal 500, response.status, "Invalid V-ID should return 500"
```

### Ruby-First Testing

We chose Ruby-based testing tools over JavaScript alternatives:

- `openapi3_parser` - Ruby gem for OpenAPI validation
- `minitest` - Simple, effective test framework
- `faraday` - Flexible HTTP client

Benefits:
- No Node.js dependency
- Consistent with InSpec project
- Better integration with Ruby client

## Schema Design Patterns

### Shared Schemas

Common structures are defined once and referenced:

```yaml
# Document listing pattern used by STIG and SCAP
DocumentList:
  type: object
  additionalProperties:
    type: array
    items:
      $ref: '#/components/schemas/DocumentVersion'
```

### Consistent Patterns

Parameter patterns are defined consistently:

```yaml
# Used across all endpoints
'^V-\d{6}$'     # V-IDs
'^CCI-\d{6}$'   # CCI-IDs  
'^[A-Z]+-\d+$'  # RMF controls
```

## API Quirks and Workarounds

### Mixed STIG/SRG Endpoint

The `/stig` endpoint returns both STIGs and SRGs. We document this clearly:

```yaml
description: |
  Returns complete list of Security Technical Implementation Guides (STIGs) and 
  Security Requirements Guides (SRGs). **Note**: These are mixed in one endpoint.
  Use document name patterns to distinguish:
  - SRGs contain "Security_Requirements_Guide" or "(SRG)" in name
  - STIGs are vendor/product specific
```

### Error Response Inconsistency

Invalid parameters return 500 instead of 404. We document this in:
1. Endpoint responses
2. Test assertions
3. README notes

## Validation Strategy

### Three-Layer Validation

1. **Syntax** - Valid OpenAPI 3.1.1 structure
2. **Completeness** - All endpoints/schemas present
3. **Accuracy** - Matches real API behavior

### Continuous Validation

```bash
# Quick check after changes
ruby test/openapi_validation_test.rb

# Full validation before commits
./run_all_tests.sh
```

## Future Improvements

### Potential Enhancements

1. **Add more examples** - Real data for each schema
2. **Expand descriptions** - More detail on field meanings
3. **Add x-extensions** - Custom metadata for tooling
4. **Response time documentation** - Note slow endpoints

### Schema Evolution

As the API evolves:
1. Monitor for new endpoints
2. Check for schema changes
3. Update parameter patterns
4. Test error behaviors

## Tools and Resources

### Development Tools

- **VS Code** - YAML syntax highlighting
- **Swagger Editor** - Visual validation (use carefully with 3.1)
- **jq** - JSON exploration
- **curl** - API testing

### References

- [OpenAPI 3.1.1 Spec](https://spec.openapis.org/oas/v3.1.1)
- [JSON Schema 2020-12](https://json-schema.org/draft/2020-12/json-schema-core.html)
- [openapi3_parser docs](https://github.com/kevindew/openapi3_parser)

## Lessons Learned

1. **Test against real API early** - Assumptions often wrong
2. **Document actual behavior** - Even if non-ideal
3. **Use consistent patterns** - Makes spec maintainable
4. **Validate continuously** - Catch issues quickly
5. **Ruby tools are sufficient** - No need for Node.js ecosystem