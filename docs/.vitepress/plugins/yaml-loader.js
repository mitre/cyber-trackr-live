import yaml from 'js-yaml'
import fs from 'fs'
import path from 'path'

/**
 * Vite plugin to automatically load YAML files as JSON objects
 * This enables importing OpenAPI YAML specs directly in VitePress
 * 
 * @param {Object} options - Plugin options
 * @param {string} options.specPath - Path to OpenAPI YAML file relative to project root
 * @param {string} options.virtualId - Virtual module ID for importing the spec
 */
export function yamlLoader(options = {}) {
  const { 
    specPath = 'openapi/openapi.yaml',
    virtualId = 'virtual:openapi-spec'
  } = options

  let isProduction = false
  
  return {
    name: 'yaml-loader',
    configResolved(config) {
      // Store config for reference
      isProduction = config.command === 'build'
    },
    resolveId(id) {
      if (id === virtualId) {
        return id
      }
    },
    load(id) {
      if (id === virtualId) {
        try {
          // Load YAML file relative to project root
          const yamlPath = path.resolve(process.cwd(), specPath)
          const yamlContent = fs.readFileSync(yamlPath, 'utf8')
          const jsonSpec = yaml.load(yamlContent)
          
          // Note: We use a global fetch interceptor for CORS proxy instead of modifying server URLs
          // This mimics Scalar's approach and works better than URL manipulation
          console.log('🔧 YAML Loader: Using original server URLs with fetch interceptor for CORS')
          console.log('🔧 YAML Loader: Servers:', jsonSpec.servers.map(s => s.url))
          
          // Return as ES module
          return `export default ${JSON.stringify(jsonSpec, null, 2)}`
        } catch (error) {
          this.error(`Failed to load OpenAPI YAML from ${specPath}: ${error.message}`)
        }
      }
    }
  }
}