#!/bin/bash
# Generate Ruby client from OpenAPI specification

set -e  # Exit on any error

echo "🚀 Generating Ruby client from OpenAPI specification..."
echo

# Check if OpenAPI spec exists
if [ ! -f "openapi/openapi.yaml" ]; then
    echo "❌ openapi/openapi.yaml not found"
    exit 1
fi

# Create a temporary directory for generation
TEMP_DIR="temp_generated"

# Remove existing temp directory
if [ -d "$TEMP_DIR" ]; then
    echo "🗑️  Removing existing temp directory..."
    rm -rf "$TEMP_DIR"
fi

# Extract version from OpenAPI spec
API_VERSION=$(grep "^  version:" openapi/openapi.yaml | sed 's/.*: //')
echo "📋 Using API version: $API_VERSION"

# Generate the client using Docker to temp directory
echo "📦 Generating client with OpenAPI Generator..."
docker run --rm \
    -v "${PWD}:/local" \
    openapitools/openapi-generator-cli generate \
    -i /local/openapi/openapi.yaml \
    -g ruby \
    -o /local/$TEMP_DIR \
    --library=faraday \
    --additional-properties=gemName=cyber_trackr_client,moduleName=CyberTrackrClient,gemVersion=$API_VERSION

echo "✅ Client generation complete"
echo

# Copy generated files to lib/cyber_trackr_client
echo "📁 Moving generated client to lib/cyber_trackr_client..."
rm -rf lib/cyber_trackr_client
cp -r "$TEMP_DIR/lib/cyber_trackr_client" lib/

# Clean up temp directory
rm -rf "$TEMP_DIR"

# Post-generation fixes removed - API now returns proper JSON headers
echo "🔧 Skipping post-generation fixes - API now returns proper JSON headers"

echo
echo "🎉 Ruby client generation complete!"
echo "   Client location: lib/cyber_trackr_client/"
echo "   Ready to use with workarounds applied"