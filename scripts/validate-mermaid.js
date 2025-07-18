#!/usr/bin/env node

import fs from 'fs'
import path from 'path'
import { glob } from 'glob'
import { execSync } from 'child_process'

const TEMP_DIR = '.temp-mermaid'

// Create temp directory for extracted diagrams
if (!fs.existsSync(TEMP_DIR)) {
  fs.mkdirSync(TEMP_DIR)
}

function extractMermaidBlocks(filePath) {
  const content = fs.readFileSync(filePath, 'utf8')
  const mermaidBlocks = []
  
  // Find all ```mermaid blocks
  const regex = /```mermaid\n([\s\S]*?)\n```/g
  let match
  let blockIndex = 0
  
  while ((match = regex.exec(content)) !== null) {
    const mermaidCode = match[1]
    const fileName = path.basename(filePath, '.md')
    const tempFile = path.join(TEMP_DIR, `${fileName}-${blockIndex}.mmd`)
    
    fs.writeFileSync(tempFile, mermaidCode)
    mermaidBlocks.push({
      file: filePath,
      block: blockIndex,
      tempFile,
      code: mermaidCode
    })
    blockIndex++
  }
  
  return mermaidBlocks
}

function validateMermaidFile(tempFile, originalFile, blockIndex) {
  try {
    // Use mmdc (mermaid-cli) to validate by trying to generate SVG
    execSync(`npx mmdc -i "${tempFile}" -o "${tempFile}.svg" -q`, { 
      stdio: 'pipe' 
    })
    console.log(`✅ ${originalFile} - Block ${blockIndex}: Valid`)
    
    // Clean up generated SVG
    if (fs.existsSync(`${tempFile}.svg`)) {
      fs.unlinkSync(`${tempFile}.svg`)
    }
    
    return true
  } catch (error) {
    console.log(`❌ ${originalFile} - Block ${blockIndex}: SYNTAX ERROR`)
    console.log(`   Error: ${error.message.split('\n')[0]}`)
    console.log(`   File: ${tempFile}`)
    return false
  }
}

async function main() {
  console.log('🔍 Validating Mermaid diagrams...\n')
  
  // Find all markdown files in docs directory
  const markdownFiles = await glob('docs/**/*.md', {
    ignore: ['**/node_modules/**']
  })
  
  let totalBlocks = 0
  let validBlocks = 0
  let hasErrors = false
  
  for (const file of markdownFiles) {
    const mermaidBlocks = extractMermaidBlocks(file)
    
    if (mermaidBlocks.length > 0) {
      console.log(`📄 ${file}:`)
      
      for (const block of mermaidBlocks) {
        totalBlocks++
        const isValid = validateMermaidFile(block.tempFile, file, block.block)
        
        if (isValid) {
          validBlocks++
        } else {
          hasErrors = true
          console.log(`\nDiagram code:`)
          console.log('```mermaid')
          console.log(block.code)
          console.log('```\n')
        }
        
        // Clean up temp file
        if (fs.existsSync(block.tempFile)) {
          fs.unlinkSync(block.tempFile)
        }
      }
    }
  }
  
  // Clean up temp directory
  if (fs.existsSync(TEMP_DIR)) {
    fs.rmSync(TEMP_DIR, { recursive: true })
  }
  
  console.log(`\n📊 Results:`)
  console.log(`   Total diagrams: ${totalBlocks}`)
  console.log(`   Valid: ${validBlocks}`)
  console.log(`   Errors: ${totalBlocks - validBlocks}`)
  
  if (hasErrors) {
    console.log('\n❌ Mermaid validation failed. Please fix syntax errors above.')
    process.exit(1)
  } else {
    console.log('\n✅ All Mermaid diagrams are valid!')
  }
}

main().catch(console.error)