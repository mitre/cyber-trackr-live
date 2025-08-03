# Getting Started with the API

## Base URL

All API requests use this base URL:
```
https://cyber.trackr.live/api
```

## Authentication

**No authentication required!** The cyber.trackr.live API is publicly accessible. No API keys, tokens, or authentication headers needed.

## Understanding the Data Model

Before making API calls, it helps to understand the compliance hierarchy:

```
NIST RMF Controls (high-level policy framework)
    ↓ (decomposed into atomic, testable statements)
CCIs (Control Correlation Identifiers - bridge policy to implementation)
    ↓ (grouped by technology class into generic requirements)
SRGs (Security Requirements Guides - technology class "what" to do)
    ↓ (implemented as vendor-specific "how" to do it)
STIGs (Security Technical Implementation Guides - vendor/product specific)
    ↓ (automated versions for scanning tools)
SCAP (Security Content Automation Protocol documents)
```

### Key Terms
- **STIG**: Security Technical Implementation Guide - vendor-specific security checklist (e.g., Windows 10 STIG)
- **SRG**: Security Requirements Guide - generic technology requirements (e.g., Operating System SRG)
- **CCI**: Control Correlation Identifier - bridges policy to implementation
- **RMF Control**: Risk Management Framework control from NIST (e.g., AC-1 for Access Control Policy)

### Common ID Formats
- **V-IDs**: `V-214518` - Requirement identifiers
- **SV-IDs**: `SV-214518r997541_rule` - XCCDF rule IDs with revision tracking
- **CCI-IDs**: `CCI-000213` - Control Correlation Identifiers
- **Control IDs**: `AC-1`, `AU-2` - RMF control identifiers

## Your First API Call

Now let's fetch a list of available STIGs:

```bash
curl https://cyber.trackr.live/api/stig
```

This returns a JSON array of all available STIG and SRG documents:

```json
[
  {
    "title": "MS_Windows_10_STIG",
    "version": "2",
    "release": "8",
    "release_date": "2024-01-25",
    "filename": "U_MS_Windows_10_V2R8_STIG.zip"
  },
  // ... more STIGs
]
```

## Common Use Cases

### 1. Browse Available STIGs/SRGs
```bash
# List all documents
curl "https://cyber.trackr.live/api/stig"

# Response includes both STIGs (vendor-specific) and SRGs (generic)
```

### 2. Get Document Details
```bash
# Get Windows 10 STIG summary with all requirements
curl "https://cyber.trackr.live/api/stig/MS_Windows_10_STIG/2/8"

# Returns document metadata and list of all requirements (V-IDs)
```

### 3. Get Specific Requirement
```bash
# Get details for requirement V-220706
curl "https://cyber.trackr.live/api/stig/MS_Windows_10_STIG/2/8/V-220706"

# Returns full requirement with check text, fix text, and severity
```

### 4. Work with RMF Controls
```bash
# List all RMF Rev 5 controls
curl "https://cyber.trackr.live/api/rmf/5"

# Get specific control details (AC-1)
curl "https://cyber.trackr.live/api/rmf/5/AC-1"
```

### 5. Look Up CCIs
```bash
# Get CCI details and mappings
curl "https://cyber.trackr.live/api/cci/CCI-000213"
```

## Response Format

All responses are JSON. The actual format varies by endpoint, but common patterns include:

### List Endpoints
```json
[
  { /* item 1 */ },
  { /* item 2 */ },
  // ...
]
```

### Detail Endpoints
```json
{
  "title": "...",
  "version": "...",
  "requirements": [...],
  // other fields
}
```

### Error Responses
```json
{
  "error": {
    "message": "STIG not found",
    "status": 500  // Note: Currently returns 500 for not found (not 404)
  }
}
```

## Code Examples

### JavaScript (fetch)
```javascript
// Get all STIGs
const response = await fetch('https://cyber.trackr.live/api/stig');
const stigs = await response.json();

// Get specific requirement
const reqResponse = await fetch('https://cyber.trackr.live/api/stig/MS_Windows_10_STIG/2/8/V-220706');
const requirement = await reqResponse.json();
```

### Python (requests)
```python
import requests

# Get all STIGs
response = requests.get('https://cyber.trackr.live/api/stig')
stigs = response.json()

# Get specific requirement
req_response = requests.get('https://cyber.trackr.live/api/stig/MS_Windows_10_STIG/2/8/V-220706')
requirement = req_response.json()
```

### PowerShell
```powershell
# Get all STIGs
$stigs = Invoke-RestMethod -Uri "https://cyber.trackr.live/api/stig"

# Get specific requirement
$requirement = Invoke-RestMethod -Uri "https://cyber.trackr.live/api/stig/MS_Windows_10_STIG/2/8/V-220706"
```

## Best Practices

### Rate Limiting
While there are no enforced rate limits, please be respectful:
- Add delays between bulk requests (100ms recommended)
- Cache responses when possible
- Avoid downloading all STIGs simultaneously

### Handling Large Responses
Some STIG documents have hundreds of requirements:
- Implement pagination in your application
- Cache responses locally
- Use specific requirement endpoints instead of fetching entire documents

### Error Handling
- Check for HTTP status codes
- Handle 500 errors (currently returned for "not found")
- Implement retry logic for network failures

## Common Issues

### CORS Errors
The API supports CORS, but if you encounter issues:
- Make requests from server-side code instead of browser
- Use our [Ruby client](../clients/ruby/index.md) which handles this

### 500 Errors Instead of 404
Currently, invalid parameters return HTTP 500 instead of 404. If you get unexpected 500 errors:
- Verify your STIG title, version, and release are correct
- Check that V-IDs exist in the document
- Ensure control IDs use correct format (e.g., "AC-1" not "ac-1")

## Next Steps

- **[Explore All Endpoints](./index.md)** - Complete API reference
- **[Use the Ruby Client](../clients/ruby/index.md)** - For advanced workflows and helper methods
- **[Generate a Client](../clients/generation/overview.md)** - Create a client for your language
- **[Interactive Documentation](./index.md#interactive-documentation)** - Try requests in your browser