# Client Generation Reference

Complete reference guide for troubleshooting, testing, and maintaining your generated API clients.

## 🧪 **Testing Generated Clients**

### **Basic Functionality Test**

```bash
# Test script for any generated client
#!/bin/bash
echo "🧪 Testing generated client..."

# Test 1: Client can be imported/required
echo "✅ Testing client import..."

# Test 2: Client can connect to API
echo "✅ Testing API connection..."

# Test 3: Client can fetch data
echo "✅ Testing data fetching..."

# Test 4: Client handles errors gracefully
echo "✅ Testing error handling..."

echo "✅ All tests passed!"
```

### **Integration Testing**

```yaml
# GitHub Actions workflow for client testing
name: Test Generated Clients
on: [push, pull_request]

jobs:
  test-clients:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        language: [ruby, python, typescript, go]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Generate ${{ matrix.language }} client
        run: |
          docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
            -i /local/openapi/openapi.yaml \
            -g ${{ matrix.language }} \
            -o /local/test-client
      
      - name: Test ${{ matrix.language }} client
        run: |
          cd test-client
          # Language-specific test commands
          ./test-client.sh
```

## 🔄 **Version Management**

### **Version Synchronization**

All generated clients follow the same versioning as the OpenAPI specification:

```bash
# Update all clients to new version
VERSION="1.1.0"

# Update specification version
sed -i "s/version: .*/version: $VERSION/" openapi/openapi.yaml

# Regenerate all clients with new version
./scripts/generate-all-clients.sh $VERSION
```

### **Client Release Process**

1. **Update OpenAPI specification** version
2. **Validate specification** with Spectral
3. **Generate all clients** with new version
4. **Test generated clients** against live API
5. **Update documentation** with new features
6. **Tag and release** clients

## 📊 **Generator Comparison**

| Language | Generator | Library | Type Safety | Async Support | Community |
|----------|-----------|---------|-------------|---------------|-----------|
| Ruby | ruby | faraday | ⭐⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ |
| TypeScript | typescript-fetch | fetch | ⭐⭐⭐⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ |
| Python | python | requests | ⭐⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ |
| Go | go | net/http | ⭐⭐⭐⭐⭐ | ✅ | ⭐⭐⭐⭐ |
| Java | java | okhttp-gson | ⭐⭐⭐⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ |

## 🔧 **Troubleshooting**

### **Common Issues**

**Issue**: Generator not found
```bash
# Solution: Update generator list
openapi-generator-cli list | grep python
```

**Issue**: Invalid specification
```bash
# Solution: Validate specification first
spectral lint openapi/openapi.yaml
```

**Issue**: Generated client compilation errors
```bash
# Solution: Check generator version compatibility
openapi-generator-cli version
```

**Issue**: Docker permission denied
```bash
# Solution: Fix Docker permissions
sudo chmod 666 /var/run/docker.sock
# Or run with proper user permissions
docker run --rm -v "${PWD}:/local" --user $(id -u):$(id -g) openapitools/openapi-generator-cli
```

**Issue**: Client imports fail
```bash
# Solution: Check package structure and dependencies
ls -la generated-client/
# Install required dependencies for your language
```

### **Debug Mode**

```bash
# Enable debug output
openapi-generator-cli generate \
  -i openapi/openapi.yaml \
  -g python \
  --enable-post-process-file \
  --global-property=debugModels,debugOperations \
  -o ./debug-client
```

### **Verbose Output**

```bash
# Get detailed generation information
openapi-generator-cli generate \
  -i openapi/openapi.yaml \
  -g ruby \
  --verbose \
  -o ./debug-client
```

## 🌟 **Best Practices**

### **Generator Selection**

- ✅ **Use stable generators** - Prefer generators marked as stable
- ✅ **Test before production** - Always test generated clients
- ✅ **Version consistency** - Keep all clients on same spec version
- ✅ **Documentation** - Generate documentation with clients
- ✅ **Error handling** - Implement proper error handling

### **Customization**

- 🎯 **Custom templates** - Modify templates for specific needs
- 🎯 **Configuration files** - Use JSON config for consistency
- 🎯 **Post-processing** - Add custom logic after generation
- 🎯 **Package metadata** - Include proper package information

### **Development Workflow**

- 🔄 **Automate generation** - Use scripts for consistent results
- 🔄 **Version control** - Don't commit generated files
- 🔄 **CI/CD integration** - Generate clients in your pipeline
- 🔄 **Testing pipeline** - Validate generated clients automatically

### **Production Considerations**

- 🚀 **Performance** - Choose appropriate HTTP libraries
- 🚀 **Security** - Validate all inputs and handle secrets properly
- 🚀 **Monitoring** - Add logging and metrics to generated clients
- 🚀 **Documentation** - Maintain clear usage examples

## 📚 **Resources**

### **Documentation**
- **[OpenAPI Generator Documentation](https://openapi-generator.tech/docs/)**
- **[Generator List](https://openapi-generator.tech/docs/generators)**
- **[Configuration Options](https://openapi-generator.tech/docs/configuration)**
- **[Template Guide](https://openapi-generator.tech/docs/templating)**

### **Community**
- **[GitHub Repository](https://github.com/OpenAPITools/openapi-generator)**
- **[Stack Overflow](https://stackoverflow.com/questions/tagged/openapi-generator)**
- **[Discord Community](https://discord.gg/openapi-generator)**
- **[OpenAPI Slack](https://join.slack.com/t/openapi/shared_invite/zt-12jmnxzfx-OLIgbQSxKQzrLAQ~1hHNRQ)**

### **Related Tools**
- **[Spectral](https://stoplight.io/open-source/spectral)** - OpenAPI linting
- **[Swagger Editor](https://editor.swagger.io/)** - Online specification editor
- **[Insomnia](https://insomnia.rest/)** - API testing with OpenAPI import
- **[Postman](https://www.postman.com/)** - API development with OpenAPI support

## 🔄 **Navigation**

- **[Overview](./overview.md)** - Getting started with client generation
- **[Language Commands](./languages.md)** - Ready-to-use generation commands
- **[Advanced Configuration](./advanced.md)** - Custom templates and automation
- **[Usage Examples](./usage.md)** - See generated clients in action

---

**Need help?** Check the troubleshooting section above or reach out to the OpenAPI Generator community for support.