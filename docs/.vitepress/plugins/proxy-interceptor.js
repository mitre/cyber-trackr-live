/**
 * Proxy interceptor for VitePress OpenAPI
 * Mimics Scalar's proxy behavior to handle CORS issues
 */

// Check if URL is relative path
function isRelativePath(url) {
  try {
    new URL(url)
    return false
  } catch {
    return true
  }
}

// Check if URL is localhost/local IP
function isLocalUrl(url) {
  try {
    const urlObj = new URL(url)
    const hostname = urlObj.hostname
    return (
      hostname === 'localhost' ||
      hostname === '127.0.0.1' ||
      hostname === '0.0.0.0' ||
      hostname.startsWith('192.168.') ||
      hostname.startsWith('10.') ||
      hostname.startsWith('172.')
    )
  } catch {
    return false
  }
}

// Determine if we should use proxy (same logic as Scalar)
function shouldUseProxy(proxyUrl, url) {
  try {
    console.log('🔍 shouldUseProxy check:', { proxyUrl, url })
    
    // No proxy URL or URL
    if (!proxyUrl || !url) {
      console.log('   ❌ No proxy URL or URL provided')
      return false
    }

    // Relative URLs don't need proxy
    if (isRelativePath(url)) {
      console.log('   ❌ URL is relative path, no proxy needed')
      return false
    }

    // Proxy URL is relative (e.g. /proxy)
    if (isRelativePath(proxyUrl)) {
      console.log('   ✅ Proxy URL is relative, using proxy')
      return true
    }

    // Proxy URL is local
    if (isLocalUrl(proxyUrl)) {
      console.log('   ✅ Proxy URL is local, using proxy')
      return true
    }

    // Don't proxy localhost requests (proxy can't reach them)
    if (isLocalUrl(url)) {
      console.log('   ❌ Target URL is localhost, no proxy needed')
      return false
    }

    // Remote proxy + remote URL = use proxy
    console.log('   ✅ Remote proxy + remote URL, using proxy')
    return true
  } catch (error) {
    console.log('   ❌ Error in shouldUseProxy:', error)
    return false
  }
}

// Redirect URL to proxy (same logic as Scalar)
function redirectToProxy(proxyUrl, url) {
  try {
    console.log('🔄 redirectToProxy:', { proxyUrl, url })
    
    if (!shouldUseProxy(proxyUrl, url)) {
      console.log('   ❌ shouldUseProxy returned false, returning original URL')
      return url
    }

    // Create new URL object
    const newUrl = new URL(url)
    console.log('   📝 Created URL object:', newUrl.toString())

    // Handle relative proxy URLs
    const temporaryProxyUrl = isRelativePath(proxyUrl) 
      ? `http://localhost${proxyUrl}` 
      : proxyUrl
    console.log('   🌐 Temporary proxy URL:', temporaryProxyUrl)

    // Rewrite with proxy URL
    newUrl.href = temporaryProxyUrl
    console.log('   🔧 After setting href:', newUrl.toString())

    // Add original URL as scalar_url parameter
    newUrl.searchParams.append('scalar_url', url)
    console.log('   📌 After adding scalar_url:', newUrl.toString())

    // Remove temporary domain for relative proxy URLs
    const result = isRelativePath(proxyUrl)
      ? newUrl.toString().replace(/^http:\/\/localhost/, '')
      : newUrl.toString()
    
    console.log('   ✅ Final proxy URL:', result)
    return result
  } catch (error) {
    console.log('   ❌ Error in redirectToProxy:', error)
    return url
  }
}

// Fetch with proxy fallback (same logic as Scalar)
async function fetchWithProxyFallback(url, proxyUrl, originalFetch) {
  const shouldTryProxy = shouldUseProxy(proxyUrl, url)
  const initialUrl = shouldTryProxy ? redirectToProxy(proxyUrl, url) : url

  try {
    console.log('🌐 Proxy interceptor:', shouldTryProxy ? 'Using proxy' : 'Direct fetch')
    console.log('   Original URL:', url)
    console.log('   Fetch URL:', initialUrl)
    
    const result = await originalFetch(initialUrl)
    
    console.log('📥 Fetch response:', {
      status: result.status,
      statusText: result.statusText,
      ok: result.ok,
      headers: Object.fromEntries(result.headers.entries()),
      url: result.url
    })

    if (result.ok || !shouldTryProxy) {
      console.log('   ✅ Request successful or no proxy, returning result')
      return result
    }

    // Retry without proxy if initial request failed
    console.log('🔄 Proxy failed, retrying direct fetch')
    const retryResult = await originalFetch(url)
    console.log('📥 Retry response:', {
      status: retryResult.status,
      statusText: retryResult.statusText,
      ok: retryResult.ok,
      url: retryResult.url
    })
    return retryResult
  } catch (error) {
    console.log('❌ Fetch error:', error)
    if (shouldTryProxy) {
      // If proxy failed, try without it
      console.log('🔄 Proxy error, retrying direct fetch')
      try {
        const retryResult = await originalFetch(url)
        console.log('📥 Error retry response:', {
          status: retryResult.status,
          statusText: retryResult.statusText,
          ok: retryResult.ok,
          url: retryResult.url
        })
        return retryResult
      } catch (retryError) {
        console.log('❌ Retry also failed:', retryError)
        throw retryError
      }
    }
    throw error
  }
}

// Intercept global fetch for VitePress OpenAPI
export function setupProxyInterceptor(proxyUrl) {
  if (!proxyUrl) {
    console.log('🚫 No proxy URL provided, skipping interceptor')
    return
  }

  // Store original fetch
  const originalFetch = window.fetch

  // Replace global fetch
  window.fetch = async function(input, init) {
    const url = typeof input === 'string' ? input : input.url
    
    console.log('🌐 FETCH INTERCEPTED:', {
      url,
      input: typeof input === 'string' ? input : input,
      init,
      timestamp: new Date().toISOString()
    })

    // Only intercept API calls to external domains
    if (url && shouldUseProxy(proxyUrl, url)) {
      console.log('   🔀 Routing through proxy interceptor')
      return fetchWithProxyFallback(url, proxyUrl, originalFetch)
    }

    // Use original fetch for everything else
    console.log('   ➡️  Using original fetch (no proxy needed)')
    return originalFetch.call(this, input, init)
  }

  console.log('✅ Proxy interceptor setup with:', proxyUrl)
}