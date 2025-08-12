#!/usr/bin/env -S deno run --allow-run --allow-read --allow-write
/**
 * Complex DOCX Capturable Executable using Deno shell and Python markitdown CLI
 * Processes DOCX files and outputs structured markdown with metadata
 * 
 * This CapEx uses Deno shell to call the Python markitdown CLI version,
 * providing performance metrics and content analysis.
 * 
 * Usage: deno run --allow-run --allow-read --allow-write complex.surveilr[docx].ts <docx_file>
 * Requires: pip install markitdown
 */

import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";

interface ProcessingResult {
  success: boolean;
  content: string;
  conversion_time_ms: number;
  content_length: number;
  content_hash: string;
  structure: StructureAnalysis;
  error?: string;
  markitdown_version: string;
  processed_at: string;
}

interface StructureAnalysis {
  heading_count: number;
  h1_count: number;
  h2_count: number;
  h3_count: number;
  list_count: number;
  table_count: number;
  code_block_count: number;
  link_count: number;
  line_count: number;
  paragraph_count: number;
}

async function calculateHash(content: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(content);
  const hashBuffer = await crypto.subtle.digest("SHA-1", data);
  return Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0')).join('');
}

function analyzeMarkdownStructure(markdownContent: string): StructureAnalysis {
  const lines = markdownContent.split('\n');
  
  // Count different markdown elements
  const headingCount = lines.filter(line => line.startsWith('#')).length;
  const listCount = lines.filter(line => 
    line.trim().match(/^[-*+]\s/) || line.trim().match(/^\d+\.\s/)
  ).length;
  const tableCount = lines.filter(line => 
    line.includes('|') && line.split('|').length >= 3
  ).length;
  const codeBlockCount = lines.filter(line => 
    line.trim().startsWith('```')
  ).length;
  const linkCount = lines.filter(line => 
    line.includes('[') && line.includes('](')
  ).length;
  
  // Analyze heading structure
  const h1Count = lines.filter(line => line.startsWith('# ')).length;
  const h2Count = lines.filter(line => line.startsWith('## ')).length;
  const h3Count = lines.filter(line => line.startsWith('### ')).length;
  
  const paragraphCount = lines.filter(line => 
    line.trim() && 
    !line.startsWith('#') && 
    !line.trim().match(/^[-*+]/) && 
    !line.includes('|') && 
    !line.startsWith('```')
  ).length;

  return {
    heading_count: headingCount,
    h1_count: h1Count,
    h2_count: h2Count,
    h3_count: h3Count,
    list_count: listCount,
    table_count: tableCount,
    code_block_count: codeBlockCount,
    link_count: linkCount,
    line_count: lines.length,
    paragraph_count: paragraphCount
  };
}

async function processDocxWithMarkitdown(filePath: string): Promise<ProcessingResult> {
  const startTime = Date.now();
  
  try {
    // Run markitdown command using Deno shell
    const result = await $`markitdown ${filePath}`.timeout(60000).noThrow();
    
    const endTime = Date.now();
    const conversionTime = endTime - startTime;
    
    if (result.code !== 0) {
      return {
        success: false,
        content: `<!-- Conversion failed: ${result.stderr} -->`,
        conversion_time_ms: conversionTime,
        content_length: 0,
        content_hash: '',
        structure: {
          heading_count: 0, h1_count: 0, h2_count: 0, h3_count: 0,
          list_count: 0, table_count: 0, code_block_count: 0,
          link_count: 0, line_count: 0, paragraph_count: 0
        },
        error: `markitdown failed with code ${result.code}: ${result.stderr}`,
        markitdown_version: 'python-markitdown-cli',
        processed_at: new Date().toISOString()
      };
    }
    
    const markdownContent = result.stdout;
    const structureAnalysis = analyzeMarkdownStructure(markdownContent);
    const contentHash = await calculateHash(markdownContent);
    
    return {
      success: true,
      content: markdownContent,
      conversion_time_ms: conversionTime,
      content_length: markdownContent.length,
      content_hash: contentHash,
      structure: structureAnalysis,
      markitdown_version: 'python-markitdown-cli',
      processed_at: new Date().toISOString()
    };
    
  } catch (error) {
    const endTime = Date.now();
    const errorMessage = error.message || 'Unknown error';
    
    let content = '';
    let specificError = '';
    
    if (errorMessage.includes('command not found') || errorMessage.includes('No such file')) {
      content = '<!-- markitdown not found. Install: pip install markitdown -->';
      specificError = 'markitdown not installed - run: pip install markitdown';
    } else if (errorMessage.includes('timeout')) {
      content = '<!-- Conversion timed out after 60 seconds -->';
      specificError = 'Conversion timed out after 60 seconds';
    } else {
      content = `<!-- Conversion error: ${errorMessage} -->`;
      specificError = `Conversion error: ${errorMessage}`;
    }
    
    return {
      success: false,
      content,
      conversion_time_ms: endTime - startTime,
      content_length: 0,
      content_hash: '',
      structure: {
        heading_count: 0, h1_count: 0, h2_count: 0, h3_count: 0,
        list_count: 0, table_count: 0, code_block_count: 0,
        link_count: 0, line_count: 0, paragraph_count: 0
      },
      error: specificError,
      markitdown_version: 'python-markitdown-cli',
      processed_at: new Date().toISOString()
    };
  }
}

async function main() {
  if (Deno.args.length < 1) {
    console.error("Usage: complex.surveilr[docx].ts <docx_file>");
    console.error("");
    console.error("This Capturable Executable converts DOCX files to markdown using Python markitdown CLI");
    console.error("Requires: pip install markitdown");
    Deno.exit(1);
  }
  
  const docxPath = Deno.args[0];
  
  let fileSize = 0;
  try {
    const stat = await Deno.stat(docxPath);
    fileSize = stat.size;
  } catch {
    console.error(`File not found: ${docxPath}`);
    Deno.exit(1);
  }
  
  if (!docxPath.toLowerCase().endsWith('.docx') && !docxPath.toLowerCase().endsWith('.doc')) {
    console.error(`Warning: File ${docxPath} does not have .docx/.doc extension`);
  }
  
  const result = await processDocxWithMarkitdown(docxPath);
  
  // Output comprehensive metadata as comments
  console.log(`<!-- DOCX Markitdown Conversion Report -->`);
  console.log(`<!-- File: ${docxPath} -->`);
  console.log(`<!-- File Size: ${fileSize} bytes (${(fileSize/1024/1024).toFixed(2)} MB) -->`);
  console.log(`<!-- Success: ${result.success} -->`);
  console.log(`<!-- Conversion Time: ${result.conversion_time_ms.toFixed(2)}ms -->`);
  console.log(`<!-- Content Length: ${result.content_length} chars -->`);
  console.log(`<!-- Content Hash: ${result.content_hash} -->`);
  console.log(`<!-- Markitdown Version: ${result.markitdown_version} -->`);
  console.log(`<!-- Processed At: ${result.processed_at} -->`);
  
  if (result.success && result.structure) {
    const s = result.structure;
    console.log(`<!-- Structure Analysis: -->`);
    console.log(`<!--   Headings: ${s.heading_count} (H1:${s.h1_count}, H2:${s.h2_count}, H3:${s.h3_count}) -->`);
    console.log(`<!--   Lists: ${s.list_count} -->`);
    console.log(`<!--   Tables: ${s.table_count} -->`);
    console.log(`<!--   Code Blocks: ${s.code_block_count} -->`);
    console.log(`<!--   Links: ${s.link_count} -->`);
    console.log(`<!--   Paragraphs: ${s.paragraph_count} -->`);
    console.log(`<!--   Total Lines: ${s.line_count} -->`);
  }
  
  if (result.error) {
    console.log(`<!-- Error: ${result.error} -->`);
  }
  
  console.log();
  console.log("---");
  console.log("# DOCX to Markdown Conversion");
  console.log(`**Source:** \`${docxPath.split('/').pop()}\``);
  console.log(`**Converted by:** Deno + Python markitdown CLI`);
  console.log(`**Conversion time:** ${result.conversion_time_ms.toFixed(2)}ms`);
  console.log("---");
  console.log();
  
  // Output the markdown content
  console.log(result.content);
}

if (import.meta.main) {
  main();
}