---
layout: home

hero:
  name: OpenAPI 3.1.1 Specification
  text: cyber.trackr.live API
  tagline: OpenAPI specification driving a complete client ecosystem for cybersecurity compliance data
  image:
    src: /openapi-logo.svg
    alt: OpenAPI Specification Logo
  actions:
    - theme: brand
      text: Start Using the API
      link: /api-reference/getting-started
    - theme: alt
      text: Use Ruby Client
      link: /clients/ruby/
    - theme: alt
      text: Generate a Client
      link: /clients/generation/overview

features:
  - icon: 📋
    title: OpenAPI 3.1.1 Specification
    details: Production-ready specification with 15+ endpoints covering 1000+ DISA STIGs, 300+ SRGs, and 3000+ CCIs. Complete validation and standards compliance.
    
  - icon: 💎
    title: Client Ecosystem
    details: Ruby client (production-ready) with TypeScript, Python, and Go clients planned. All generated from the same OpenAPI specification.
    
  - icon: 📚
    title: Interactive Documentation
    details: Try-it-out functionality that works on GitHub Pages through our CORS proxy solution. Always up-to-date with the specification.
    
  - icon: 🤝
    title: API Integration
    details: Comprehensive OpenAPI specification and client ecosystem for the cyber.trackr.live API service. [Learn more about our approach](/project/collaboration).
    
  - icon: 🔧
    title: OpenAPI-First Development
    details: Two-tier testing, specification-driven development, and cross-platform patterns applicable to any OpenAPI project.
    
  - icon: 🌐
    title: Cybersecurity Data Access
    details: No authentication required - immediate access to comprehensive DISA compliance data and 87 SCAP documents.
---

## OpenAPI-First Architecture

Our OpenAPI 3.1.1 specification is the foundation for accessing [cyber.trackr.live](https://cyber.trackr.live) API data and drives the entire client ecosystem. [Learn more about our approach](/project/collaboration).

```mermaid
graph LR
    A["cyber.trackr.live API Service"] --> B["OpenAPI 3.1.1 Specification"]
    B --> C["Client Ecosystem"]
    B --> D["Interactive Documentation"]
    
    style A fill:#dc3545,stroke:#bd2130,stroke-width:2px,color:#ffffff
    style B fill:#007bff,stroke:#0056b3,stroke-width:3px,color:#ffffff
    style C fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#ffffff
    style D fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#ffffff
```

## Getting Started

Choose your path based on what you want to do:

```mermaid
graph TD
    A["What do you want to do?"] --> B["Use the API Directly"]
    A --> C["Use Ruby Gem"]
    A --> D["Generate Another Client"]
    A --> E["Contribute"]
    
    B --> F["API Getting Started Guide"]
    C --> G["Ruby Client Guide"]
    D --> H["Client Generation Guide"]
    E --> I["Development Guide"]
    
    style A fill:#007bff,stroke:#0056b3,stroke-width:2px,color:#ffffff
    style F fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#ffffff
    style G fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#ffffff
    style H fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#ffffff
    style I fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#ffffff
```

### Choose Your Path

#### 🌐 **I want to use the API directly**
→ **[API Getting Started Guide](/api-reference/getting-started)** - Make your first API call in 30 seconds with curl, JavaScript, Python, or PowerShell examples.

#### 💎 **I want to use the Ruby gem**
→ **[Ruby Client Guide](/clients/ruby/)** - Install the gem and use helper methods for STIG workflows. Production-ready with extensive examples.

#### 🔧 **I want to generate a client in another language**
→ **[Client Generation Guide](/clients/generation/overview)** - Generate TypeScript, Python, Go, Java, or 50+ other language clients from our OpenAPI spec.

#### 🤝 **I want to contribute or understand the architecture**
→ **[Development Guide](/development/)** - Learn about our OpenAPI-first approach, testing strategy, and how to contribute.

## Why OpenAPI-First Matters

Our specification-driven approach provides:

- **Single source of truth** - All clients and documentation generated from the OpenAPI spec
- **Consistent implementations** - Same behavior across Ruby, TypeScript, Python, Go clients
- **Always up-to-date documentation** - Interactive docs generated from the specification
- **Professional validation** - Spectral linting ensures specification quality

[Learn more about OpenAPI-first development](/openapi/benefits) and how it solves common API challenges.

## Quick Access

### For Users
- **[API Getting Started](/api-reference/getting-started)** - Your first API call
- **[Ruby Client](/clients/ruby/)** - Production-ready gem with helpers
- **[Generate Clients](/clients/generation/overview)** - Create clients for any language
- **[Interactive API Docs](/api-reference/)** - Try endpoints in your browser

### For Contributors
- **[Development Guide](/development/)** - Architecture and testing approaches
- **[OpenAPI Specification](/openapi/)** - Core specification details
- **[Project Information](/project/)** - Contributing, security, and governance

## Community & Support

- 📚 **Documentation**: Comprehensive guides throughout this site
- 🐛 **Issues**: [GitHub Issues](https://github.com/mitre/cyber-trackr-live/issues) for bugs and features
- 💬 **Discussions**: [GitHub Discussions](https://github.com/mitre/cyber-trackr-live/discussions) for questions
- 🤝 **Project Details**: [Learn about our approach](/project/collaboration) and MITRE's role

---

**The OpenAPI 3.1.1 specification is the foundation that drives everything else.** [Explore the specification](/openapi/) to understand how it powers the entire ecosystem.