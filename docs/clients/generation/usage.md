# Using Generated Clients

See your generated API clients in action with practical, real-world examples.

## **Ruby Client Usage**

```ruby
# Generated Ruby client usage
require 'cyber_trackr_live'

# Initialize client
client = CyberTrackrLive::DefaultApi.new

# List STIGs
stigs = client.list_stigs
puts "Found #{stigs.count} STIGs"

# Get specific STIG
stig = client.get_stig('Juniper_SRX_Services_Gateway_ALG', '3', '3')
puts "STIG: #{stig.title}"

# Search for specific requirements
requirements = client.get_stig_requirements('Juniper_SRX_Services_Gateway_ALG', '3', '3')
puts "Found #{requirements.count} requirements"

# Get RMF controls
controls = client.list_rmf_controls('5')
puts "Found #{controls.count} RMF 5.0 controls"
```

## **TypeScript Client Usage**

```typescript
// Generated TypeScript client usage
import { DefaultApi, Configuration } from 'cyber-trackr-live';

const config = new Configuration({
  basePath: 'https://cyber.trackr.live'
});

const client = new DefaultApi(config);

async function demo() {
  try {
    // List STIGs
    const stigs = await client.listStigs();
    console.log(`Found ${stigs.length} STIGs`);

    // Get specific STIG
    const stig = await client.getStig('Juniper_SRX_Services_Gateway_ALG', '3', '3');
    console.log(`STIG: ${stig.title}`);

    // Search for specific requirements
    const requirements = await client.getStigRequirements('Juniper_SRX_Services_Gateway_ALG', '3', '3');
    console.log(`Found ${requirements.length} requirements`);

    // Get RMF controls
    const controls = await client.listRmfControls('5');
    console.log(`Found ${controls.length} RMF 5.0 controls`);
  } catch (error) {
    console.error('API Error:', error);
  }
}

demo();
```

## **Python Client Usage**

```python
# Generated Python client usage
import cyber_trackr_live
from cyber_trackr_live.rest import ApiException

# Initialize client
configuration = cyber_trackr_live.Configuration(
    host = "https://cyber.trackr.live"
)
client = cyber_trackr_live.DefaultApi(
    cyber_trackr_live.ApiClient(configuration)
)

def demo():
    try:
        # List STIGs
        stigs = client.list_stigs()
        print(f"Found {len(stigs)} STIGs")

        # Get specific STIG
        stig = client.get_stig('Juniper_SRX_Services_Gateway_ALG', '3', '3')
        print(f"STIG: {stig.title}")

        # Search for specific requirements
        requirements = client.get_stig_requirements('Juniper_SRX_Services_Gateway_ALG', '3', '3')
        print(f"Found {len(requirements)} requirements")

        # Get RMF controls
        controls = client.list_rmf_controls('5')
        print(f"Found {len(controls)} RMF 5.0 controls")

    except ApiException as e:
        print(f"API Exception: {e}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    demo()
```

## **Go Client Usage**

```go
// Generated Go client usage
package main

import (
    "context"
    "fmt"
    "log"
    
    cybertrackrlive "github.com/your-username/go-client"
)

func main() {
    cfg := cybertrackrlive.NewConfiguration()
    cfg.BasePath = "https://cyber.trackr.live"
    
    client := cybertrackrlive.NewAPIClient(cfg)
    ctx := context.Background()
    
    // List STIGs
    stigs, _, err := client.DefaultApi.ListStigs(ctx)
    if err != nil {
        log.Printf("Error listing STIGs: %v", err)
        return
    }
    fmt.Printf("Found %d STIGs\n", len(stigs))
    
    // Get specific STIG
    stig, _, err := client.DefaultApi.GetStig(ctx, 
        "Juniper_SRX_Services_Gateway_ALG", "3", "3")
    if err != nil {
        log.Printf("Error getting STIG: %v", err)
        return
    }
    fmt.Printf("STIG: %s\n", stig.Title)
    
    // Search for specific requirements
    requirements, _, err := client.DefaultApi.GetStigRequirements(ctx, 
        "Juniper_SRX_Services_Gateway_ALG", "3", "3")
    if err != nil {
        log.Printf("Error getting requirements: %v", err)
        return
    }
    fmt.Printf("Found %d requirements\n", len(requirements))
    
    // Get RMF controls
    controls, _, err := client.DefaultApi.ListRmfControls(ctx, "5")
    if err != nil {
        log.Printf("Error listing RMF controls: %v", err)
        return
    }
    fmt.Printf("Found %d RMF 5.0 controls\n", len(controls))
}
```

## Common Patterns

### Error Handling

Each generated client handles errors differently:

**Ruby**
```ruby
begin
  stig = client.get_stig('invalid', '0', '0')
rescue CyberTrackrLive::ApiError => e
  puts "API Error: #{e.message}"
end
```

**TypeScript**
```typescript
try {
  const stig = await client.getStig('invalid', '0', '0');
} catch (error) {
  console.error('API Error:', error.message);
}
```

**Python**
```python
try:
    stig = client.get_stig('invalid', '0', '0')
except ApiException as e:
    print(f"API Exception: {e}")
```

**Go**
```go
stig, response, err := client.DefaultApi.GetStig(ctx, "invalid", "0", "0")
if err != nil {
    log.Printf("API Error: %v (Status: %d)", err, response.StatusCode)
}
```

### Configuration Options

**Ruby**
```ruby
# Custom configuration
config = CyberTrackrLive::Configuration.new
config.host = 'https://cyber.trackr.live'
config.debugging = true
client = CyberTrackrLive::DefaultApi.new(CyberTrackrLive::ApiClient.new(config))
```

**TypeScript**
```typescript
const config = new Configuration({
  basePath: 'https://cyber.trackr.live',
  fetchApi: fetch,
  middleware: [{
    pre: async (context) => {
      console.log('Request:', context.url);
      return context;
    }
  }]
});
```

**Python**
```python
configuration = cyber_trackr_live.Configuration(
    host = "https://cyber.trackr.live"
)
configuration.debug = True
client = cyber_trackr_live.DefaultApi(
    cyber_trackr_live.ApiClient(configuration)
)
```

**Go**
```go
cfg := cybertrackrlive.NewConfiguration()
cfg.BasePath = "https://cyber.trackr.live"
cfg.Debug = true
client := cybertrackrlive.NewAPIClient(cfg)
```

## 📚 **Next Steps**

- **[Language Commands](./languages.md)** - Generate clients for these examples
- **[Advanced Configuration](./advanced.md)** - Customize client generation
- **[Reference Guide](./reference.md)** - Troubleshooting and best practices
- **[Overview](./overview.md)** - Back to getting started

## 🎯 **Production Tips**

1. **Environment Variables** - Store API base URL in environment variables
2. **Timeout Configuration** - Set appropriate timeouts for your use case
3. **Retry Logic** - Implement retry logic for transient failures
4. **Logging** - Enable debug logging during development
5. **Error Handling** - Always handle API exceptions gracefully