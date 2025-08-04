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
              { text: 'Platform Compatibility', link: '/guide/platform-compatibility' },
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
              { text: 'Diagram Color Guide', link: '/development/diagram-color-guide' }
            ]
          },
          {
            text: 'Testing',
            items: [
              { text: 'Testing Overview', link: '/development/testing/' },
              { text: 'Two-Tier Testing', link: '/development/testing/two-tier-testing' },
              { text: 'API Testing Guide', link: '/development/testing/api-testing' }
            ]
          },
          {
            text: 'Release Process',
            items: [
              { text: 'Overview', link: '/development/release-process/' },
              { text: 'Quick Release Guide', link: '/development/release-process/quick-release' },
              { text: 'Architecture', link: '/development/release-process/architecture' },
              { text: 'First Release Setup', link: '/development/release-process/first-release' },
              { text: 'Development Workflow', link: '/development/release-process/development-workflow' },
              { text: 'Troubleshooting', link: '/development/release-process/troubleshooting' }
            ]
          },
          {
            text: 'API Provider Guide',
            items: [
              { text: 'Overview', link: '/development/api-provider-guide/' },
              { text: 'OpenAPI-First Approach', link: '/development/api-provider-guide/openapi-first' },
              { text: 'Symfony Migration', link: '/development/api-provider-guide/symfony-migration' },
              { text: 'Laravel Migration', link: '/development/api-provider-guide/laravel-migration' },
              { text: 'Static API Generation', link: '/development/api-provider-guide/static-generation' }
            ]
          }
        ],
        '/clients/': [
          {
            text: 'Overview',
            items: [
              { text: 'All Clients', link: '/clients/' }
            ]
          },
          {
            text: 'Client Generation',
            items: [
              { text: 'Getting Started', link: '/clients/generation/overview' },
              { text: 'Language Commands', link: '/clients/generation/languages' },
              { text: 'Advanced Configuration', link: '/clients/generation/advanced' },
              { text: 'Usage Examples', link: '/clients/generation/usage' },
              { text: 'Reference Guide', link: '/clients/generation/reference' }
            ]
          },
          {
            text: 'Ruby Client',
            items: [
              { text: 'Overview', link: '/clients/ruby/' },
              { text: 'Helper Methods', link: '/clients/ruby/helper-methods' },
              { text: 'Examples', link: '/clients/ruby/examples' }
            ]
          },
          {
            text: 'Ruby Releases',
            items: [
              { text: 'v1.0.3 (Latest)', link: '/clients/ruby/releases/v1.0.3' },
              { text: 'v1.0.2', link: '/clients/ruby/releases/v1.0.2' },
              { text: 'v1.0.1', link: '/clients/ruby/releases/v1.0.1' },
              { text: 'v1.0.0', link: '/clients/ruby/releases/v1.0.0' }
            ]
          }
        ],
        '/project/': [
          {
            text: 'Project Information',
            items: [
              { text: 'Overview', link: '/project/' },
              { text: 'Project README', link: '/project/readme' },
              { text: 'Implementation Summary', link: '/project/implementation' },
              { text: 'Project Collaboration', link: '/project/collaboration' }
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
        '/api-reference/': [
          {
            text: 'Getting Started',
            items: [
              { text: 'Quick Start Guide', link: '/api-reference/getting-started' },
              { text: 'API Operations', link: '/api-reference/' },
              { text: 'Interactive Docs (CORS)', link: '/api-reference/cors-proxy' }
            ]
          }
        ],
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