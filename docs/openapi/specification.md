# OpenAPI Specification Details

Technical details about our OpenAPI 3.1.1 specification for the cyber.trackr.live API.

## 📋 **Specification Overview**

Our OpenAPI specification is a comprehensive, production-ready definition of the cyber.trackr.live API that serves as the single source of truth for all client generation and documentation.

### **Key Statistics**
- **OpenAPI Version**: 3.1.1 (latest standard)
- **Endpoints**: 15+ fully documented endpoints
- **Data Coverage**: 1000+ STIGs, 300+ SRGs, 3000+ CCIs
- **Validation**: Professional-grade Spectral linting
- **Testing**: Two-tier validation approach

## 🔧 **API Endpoints**

### **Core Document Endpoints**
```yaml
# List all STIG and SRG documents
GET /api/stig

# Get specific document metadata
GET /api/stig/{title}/{version}/{release}

# Get document requirements
GET /api/stig/{title}/{version}/{release}/requirements
```

### **CCI (Control Correlation Identifier) Endpoints**
```yaml
# List all CCIs
GET /api/cci

# Get specific CCI details
GET /api/cci/{cci_id}

# Get CCI by control
GET /api/cci/control/{control_id}
```

### **RMF (Risk Management Framework) Endpoints**
```yaml
# List RMF controls
GET /api/rmf/controls

# Get specific control details
GET /api/rmf/controls/{control_id}
```

### **SCAP (Security Content Automation Protocol) Endpoints**
```yaml
# List SCAP documents
GET /api/scap

# Get specific SCAP document
GET /api/scap/{scap_id}
```

## 📊 **Data Schemas**

### **STIG Document Schema**
```yaml
StigDocument:
  type: object
  properties:
    id:
      type: string
      description: Document identifier
    title:
      type: string
      description: Full document title
    version:
      type: string
      description: Version number
    release:
      type: string
      description: Release number
    date:
      type: string
      format: date
      description: Release date
    requirements:
      type: array
      items:
        $ref: '#/components/schemas/Requirement'
```

### **Requirement Schema**
```yaml
Requirement:
  type: object
  properties:
    vuln_id:
      type: string
      description: Vulnerability ID (V-ID)
    title:
      type: string
      description: Requirement title
    description:
      type: string
      description: Detailed description
    severity:
      type: string
      enum: [high, medium, low]
      description: Severity level
    rule_id:
      type: string
      description: XCCDF rule ID (SV-ID)
    cci_refs:
      type: array
      items:
        type: string
      description: Referenced CCI IDs
```

### **CCI Schema**
```yaml
CCI:
  type: object
  properties:
    id:
      type: string
      description: CCI identifier (e.g., CCI-000001)
    definition:
      type: string
      description: CCI definition text
    controls:
      type: array
      items:
        type: string
      description: Associated RMF controls
    type:
      type: string
      description: CCI type
```

## 🧪 **Validation & Quality Assurance**

### **Spectral Validation Rules**
Our specification uses [Spectral](https://stoplight.io/open-source/spectral/) for professional-grade validation:

```yaml
# .spectral.yml
extends: ["@stoplight/spectral/rulesets/oas"]

rules:
  # Custom DISA-specific rules
  disa-endpoint-naming:
    description: "DISA endpoints should follow naming conventions"
    given: "$.paths[*]"
    then:
      function: pattern
      functionOptions:
        match: "^/api/(stig|cci|rmf|scap)"
        
  disa-response-examples:
    description: "All responses should include examples"
    given: "$.paths[*][*].responses[*]"
    then:
      - field: "content.application/json.examples"
        function: truthy
```

### **Validation Commands**
```bash
# Validate OpenAPI specification
npm run docs:validate

# Validate with custom DISA rules
spectral lint openapi/openapi.yaml --ruleset .spectral.yml

# Validate Mermaid diagrams
npm run docs:validate-mermaid
```

## 🔄 **Version Management**

### **Semantic Versioning**
We follow semantic versioning for the OpenAPI specification:
- **Major**: Breaking changes to API structure
- **Minor**: New endpoints or non-breaking enhancements
- **Patch**: Bug fixes and documentation updates

### **Version History**
- **v1.0.0**: Initial production release
- **v1.1.0**: Added RMF controls endpoints
- **v1.2.0**: Enhanced SCAP document support
- **v1.2.1**: Fixed response schema validation

## 🛠️ **Development Workflow**

### **Specification-First Development**
1. **Design in OpenAPI** - Define endpoints and schemas first
2. **Validate with Spectral** - Ensure quality and consistency
3. **Generate clients** - Create Ruby, TypeScript, Python, Go clients
4. **Test against live API** - Validate specification accuracy
5. **Deploy documentation** - Update interactive docs

### **Modification Process**
```bash
# 1. Edit the specification
vim openapi/openapi.yaml

# 2. Validate changes
npm run docs:validate

# 3. Regenerate Ruby client
make generate

# 4. Run tests
bundle exec rake test

# 5. Update documentation
npm run docs:build
```

## 🌐 **Client Generation**

### **Supported Languages**
Our OpenAPI specification supports client generation for:

- ✅ **Ruby** - Production-ready official client
- 🔧 **TypeScript** - Generate with OpenAPI Generator
- 🔧 **Python** - Generate with OpenAPI Generator
- 🔧 **Go** - Generate with OpenAPI Generator
- 🔧 **Java** - Generate with OpenAPI Generator
- 🔧 **C#** - Generate with OpenAPI Generator

### **Generation Examples**
```bash
# Generate TypeScript client
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g typescript-fetch \
  -o ./generated/typescript \
  --additional-properties=npmName=cyber-trackr-live

# Generate Python client
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g python \
  -o ./generated/python \
  --additional-properties=packageName=cyber_trackr_live
```

## 📚 **Documentation Generation**

### **Interactive Documentation**
Our specification generates interactive documentation using:
- **VitePress** - Static site generator
- **Scalar** - OpenAPI documentation renderer
- **Mermaid** - Diagram generation
- **CORS Proxy** - GitHub Pages compatibility

### **Documentation Features**
- 🔧 **Try-it-out functionality** - Test API calls directly
- 📱 **Mobile-responsive** - Works on all devices
- 🌐 **GitHub Pages deployment** - Static hosting
- 🔍 **Full-text search** - Find endpoints and schemas quickly

## 🤝 **API Partnership Integration**

### **cyber.trackr.live Compatibility**
Our specification is designed to accurately represent the cyber.trackr.live API:

```yaml
# Base URL configuration
servers:
  - url: https://cyber.trackr.live
    description: Production API server
  - url: https://staging.cyber.trackr.live
    description: Staging API server (if available)
```

### **Authentication**
```yaml
# No authentication required for public endpoints
security: []

# Future: If authentication is added
components:
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: X-API-Key
```

## 🔮 **Future Enhancements**

### **Planned Improvements**
- 🔄 **Webhook support** - Real-time notifications
- 📊 **GraphQL integration** - Alternative query interface
- 🧪 **Mock server generation** - Development and testing
- 🔐 **Enhanced security schemas** - If authentication is added
- 📋 **OpenAPI 3.1.x updates** - Stay current with specification

### **Community Contributions**
We welcome contributions to improve the specification:
- 🐛 **Bug reports** - Specification inaccuracies
- 💡 **Feature requests** - New endpoint suggestions
- 📚 **Documentation improvements** - Clearer descriptions
- 🧪 **Testing enhancements** - Better validation rules

## 📖 **Learn More**

- **[OpenAPI Benefits](./benefits.md)** - Why we chose OpenAPI-first development
- **[Validation & Quality](./validation.md)** - Our professional validation approach
- **[Client Generation](/clients/generation/overview)** - How to generate your own clients
- **[Development Guide](/development/openapi-development.md)** - Contributing to the specification

---

**The OpenAPI 3.1.1 specification is the technical foundation that makes everything else possible.** Explore how it powers our entire ecosystem!