import { usePaths } from 'vitepress-openapi'
import yaml from 'js-yaml'
import fs from 'fs'
import path from 'path'

// Load OpenAPI spec directly in Node.js context
const yamlPath = path.resolve(process.cwd(), 'openapi/openapi.yaml')
const yamlContent = fs.readFileSync(yamlPath, 'utf8')
const spec = yaml.load(yamlContent)

export default {
    paths() {
        return usePaths({ spec })
            .getPathsByVerbs()
            .map(({ operationId, summary }) => {
                return {
                    params: {
                        operationId,
                        pageTitle: `${summary} - cyber.trackr.live API`,
                    },
                }
            })
    },
}