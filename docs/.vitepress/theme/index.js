import DefaultTheme from 'vitepress/theme'
import { theme, useOpenapi, useShiki } from 'vitepress-openapi/client'
import { setupProxyInterceptor } from '../plugins/proxy-interceptor.js'
import spec from 'virtual:openapi-spec'
import 'vitepress-openapi/dist/style.css'

export default {
  extends: DefaultTheme,
  async enhanceApp({ app }) {
    // Initialize Shiki highlighter as singleton first
    await useShiki().init()
    
    // Set the OpenAPI specification (loaded from YAML via our custom plugin)
    useOpenapi({
      spec,
    })
    
    // Setup proxy interceptor for CORS (like Scalar does)
    if (typeof window !== 'undefined') {
      // Use Scalar's CORS proxy for production/GitHub Pages
      setupProxyInterceptor('https://proxy.scalar.com')
    }
    
    // Use the theme
    theme.enhanceApp({ app })
  }
}