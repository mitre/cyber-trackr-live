import { defineConfig } from 'vitepress'
import { yamlLoader } from './plugins/yaml-loader.js'
import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid(defineConfig({
    title: 'cyber.trackr.live',
    description: 'OpenAPI specification and Ruby client for cyber.trackr.live API - DISA STIGs, SRGs, RMF controls, CCIs, and SCAP data',
    base: '/cyber-trackr-live/',
    
    // Mermaid configuration
    mermaid: {
      theme: 'default',
      logLevel: 'error',
      securityLevel: 'loose',
      startOnLoad: true,
      flowchart: {
        htmlLabels: true,
        useMaxWidth: true,
        padding: 20
      }
    },
    
    head: [
      ['link', { rel: 'icon', href: '/favicon.ico' }]
    ],

    themeConfig: {
      logo: '/logo.svg',
      
      outline: {
        level: [2, 3]
      },
      
      nav: [
        { text: 'Guide', link: '/guide/' },
        { text: 'OpenAPI Spec', link: '/openapi/' },
        { text: 'API Reference', link: '/api-reference/' },
        { text: 'Development', link: '/development/' },
        { text: 'Clients', link: '/clients/' },
        { text: 'Project', link: '/project/' },
        { text: 'Future', link: '/future/' },
        { text: 'GitHub', link: 'https://github.com/mitre/cyber-trackr-live' }
      ],

      sidebar: {
        '/guide/': [
          {
            text: 'Getting Started',
            items: [
              { text: 'Introduction', link: '/guide/' },
              { text: 'Installation', link: '/guide/installation' },
              { text: 'Quick Start', link: '/guide/quick-start' },
              { text: 'Testing', link: '/guide/testing' }
            ]
          }
        ],
        '/openapi/': [
          {
            text: 'OpenAPI Specification',
            items: [
              { text: 'Overview', link: '/openapi/' },
              { text: 'Specification Details', link: '/openapi/specification' },
              { text: 'OpenAPI-First Benefits', link: '/openapi/benefits' },
              { text: 'Validation & Quality', link: '/openapi/validation' }
            ]
          }
        ],
        '/development/': [
          {
            text: 'Getting Started',
            items: [
              { text: 'Overview', link: '/development/' },
              { text: 'OpenAPI Development', link: '/development/openapi-development' },
              { text: 'API Testing', link: '/development/api-testing' },
              { text: 'Diagram Color Guide', link: '/development/diagram-color-guide' }
            ]
          },
          {
            text: 'Architecture',
            items: [
              { text: 'System Integration', link: '/development/architecture/system-integration' },
              { text: 'Two-Tier Testing', link: '/development/architecture/two-tier-testing' },
              { text: 'CORS Proxy Solution', link: '/development/architecture/cors-proxy-solution' },
              { text: 'Faraday Migration', link: '/development/architecture/faraday-migration' },
              { text: 'Windows Compatibility', link: '/development/architecture/windows-compatibility' },
              { text: 'Validation Cleanup', link: '/development/architecture/validation-cleanup' }
            ]
          },
          {
            text: 'Release Process',
            items: [
              { text: 'Release Workflow', link: '/development/release-process' }
            ]
          }
        ],
        '/clients/': [
          {
            text: 'Overview',
            items: [
              { text: 'All Clients', link: '/clients/' },
              { text: 'Client Generation', link: '/clients/generation' }
            ]
          },
          {
            text: 'Ruby Client',
            items: [
              { text: 'Overview', link: '/clients/ruby/' },
              { text: 'Helper Methods', link: '/clients/ruby/helper-methods' },
              { text: 'Examples', link: '/clients/ruby/examples' }
            ]
          }
        ],
        '/project/': [
          {
            text: 'Project Information',
            items: [
              { text: 'Overview', link: '/project/' },
              { text: 'Project README', link: '/project/readme' },
              { text: 'Implementation Summary', link: '/project/implementation' }
            ]
          },
          {
            text: 'Contributing',
            items: [
              { text: 'Contributing Guide', link: '/project/contributing' },
              { text: 'Code of Conduct', link: '/project/code-of-conduct' }
            ]
          },
          {
            text: 'Security & Legal',
            items: [
              { text: 'Security Policy', link: '/project/security' },
              { text: 'License', link: '/project/license' },
              { text: 'Legal Notices', link: '/project/notices' }
            ]
          },
          {
            text: 'Support',
            items: [
              { text: 'Known Issues', link: '/project/known-issues' }
            ]
          }
        ],
        '/future/': [
          {
            text: 'Roadmap',
            items: [
              { text: 'Overview', link: '/future/' }
            ]
          },
          {
            text: 'API Provider Guide',
            items: [
              { text: 'Getting Started', link: '/future/api-provider-guide/' },
              { text: 'OpenAPI-First Approach', link: '/future/api-provider-guide/openapi-first' },
              { text: 'Laravel Migration', link: '/future/api-provider-guide/laravel-migration' },
              { text: 'Static API Generation', link: '/future/api-provider-guide/static-generation' }
            ]
          }
        ],
        '/patterns/': [
          {
            text: 'Project Patterns',
            items: [
              { text: 'Overview', link: '/patterns/' },
              { text: 'Universal OpenAPI Patterns', link: '/patterns/universal-openapi-patterns' }
            ]
          }
        ],
        '/api-reference/': [], // Will be auto-generated from OpenAPI
        '/reference/': [
          {
            text: 'Changelogs',
            items: [
              { text: 'Ruby Gem Changelog', link: '/reference/changelog-ruby' },
              { text: 'OpenAPI Specification Changelog', link: '/reference/changelog-openapi' }
            ]
          },
          {
            text: 'Process',
            items: [
              { text: 'Release Process', link: '/reference/release-process' }
            ]
          }
        ]
      },

      socialLinks: [
        { icon: 'github', link: 'https://github.com/mitre/cyber-trackr-live' }
      ],

      footer: {
        message: 'Released under the Apache-2.0 License.',
        copyright: 'Copyright © 2025 MITRE Corporation'
      },

      search: {
        provider: 'local'
      }
    },

    vite: {
      resolve: {
        preserveSymlinks: true
      },
      plugins: [yamlLoader({
        specPath: 'openapi/openapi.yaml', // Relative to project root
        virtualId: 'virtual:openapi-spec'
      })],
      server: {
        proxy: {
          '^/api/(?!reference)': {
            target: 'https://cyber.trackr.live',
            changeOrigin: true,
            secure: true,
            rewrite: (path) => path,
            headers: {
              'User-Agent': 'VitePress-OpenAPI-Docs/1.0',
              'Accept': 'application/json'
            },
            configure: (proxy, options) => {
              proxy.on('error', (err, req, res) => {
                console.log('❌ Proxy error:', err);
                console.log('   Request URL:', req.url);
                console.log('   Request headers:', req.headers);
              });
              proxy.on('proxyReq', (proxyReq, req, res) => {
                console.log('🚀 Proxy request:', req.method, req.url);
                console.log('   Headers:', JSON.stringify(req.headers, null, 2));
                console.log('   Target URL:', proxyReq.path);
              });
              proxy.on('proxyRes', (proxyRes, req, res) => {
                console.log('✅ Proxy response:', req.method, req.url, proxyRes.statusCode);
                console.log('   Response headers:', JSON.stringify(proxyRes.headers, null, 2));
              });
            }
          }
        }
      }
    }
  }))