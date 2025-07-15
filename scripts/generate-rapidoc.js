#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Create the RapiDoc HTML following official quickstart
const htmlTemplate = `<!doctype html>
<html>
  <head>
    <title>Cyber Trackr API - RapiDoc</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script type="module" src="https://unpkg.com/rapidoc/dist/rapidoc-min.js"></script>
  </head>
  <body>
    <rapi-doc 
      spec-url="./openapi.yaml"
      theme="dark"
      render-style="read"
      layout="row"
      sort-tags="true"
      allow-try="true"
      allow-authentication="false"
      allow-server-selection="true"
      default-api-server="https://corsproxy.io/?https://cyber.trackr.live/api"
      heading-text="🔒 Cyber Trackr API"
      info-description-headings-in-navbar="true"
      style="height:100vh; width:100%"
    >
    </rapi-doc>
  </body>
</html>`;

// Ensure the output directory exists
const outputDir = process.argv[2] || 'site';
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// Copy the OpenAPI spec to the site directory
const openApiSource = path.join(__dirname, '..', 'openapi', 'openapi.yaml');
const openApiDest = path.join(outputDir, 'openapi.yaml');
fs.copyFileSync(openApiSource, openApiDest);

// Write the HTML file
const outputPath = path.join(outputDir, 'rapidoc.html');
fs.writeFileSync(outputPath, htmlTemplate);

console.log(`✅ Generated RapiDoc documentation at ${outputPath}`);
console.log(`📄 Copied OpenAPI spec to ${openApiDest}`);
console.log(`🚀 Visit http://localhost:8000/rapidoc.html`);
console.log(`📋 Features: Dark theme, interactive testing, row layout, "try it" enabled`);