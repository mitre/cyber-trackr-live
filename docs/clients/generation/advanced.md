# Advanced Client Generation

Take your client generation to the next level with custom configurations, templates, and automated workflows.

## Custom Generator Options

```bash
# List available generators
openapi-generator-cli list

# Get help for specific generator
openapi-generator-cli config-help -g python

# Generate with custom configuration
openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g python \
  -c custom-config.json \
  -o ./python-client
```

## Configuration Files

Create a `config.json` file for consistent generation:

```json
{
  "packageName": "cyber_trackr_live",
  "packageVersion": "1.0.0",
  "packageCompany": "MITRE Corporation",
  "packageAuthors": "MITRE Corporation",
  "packageCopyright": "Copyright 2025 MITRE Corporation",
  "packageDescription": "Python client for cyber.trackr.live API - DISA cybersecurity data",
  "packageUrl": "https://github.com/mitre/cyber-trackr-live",
  "projectName": "cyber-trackr-live",
  "clientPackage": "cyber_trackr_live",
  "packageKeywords": ["cybersecurity", "compliance", "stig", "disa", "api"]
}
```

## Template Customization

```bash
# Download templates for customization
openapi-generator-cli author template -g python -o ./python-templates

# Generate with custom templates
openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g python \
  -t ./python-templates \
  -o ./python-client
```

## Generation Workflow

### Development Workflow

```mermaid
graph LR
    A[OpenAPI Spec Update] --> B[Validate Specification]
    B --> C[Generate Clients]
    C --> D[Test Generated Clients]
    D --> E[Update Client Versions]
    E --> F[Publish/Distribute]
    
    style A fill:#007bff,stroke:#0056b3,stroke-width:2px,color:#ffffff
    style B fill:#fd7e14,stroke:#e55100,stroke-width:2px,color:#000000
    style C fill:#fd7e14,stroke:#e55100,stroke-width:2px,color:#000000
    style D fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#ffffff
    style F fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#ffffff
```

### Automated Generation Script

```bash
#!/bin/bash
# generate-all-clients.sh

set -e

SPEC_URL="https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml"
VERSION="1.0.0"

echo "🔄 Generating all clients from OpenAPI specification..."

# Ruby (Reference Implementation)
echo "📦 Generating Ruby client..."
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i $SPEC_URL -g ruby --library=faraday \
  --additional-properties=gemName=cyber_trackr_live,gemVersion=$VERSION \
  -o /local/clients/ruby

# TypeScript
echo "📦 Generating TypeScript client..."
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i $SPEC_URL -g typescript-fetch \
  --additional-properties=npmName=cyber-trackr-live,npmVersion=$VERSION \
  -o /local/clients/typescript

# Python
echo "📦 Generating Python client..."
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i $SPEC_URL -g python \
  --additional-properties=packageName=cyber_trackr_live,packageVersion=$VERSION \
  -o /local/clients/python

# Go
echo "📦 Generating Go client..."
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i $SPEC_URL -g go \
  --additional-properties=packageName=cybertrackrlive,packageVersion=$VERSION \
  -o /local/clients/go

echo "✅ All clients generated successfully!"
```

## Enterprise Features

### Version Synchronization

Keep all your clients in sync with your OpenAPI specification:

```bash
# Extract version from OpenAPI spec
API_VERSION=$(grep "version:" openapi/openapi.yaml | sed 's/.*: //' | tr -d '"')

# Use extracted version in generation
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i openapi/openapi.yaml \
  -g ruby \
  --additional-properties=gemVersion=$API_VERSION \
  -o /local/ruby-client
```

### CI/CD Integration

Add client generation to your GitHub Actions workflow:

```yaml
- name: Generate Ruby Client
  run: |
    docker run --rm -v "${PWD}:/workspace" openapitools/openapi-generator-cli generate \
      -i /workspace/openapi/openapi.yaml \
      -g ruby --library=faraday \
      --additional-properties=gemName=cyber_trackr_live \
      -o /workspace/clients/ruby
```

## 📚 **Next Steps**

- **[Usage Examples](./usage.md)** - See these advanced configurations in action
- **[Reference Guide](./reference.md)** - Troubleshooting and complete documentation
- **[Language Commands](./languages.md)** - Back to basic generation commands
- **[Overview](./overview.md)** - Start from the beginning

## 🔧 **Custom Templates**

Want to create your own templates? Check out:
- [OpenAPI Generator Template Guide](https://openapi-generator.tech/docs/templating)
- [Mustache Template Language](https://mustache.github.io/)
- [Community Templates](https://github.com/OpenAPITools/openapi-generator/tree/master/modules/openapi-generator/src/main/resources)