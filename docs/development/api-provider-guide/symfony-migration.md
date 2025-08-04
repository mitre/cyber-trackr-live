# Symfony OpenAPI Migration Guide: cyber.trackr.live Implementation

This guide is specifically tailored for the **cyber.trackr.live** team using Symfony and shows how to integrate the reverse-engineered OpenAPI specification into their existing architecture.

## Key Learnings from Research

Based on our analysis of real Symfony/API Platform projects:
1. **API Platform is the standard** - Most modern Symfony APIs use API Platform for OpenAPI support
2. **Configuration is straightforward** - Simple YAML configuration enables OpenAPI features
3. **Multiple integration options** - Can use API Platform, NelmioApiDocBundle, or custom validation
4. **OpenAPI Factory** - API Platform provides sophisticated OpenAPI generation and customization
5. **Real examples show** - Projects commonly enable both API Platform and Nelmio for maximum flexibility

## Current Understanding

Based on our analysis:
- **Symfony PHP** framework (confirmed by API owners)
- **OpenAPI 3.1.1 specification** reverse-engineered from live API
- **XML XPath queries** for DISA STIG data
- **No traditional database** - XML files as data source
- **AI integration** for mitigation statements

## Why This Benefits cyber.trackr.live

### Your Reverse-Engineered Spec Becomes Official
1. **Adopt as source of truth**: The spec you created becomes their official API documentation
2. **Validation layer**: Ensure API responses match the documented spec
3. **Client generation**: Auto-generate clients in multiple languages
4. **Testing foundation**: Use spec for contract testing
5. **Future-proofing**: Maintain backward compatibility

## Integration Approaches for Symfony

### Option 1: API Platform Integration (Recommended)

API Platform is the modern standard for Symfony APIs. While it typically generates OpenAPI from code, you can customize it to work with your existing spec:

```yaml
# config/packages/api_platform.yaml
api_platform:
    title: 'Cyber Trackr API'
    description: 'DISA STIGs, SRGs, CCIs, and RMF Controls'
    version: '1.0.3'
    mapping:
        paths: ['%kernel.project_dir%/src/Entity']
    formats:
        json:
            mime_types: ['application/json']
    # Enable Swagger UI
    enable_documentation: true
    # Optional: Also enable NelmioApiDocBundle integration
    enable_nelmio_api_doc: true
```

To use your existing OpenAPI spec, create a custom OpenAPI factory decorator:

```php
<?php
// src/OpenApi/OpenApiFactoryDecorator.php
namespace App\OpenApi;

use ApiPlatform\OpenApi\Factory\OpenApiFactoryInterface;
use ApiPlatform\OpenApi\OpenApi;
use Symfony\Component\Yaml\Yaml;

final class OpenApiFactoryDecorator implements OpenApiFactoryInterface
{
    public function __construct(
        private OpenApiFactoryInterface $decorated,
        private string $projectDir
    ) {}

    public function __invoke(array $context = []): OpenApi
    {
        $openApi = $this->decorated->__invoke($context);
        
        // Load your existing OpenAPI spec
        $customSpec = Yaml::parseFile($this->projectDir . '/openapi/openapi.yaml');
        
        // Merge or replace with your spec as needed
        // This is where you integrate your reverse-engineered spec
        
        return $openApi;
    }
}
```

#### Benefits:
- Modern Symfony standard for APIs
- Can integrate your existing OpenAPI spec
- Built-in Swagger UI interface
- Strong ecosystem and community support

### Option 2: NelmioApiDocBundle (Traditional)

If they're already using Nelmio, they can enhance it with your spec:

```yaml
# config/packages/nelmio_api_doc.yaml
nelmio_api_doc:
    documentation:
        # Import external OpenAPI spec
        imports:
            - { resource: openapi/openapi.yaml }
    areas:
        path_patterns:
            - ^/api
```

### Option 3: OpenAPI Validation Middleware

For minimal changes, add validation to existing controllers using the PSR-7 bridge:

```php
<?php
// src/EventListener/OpenApiValidationListener.php
namespace App\EventListener;

use League\OpenAPIValidation\PSR7\ValidatorBuilder;
use League\OpenAPIValidation\PSR7\Exception\ValidationFailed;
use Symfony\Bridge\PsrHttpMessage\Factory\PsrHttpFactory;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\Event\ResponseEvent;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;
use Psr\Log\LoggerInterface;

class OpenApiValidationListener
{
    private $requestValidator;
    private $responseValidator;
    private $psrHttpFactory;

    public function __construct(
        string $projectDir,
        private LoggerInterface $logger
    ) {
        $validatorBuilder = (new ValidatorBuilder())
            ->fromYamlFile($projectDir . '/openapi/openapi.yaml');
        
        $this->requestValidator = $validatorBuilder->getRequestValidator();
        $this->responseValidator = $validatorBuilder->getResponseValidator();
        
        // PSR-7 bridge for Symfony requests
        $this->psrHttpFactory = new PsrHttpFactory();
    }

    public function onKernelRequest(RequestEvent $event): void
    {
        if (!$event->isMainRequest()) {
            return;
        }

        $symfonyRequest = $event->getRequest();
        $psrRequest = $this->psrHttpFactory->createRequest($symfonyRequest);
        
        try {
            $this->requestValidator->validate($psrRequest);
        } catch (ValidationFailed $e) {
            $this->logger->warning('OpenAPI request validation failed', [
                'path' => $symfonyRequest->getPathInfo(),
                'error' => $e->getMessage()
            ]);
            
            // Optional: throw exception to reject invalid requests
            // throw new BadRequestHttpException($e->getMessage());
        }
    }
}
```

Register as a service:
```yaml
# config/services.yaml
services:
    App\EventListener\OpenApiValidationListener:
        arguments:
            $projectDir: '%kernel.project_dir%'
        tags:
            - { name: kernel.event_listener, event: kernel.request, priority: 100 }
```

## Required Packages

Install the necessary packages based on your chosen approach:

```bash
# For API Platform (Option 1)
composer require api

# For OpenAPI validation (Option 3)
composer require league/openapi-psr7-validator
composer require symfony/psr-http-message-bridge

# For NelmioApiDocBundle (Option 2)
composer require nelmio/api-doc-bundle
```

## Implementation Strategy

### Phase 1: Documentation Integration (Week 1)

#### Step 1: Add OpenAPI Spec to Project
```bash
# Add to your Symfony project
cd /path/to/cyber-trackr-symfony
mkdir -p openapi
curl -o openapi/openapi.yaml \
  https://raw.githubusercontent.com/mitre/cyber-trackr-live/main/openapi/openapi.yaml
```

#### Step 2: Serve OpenAPI Documentation
```yaml
# config/routes/api_documentation.yaml
api_docs:
    path: /api/docs
    controller: App\Controller\DocumentationController::index

openapi_spec:
    path: /api/openapi.yaml
    controller: App\Controller\DocumentationController::spec
```

```php
<?php
// src/Controller/DocumentationController.php
namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;

class DocumentationController extends AbstractController
{
    public function index(): Response
    {
        return $this->render('api/documentation.html.twig');
    }

    public function spec(): Response
    {
        $spec = file_get_contents($this->getParameter('kernel.project_dir') . '/openapi/openapi.yaml');
        
        return new Response($spec, 200, [
            'Content-Type' => 'application/x-yaml'
        ]);
    }
}
```

```twig
{# templates/api/documentation.html.twig #}
<!DOCTYPE html>
<html>
<head>
    <title>Cyber Trackr API Documentation</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
        SwaggerUIBundle({
            url: '/api/openapi.yaml',
            dom_id: '#swagger-ui',
            presets: [
                SwaggerUIBundle.presets.apis,
                SwaggerUIBundle.presets.standalone
            ]
        });
    </script>
</body>
</html>
```

### Phase 2: Request/Response Validation

#### Using API Platform (Recommended)
```php
<?php
// src/Entity/Stig.php
namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;

#[ApiResource(
    operations: [
        new GetCollection(
            uriTemplate: '/api/stig',
            openapiContext: [
                'summary' => 'List all DISA STIGs',
                'description' => 'Returns all available DISA Security Technical Implementation Guides'
            ]
        ),
        new Get(
            uriTemplate: '/api/stig/{title}/{version}/{release}',
            openapiContext: [
                'summary' => 'Get specific STIG with all requirements',
                'parameters' => [
                    ['name' => 'title', 'in' => 'path', 'required' => true],
                    ['name' => 'version', 'in' => 'path', 'required' => true],
                    ['name' => 'release', 'in' => 'path', 'required' => true]
                ]
            ]
        )
    ]
)]
class Stig
{
    public string $id;
    public string $title;
    public string $version;
    public string $release;
    public array $requirements = [];
}
```

#### Using Validation Middleware
```php
<?php
// src/Service/OpenApiValidator.php
namespace App\Service;

use League\OpenAPIValidation\PSR7\ValidatorBuilder;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Message\ResponseInterface;

class OpenApiValidator
{
    private $requestValidator;
    private $responseValidator;

    public function __construct(string $specPath)
    {
        $validatorBuilder = (new ValidatorBuilder())
            ->fromYamlFile($specPath);
            
        $this->requestValidator = $validatorBuilder->getServerRequestValidator();
        $this->responseValidator = $validatorBuilder->getResponseValidator();
    }

    public function validateRequest(ServerRequestInterface $request): void
    {
        $this->requestValidator->validate($request);
    }

    public function validateResponse(ResponseInterface $response, ServerRequestInterface $request): void
    {
        $this->responseValidator->validate($response, $request);
    }
}
```

### Phase 3: Existing Business Logic Integration

Your existing services remain unchanged:

```php
<?php
// src/Service/StigService.php - YOUR EXISTING BUSINESS LOGIC
namespace App\Service;

use DOMDocument;
use DOMXPath;

class StigService
{
    private string $xmlPath;

    public function __construct(string $xmlStoragePath)
    {
        $this->xmlPath = $xmlStoragePath;
    }

    public function getAllDocuments(): array
    {
        // Your existing XML XPath queries remain unchanged
        $documents = [];
        $xmlFiles = glob($this->xmlPath . '/*.xml');
        
        foreach ($xmlFiles as $file) {
            $dom = new DOMDocument();
            $dom->load($file);
            $xpath = new DOMXPath($dom);
            
            // Your existing parsing logic
            $title = $xpath->query('//title')->item(0)->nodeValue;
            $version = $xpath->query('//version')->item(0)->nodeValue;
            // ... continue with existing logic
        }
        
        return $documents;
    }
}
```

### Phase 4: Generate Client Libraries

Using your OpenAPI spec, generate official client libraries:

```bash
# Generate Ruby client
docker run --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate \
    -i /local/openapi/openapi.yaml \
    -g ruby \
    -o /local/clients/ruby

# Generate Python client
docker run --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate \
    -i /local/openapi/openapi.yaml \
    -g python \
    -o /local/clients/python

# Generate TypeScript client
docker run --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate \
    -i /local/openapi/openapi.yaml \
    -g typescript-fetch \
    -o /local/clients/typescript
```

## Testing with Your OpenAPI Spec

### Contract Testing
```php
<?php
// tests/Api/OpenApiContractTest.php
namespace App\Tests\Api;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use League\OpenAPIValidation\PSR7\ValidatorBuilder;

class OpenApiContractTest extends WebTestCase
{
    private $validator;

    protected function setUp(): void
    {
        parent::setUp();
        $this->validator = (new ValidatorBuilder())
            ->fromYamlFile(__DIR__ . '/../../openapi/openapi.yaml')
            ->getResponseValidator();
    }

    public function testStigListMatchesSpec(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/stig');
        
        $response = $client->getResponse();
        
        // Validate response matches OpenAPI spec
        $this->validator->validate($response, $client->getRequest());
        
        $this->assertResponseIsSuccessful();
    }
}
```

## Advanced Integration Options

### 1. Generate Symfony Code from OpenAPI

Use OpenAPI Generator to create Symfony server stubs:

```bash
# Generate Symfony server bundle from your spec
docker run --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate \
    -i /local/openapi/openapi.yaml \
    -g php-symfony \
    -o /local/generated-server \
    --additional-properties=bundleName=CyberTrackrApiBundle
```

### 2. API Platform with Custom Data Provider

Integrate your XML-based data with API Platform:

```php
<?php
// src/DataProvider/StigDataProvider.php
namespace App\DataProvider;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProviderInterface;
use App\Service\StigService;

class StigDataProvider implements ProviderInterface
{
    public function __construct(
        private StigService $stigService
    ) {}

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): object|array|null
    {
        if ($operation->getUriTemplate() === '/api/stig') {
            return $this->stigService->getAllDocuments();
        }
        
        if (isset($uriVariables['title'])) {
            return $this->stigService->getDocument(
                $uriVariables['title'],
                $uriVariables['version'],
                $uriVariables['release']
            );
        }
        
        return null;
    }
}
```

### 3. Symfony Serializer Configuration

Ensure responses match your OpenAPI spec format:

```yaml
# config/packages/serializer.yaml
framework:
    serializer:
        name_converter: 'serializer.name_converter.camel_case_to_snake_case'
        default_context:
            json_encode_options: JSON_UNESCAPED_SLASHES | JSON_PRESERVE_ZERO_FRACTION
```

## Benefits for cyber.trackr.live Team

### Immediate Benefits
1. **Professional documentation** at `/api/docs`
2. **Your spec becomes official** - No more reverse engineering needed
3. **Request/response validation** - Catch API drift early
4. **Multi-language clients** - Ruby, Python, TypeScript, etc.

### Long-term Benefits
1. **API governance** - Changes require spec updates first
2. **Parallel development** - Frontend teams use spec while backend implements
3. **Automated testing** - Contract tests ensure compliance
4. **Community adoption** - Clear API contract for integrators

## Migration Timeline

### Week 1: Documentation
- [ ] Add OpenAPI spec to repository
- [ ] Deploy Swagger UI at `/api/docs`
- [ ] Share with stakeholders

### Week 2: Validation
- [ ] Add request validation middleware
- [ ] Add response validation in tests
- [ ] Fix any spec mismatches

### Week 3: Client Generation
- [ ] Generate official client libraries
- [ ] Publish to package repositories
- [ ] Update documentation

### Week 4: Full Integration
- [ ] API Platform or enhanced Nelmio setup
- [ ] Contract testing suite
- [ ] CI/CD integration

## Key Differences from Laravel Guide

1. **Framework-specific**: Uses Symfony components and best practices
2. **API Platform focus**: Leverages Symfony's leading API framework
3. **Service-based architecture**: Aligns with Symfony service patterns
4. **Bundle structure**: Can be packaged as reusable Symfony bundle
5. **Symfony testing**: Uses WebTestCase and Symfony test tools

## Next Steps

1. **Review with your team** - Does this align with your Symfony setup?
2. **Choose integration approach** - API Platform, Nelmio, or custom?
3. **Test locally** - Add spec and documentation first
4. **Gradual rollout** - Start with docs, add validation, then full integration

This approach lets the cyber.trackr.live team adopt your carefully crafted OpenAPI specification as their official API contract, improving their development process while maintaining their existing Symfony architecture!