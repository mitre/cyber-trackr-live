---
aside: true
outline: [1, 3]
title: API Operations
---

# API Operations

The cyber.trackr.live API provides comprehensive access to cybersecurity compliance data including DISA STIGs, SRGs, RMF controls, CCIs, and SCAP documents. All endpoints are publicly accessible with no authentication required.

## Quick Start

### Common Workflows

1. **List Available STIGs**
   ```http
   GET /stig
   ```

2. **Get STIG Summary**
   ```http
   GET /stig/{title}/{version}/{release}
   ```

3. **Get Specific Requirement**
   ```http
   GET /stig/{title}/{version}/{release}/{vuln_id}
   ```

4. **Search RMF Controls**
   ```http
   GET /rmf/5
   GET /rmf/5/{control_id}
   ```

## Endpoint Categories

### 📋 **STIG & SRG Documents**
- **List Documents**: Get all available STIGs and SRGs
- **Document Summary**: Get document metadata and requirement list
- **Requirement Details**: Get full requirement specification with check/fix text

### 🔒 **RMF Controls**  
- **RMF Rev 4 & 5**: Access NIST RMF control families and individual controls
- **Control Details**: Full control text, implementation guidance, and relationships

### 🎯 **CCI References**
- **CCI List**: Browse Common Control Identifiers
- **CCI Details**: Get detailed CCI information and RMF mappings

### 📊 **SCAP Content**
- **SCAP Documents**: Security Content Automation Protocol documents
- **SCAP Requirements**: Individual SCAP requirement details

## Rate Limits & Performance

- **No Authentication Required**: All endpoints are publicly accessible
- **Rate Limits**: Please be respectful with request frequency
- **Response Format**: All responses are JSON
- **CORS Enabled**: Safe for browser-based applications

## Interactive Documentation

The interactive API documentation below allows you to:
- ✅ **Try requests directly** from your browser
- ✅ **See real response data** from the live API  
- ✅ **Explore all endpoints** with full parameter details
- ✅ **Copy working code examples** in multiple languages

<OASpec />