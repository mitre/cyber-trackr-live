#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Read the OpenAPI specification
const openApiPath = path.join(__dirname, '..', 'openapi', 'openapi.yaml');
const openApiContent = fs.readFileSync(openApiPath, 'utf8');

// Create the HTML template with embedded OpenAPI spec
const htmlTemplate = `<!doctype html>
<html>
  <head>
    <title>Cyber Trackr API Reference</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
    </style>
  </head>
  <body>
    <div id="app"></div>
    <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
    <script>
      Scalar.createApiReference('#app', {
        spec: {
          content: ${JSON.stringify(openApiContent)}
        },
        proxyUrl: 'https://proxy.scalar.com',
        configuration: {
          layout: 'modern',
          theme: 'default',
          showSidebar: true,
          searchHotKey: 'k'
        },
        metaData: {
          title: 'Cyber Trackr API Documentation',
          description: 'Complete OpenAPI 3.1.1 specification for cyber.trackr.live API',
          ogDescription: 'Access to DISA STIGs, SRGs, RMF controls, CCIs, and SCAP data',
        }
      })
    </script>
  </body>
</html>`;

// Ensure the output directory exists
const outputDir = process.argv[2] || 'site';
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// Write the HTML file
const outputPath = path.join(outputDir, 'index.html');
fs.writeFileSync(outputPath, htmlTemplate);

console.log(`✅ Generated Scalar documentation at ${outputPath}`);
console.log(`📄 File size: ${Math.round(fs.statSync(outputPath).size / 1024)}KB`);
console.log(`🚀 Ready for GitHub Pages deployment`);