# RuboCop Custom Cop Solution for Content-Type Issue

## Overview
We successfully implemented a RuboCop custom cop to automatically fix the Content-Type header issue in the generated OpenAPI client. The cyber.trackr.live API incorrectly returns `text/html` for individual requirement endpoints even though the response body is valid JSON.

## Solution Components

### 1. Custom RuboCop Cop
**File**: `lib/rubocop/cop/cyber_trackr_api/content_type_fix.rb`

The cop:
- Detects the specific pattern in the `deserialize` method where Content-Type validation happens
- Adds a workaround that allows HTML content-type when the body starts with `{` or `[` (JSON)
- Uses AST pattern matching to find the exact location
- Applies the fix automatically with `--autocorrect`

### 2. RuboCop Configuration
**File**: `.rubocop_post_generate.yml`

```yaml
require:
  - ./lib/rubocop/cop/cyber_trackr_api/content_type_fix.rb

CyberTrackrApi/ContentTypeFix:
  Enabled: true
  Include:
    - 'generated-client/lib/cyber_trackr_client/api_client.rb'
```

### 3. Post-Generation Script
**File**: `scripts/post_generate_fix.rb`

Runs RuboCop with the custom cop after client generation to apply the fix.

### 4. Generation Script
**File**: `scripts/generate_client.sh`

Updated to automatically run post-generation fixes after generating the client.

## The Applied Fix

The cop transforms this code:
```ruby
fail "Content-Type is not supported: #{content_type}" unless json_mime?(content_type)
```

Into this:
```ruby
# Handle text/html responses that contain JSON (API bug)
# TODO: Remove this workaround when cyber.trackr.live fixes Content-Type headers
if content_type.include?('text/html') && body.strip.start_with?('{', '[')
  # Skip the normal content-type check - we know it's JSON despite wrong header
else
  fail "Content-Type is not supported: #{content_type}" unless json_mime?(content_type)
end
```

## How It Works

1. When `generate_client.sh` runs, it generates the OpenAPI client
2. The post-generation script runs RuboCop with our custom cop
3. The cop finds the Content-Type validation in `api_client.rb`
4. It applies the workaround automatically
5. The client is ready to use with the fix in place

## Testing

The fix has been tested and verified:
- ✅ Pattern matching works correctly
- ✅ Cop detects and fixes the target code
- ✅ Generated client handles HTML responses with JSON bodies
- ✅ No duplicate JSON parsing or other side effects

## Future Maintenance

When cyber.trackr.live fixes their Content-Type headers:
1. Remove the custom cop files
2. Remove the post-generation script call from `generate_client.sh`
3. Regenerate the client without the workaround

The fix is clearly marked with a TODO comment in the generated code for easy identification.