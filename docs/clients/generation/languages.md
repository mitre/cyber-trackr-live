# Language-Specific Generation Commands

Ready-to-use commands for generating API clients in your preferred language. Copy, paste, and customize as needed.

## 🌐 **Supported Languages**

### **✅ Production Ready**

These languages have been thoroughly tested and are recommended for production use.

#### **Ruby**
```bash
# Our reference implementation
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g ruby \
  --library=faraday \
  --additional-properties=gemName=cyber_trackr_live,gemVersion=1.0.0 \
  -o /local/ruby-client
```

#### **TypeScript/JavaScript**
```bash
# For web applications and Node.js
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g typescript-fetch \
  --additional-properties=npmName=cyber-trackr-live,npmVersion=1.0.0 \
  -o /local/typescript-client
```

#### **Python**
```bash
# For data science and automation
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g python \
  --additional-properties=packageName=cyber_trackr_live,packageVersion=1.0.0 \
  -o /local/python-client
```

#### **Go**
```bash
# For high-performance microservices
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g go \
  --additional-properties=packageName=cybertrackrlive,packageVersion=1.0.0 \
  -o /local/go-client
```

#### **Java**
```bash
# For enterprise applications
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g java \
  --library=okhttp-gson \
  --additional-properties=groupId=live.trackr.cyber,artifactId=cyber-trackr-client,apiPackage=live.trackr.cyber.api,modelPackage=live.trackr.cyber.model \
  -o /local/java-client
```

### **🔧 Community Supported**

These languages are supported by the community and work well, but may need additional customization.

#### **C#**
```bash
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g csharp \
  --additional-properties=packageName=CyberTrackrLive,packageVersion=1.0.0 \
  -o /local/csharp-client
```

#### **PHP**
```bash
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g php \
  --additional-properties=packageName=CyberTrackrLive,packageVersion=1.0.0 \
  -o /local/php-client
```

#### **Rust**
```bash
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml \
  -g rust \
  --additional-properties=packageName=cyber_trackr_live,packageVersion=1.0.0 \
  -o /local/rust-client
```

## 🔧 **Customization Tips**

### **Package Naming**
- **Ruby**: Use `gemName=your_gem_name,gemVersion=1.0.0`
- **TypeScript**: Use `npmName=your-package-name,npmVersion=1.0.0`
- **Python**: Use `packageName=your_package_name,packageVersion=1.0.0`
- **Go**: Use `packageName=yourpackagename,packageVersion=1.0.0`
- **Java**: Use `groupId=com.your.org,artifactId=your-client`

### **HTTP Libraries**
- **Ruby**: `--library=faraday` (recommended) or `--library=typhoeus`
- **Java**: `--library=okhttp-gson` (recommended) or `--library=retrofit2`
- **TypeScript**: `typescript-fetch` (recommended) or `typescript-axios`

## 📚 **Next Steps**

- **[Usage Examples](./usage.md)** - See how to use these generated clients
- **[Advanced Configuration](./advanced.md)** - Custom templates and automation
- **[Overview](./overview.md)** - Back to getting started guide
- **[Reference](./reference.md)** - Troubleshooting and best practices

## 🚀 **More Languages**

Don't see your language? OpenAPI Generator supports 50+ languages including:
- Swift, Kotlin, Scala, Clojure
- Dart, Elixir, Erlang, Haskell
- Perl, R, Shell, PowerShell

Check the [OpenAPI Generator documentation](https://openapi-generator.tech/docs/generators) for the complete list.