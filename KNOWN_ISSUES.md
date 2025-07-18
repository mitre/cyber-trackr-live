---
title: Known Issues and Solutions
description: Documented issues, workarounds, and solutions for the cyber-trackr-live project
layout: doc
sidebar: true
---

# Known Issues and Solutions

## ✅ RESOLVED: text/html Content-Type with JSON Body

**Status**: **FIXED** as of July 2024 - The API maintainer has fixed the server configuration.

**Previous Problem**: Some endpoints returned `Content-Type: text/html` for JSON responses.

**Resolution**: The API now correctly returns `Content-Type: application/json` for all JSON endpoints. Our custom workarounds and patches have been removed.

## Issue 1: Optional vs Required Fields

**Problem**: The generated client adds nil initialization for optional fields that don't need it.

**Solution**: This is actually correct behavior. The OpenAPI spec properly defines:
- Required fields: `id`, `rule`, `severity`, `requirement-title`, `check-text`, `fix-text`
- Optional fields: All others
- Nullable fields: Only `mitigation-statement`

The generator correctly handles this. No action needed.

## Recommended Production Approach

1. Use the stock OpenAPI-generated client - all server-side issues have been resolved
2. Document any remaining edge cases in the README
3. Add integration tests that verify the client works correctly with the live API
4. Consider creating a higher-level client wrapper for enhanced functionality (optional)

The stock OpenAPI approach is now viable because:
- The API server has been fixed to return proper headers
- No custom workarounds are needed
- Standard OpenAPI tooling works correctly
- The client is maintainable and follows OpenAPI best practices

## Testing Recommendations

1. Add tests that verify the client works correctly with the live API
2. Test both successful and error cases
3. Verify proper handling of the remaining known issues (date formats, error codes)
4. Include integration tests against the live API (with appropriate guards)