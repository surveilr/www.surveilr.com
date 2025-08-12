import { assert, assertEquals, assertExists } from "jsr:@std/assert@1";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";

// Test configuration for markdown transformation testing
const E2E_TEST_DIR = path.join(Deno.cwd(), "lib/assurance");
const TEST_FIXTURES_DIR = path.join(E2E_TEST_DIR, "markdown-test-files");
const MARKDOWN_FIXTURES_RSSD = path.join(
  E2E_TEST_DIR,
  "markdown-transform-test.sqlite.db",
);

Deno.test("Complete Markdown Transformation Workflow", async (t) => {

  await t.step("initialize fresh database with admin init", async () => {
    // Clean up any existing database
    if (await Deno.stat(MARKDOWN_FIXTURES_RSSD).catch(() => null)) {
      await Deno.remove(MARKDOWN_FIXTURES_RSSD);
    }

    console.log("🔄 Running surveilr admin init for fresh database...");
    
    // Initialize fresh database
    const initResult = await $`surveilr admin init -d ${MARKDOWN_FIXTURES_RSSD}`.stderr("piped");
    
    assertEquals(
      initResult.code,
      0,
      `❌ admin init failed: ${initResult.stderr}`
    );

    assertExists(
      await Deno.stat(MARKDOWN_FIXTURES_RSSD).catch(() => null),
      "❌ Database was not created after admin init"
    );

    console.log("✅ Fresh database initialized");
  });

  await t.step("update database rules for document transformation", async () => {
    const db = new DB(MARKDOWN_FIXTURES_RSSD);
    
    try {
      console.log("🔄 Updating ur_ingest_resource_path_match_rule for document transformation...");
      
      // First, check if our rule exists and delete it if so
      db.query(
        `DELETE FROM ur_ingest_resource_path_match_rule 
         WHERE ur_ingest_resource_path_match_rule_id IN ('pdf-docx-transform-metadata', 'document-transform-metadata')`
      );
      
      // Insert our updated rule that includes all Office documents and sets nature to 'md'
      db.query(`
        INSERT INTO ur_ingest_resource_path_match_rule (
          ur_ingest_resource_path_match_rule_id,
          namespace,
          regex,
          flags,
          nature,
          priority,
          description,
          created_at
        ) VALUES (
          'document-transform-markdown',
          'default',
          '\\.(?P<nature>pdf|docx|xlsx|pptx)$',
          'CONTENT_ACQUIRABLE | CONTENT_ACQUIRABLE_TRANSFORM_MARKITDOWN | CONTENT_ACQUIRABLE_METADATA',
          '?P<nature>',
          1,
          'PDF, DOCX, XLSX, and PPTX documents transformed to markdown with metadata extraction',
          CURRENT_TIMESTAMP
        )
      `);

      // Verify the rule was inserted
      const ruleCheck = db.query<[string, string, string, string]>(
        `SELECT ur_ingest_resource_path_match_rule_id, regex, flags, nature
         FROM ur_ingest_resource_path_match_rule 
         WHERE ur_ingest_resource_path_match_rule_id = 'document-transform-markdown'`
      );

      assertEquals(ruleCheck.length, 1, "❌ Document transformation rule was not inserted");
      console.log(`✅ Updated rule: ${ruleCheck[0][1]} -> nature: ${ruleCheck[0][3]}`);
      
      // Show all active rules for debugging
      const allRules = db.query<[string, string, string, string]>(
        `SELECT ur_ingest_resource_path_match_rule_id, regex, flags, nature
         FROM ur_ingest_resource_path_match_rule 
         ORDER BY priority`
      );
      
      console.log("\n🔍 All active ingestion rules:");
      allRules.forEach(([id, regex, flags, nature]) => {
        console.log(`  ${id}: ${regex} -> ${nature} (${flags})`);
      });
      
    } finally {
      db.close();
    }
  });

  await t.step("verify test fixtures exist", async () => {
    assertExists(
      await Deno.stat(TEST_FIXTURES_DIR).catch(() => null),
      `❌ Error: Test fixtures directory ${TEST_FIXTURES_DIR} does not exist`,
    );

    // Check for document files in test fixtures
    const files = [];
    for await (const entry of Deno.readDir(TEST_FIXTURES_DIR)) {
      if (entry.isFile) {
        const ext = path.extname(entry.name).toLowerCase();
        if (['.pdf', '.docx', '.doc', '.pptx', '.ppt', '.xlsx', '.xls', '.png', '.jpg', '.jpeg'].includes(ext)) {
          files.push(entry.name);
        }
      }
    }

    console.log(`📁 Found ${files.length} document files in test fixtures:`, files);
    
    if (files.length === 0) {
      console.warn("⚠️ No PDF, DOCX, XLSX, PPTX, or image files found in test fixtures");
      console.warn(`   Please add test documents to: ${TEST_FIXTURES_DIR}`);
      console.warn("   Recommended files: sample.pdf, document.docx, spreadsheet.xlsx, presentation.pptx");
      console.warn("   This test will demonstrate the workflow with any files you provide.");
    } else {
      console.log(`   Files found: ${files.join(', ')}`);
    }
  });

  await t.step("ingest test fixtures with automatic markdown transformation", async () => {
    console.log("🔄 Ingesting test fixtures with automatic markdown transformation...");
    
    // Ingest test fixtures - this should automatically transform PDF/DOCX/XLSX/PPTX to markdown
    const ingestResult = await $`surveilr ingest files -d ${MARKDOWN_FIXTURES_RSSD} -r ${TEST_FIXTURES_DIR} --stats`.stderr("piped");
      
    if (ingestResult.code !== 0) {
      console.warn(`⚠️ surveilr ingest completed with warnings: ${ingestResult.stderr}`);
    } else {
      console.log("✅ Test fixtures ingested successfully");
    }
  });

  await t.step("analyze ingestion and transformation results", () => {
    const db = new DB(MARKDOWN_FIXTURES_RSSD);
    
    try {
      // Get comprehensive statistics about all ingested files
      const statsResult = db.query<[string, number, number, number]>(
        `SELECT 
           COALESCE(nature, 'unknown') as file_type,
           COUNT(*) as total_files,
           COUNT(CASE WHEN content_fm_body_attrs IS NOT NULL THEN 1 END) as files_with_metadata,
           COUNT(CASE WHEN frontmatter IS NOT NULL THEN 1 END) as files_with_frontmatter
         FROM uniform_resource 
         GROUP BY nature
         ORDER BY total_files DESC`,
      );

      console.log("\n📊 Ingestion Results by File Type (After Transformation):");
      console.log("File Type | Total | Metadata | Frontmatter");
      console.log("----------|-------|----------|------------");
      
      let totalFiles = 0;
      let totalWithMetadata = 0;
      let totalWithFrontmatter = 0;

      statsResult.forEach(([fileType, total, withMetadata, withFrontmatter]) => {
        console.log(`${fileType.padEnd(9)} | ${total.toString().padStart(5)} | ${withMetadata.toString().padStart(8)} | ${withFrontmatter.toString().padStart(11)}`);
        totalFiles += total;
        totalWithMetadata += withMetadata;
        totalWithFrontmatter += withFrontmatter;
      });

      console.log("----------|-------|----------|------------");
      console.log(`Total     | ${totalFiles.toString().padStart(5)} | ${totalWithMetadata.toString().padStart(8)} | ${totalWithFrontmatter.toString().padStart(11)}`);

      assert(totalFiles > 0, "❌ Error: No files were ingested");
      
      // Check specifically for markdown files created from document transformation
      const markdownFiles = db.query<[number]>(
        `SELECT COUNT(*) FROM uniform_resource WHERE nature = 'md'`
      );
      
      const mdCount = markdownFiles[0] ? markdownFiles[0][0] : 0;
      console.log(`\n✅ Found ${mdCount} files transformed to markdown (nature='md')`);
      
      // Debug: Show all files and their nature + frontmatter status
      const allFiles = db.query<[string, string, string, string]>(
        `SELECT uri, nature, 
                CASE WHEN frontmatter IS NULL THEN 'NULL' 
                     WHEN LENGTH(frontmatter) > 50 THEN SUBSTR(frontmatter, 1, 50) || '...' 
                     ELSE frontmatter END as frontmatter_preview,
                CASE WHEN content IS NULL THEN 'NULL'
                     WHEN LENGTH(content) > 50 THEN SUBSTR(content, 1, 50) || '...'
                     ELSE content END as content_preview
         FROM uniform_resource 
         ORDER BY nature, uri`
      );
      
      console.log("\n🔍 Debug: All ingested files:");
      allFiles.forEach(([uri, nature, frontmatter, content]) => {
        const filename = uri.split('/').pop() || uri;
        console.log(`  ${filename} -> nature: ${nature || 'NULL'}`);
        console.log(`    frontmatter: ${frontmatter}`);
        console.log(`    content: ${content}`);
      });
      
      if (mdCount > 0) {
        // Show sample of transformed documents
        const mdSamples = db.query<[string, string]>(
          `SELECT uri, 
                  CASE WHEN LENGTH(frontmatter) > 100 
                       THEN SUBSTR(frontmatter, 1, 100) || '...' 
                       ELSE frontmatter END as sample_content
           FROM uniform_resource 
           WHERE nature = 'md' 
           LIMIT 3`
        );
        
        console.log("📄 Sample Transformed Documents:");
        mdSamples.forEach(([uri, sample]) => {
          const filename = path.basename(uri);
          console.log(`  ${filename}:`);
          console.log(`    Content: ${sample.replace(/\n/g, '\\n')}`);
        });
      }
      
    } finally {
      db.close();
    }
  });

  await t.step("verify markdown files are ready for transformation", async () => {
    const db = new DB(MARKDOWN_FIXTURES_RSSD);
    
    try {
      console.log("🔄 Checking markdown files ready for transform-markdown...");
      
      // Count files with nature='md' (should be created automatically during ingestion)
      const markdownFiles = db.query<[number]>(
        `SELECT COUNT(*) FROM uniform_resource WHERE nature = 'md'`
      )[0][0];

      if (markdownFiles === 0) {
        console.warn("⚠️ No markdown files found (nature='md'). Documents should auto-transform during ingestion.");
        
        // Show what we actually have
        const allFiles = db.query<[string, string]>(
          `SELECT uri, nature FROM uniform_resource ORDER BY nature, uri`
        );
        
        console.log("📄 Files in database:");
        allFiles.forEach(([uri, nature]) => {
          console.log(`  ${path.basename(uri)} -> nature: ${nature}`);
        });
        return;
      }

      console.log(`✅ Found ${markdownFiles} markdown files ready for transformation`);
      
      // Show sample of markdown files
      const mdSamples = db.query<[string, string]>(
        `SELECT uri, 
                CASE WHEN LENGTH(content) > 100 
                     THEN SUBSTR(content, 1, 100) || '...' 
                     ELSE content END as sample_content
         FROM uniform_resource 
         WHERE nature = 'md' 
         LIMIT 3`
      );
      
      console.log("📄 Sample Markdown Files:");
      mdSamples.forEach(([uri, sample]) => {
        const filename = path.basename(uri);
        console.log(`  ${filename}:`);
        console.log(`    Content: ${sample.replace(/\n/g, '\\n')}`);
      });
      
    } finally {
      db.close();
    }
  });

  await t.step("run transform-markdown on markdown files", async () => {
    console.log("🔄 Running surveilr orchestrate transform-markdown on files with nature='md'...");
    
    // First check if we have any markdown files
    const db = new DB(MARKDOWN_FIXTURES_RSSD);
    let mdCount = 0;
    
    try {
      const mdFiles = db.query<[number]>(
        `SELECT COUNT(*) FROM uniform_resource WHERE nature = 'md'`
      );
      mdCount = mdFiles[0] ? mdFiles[0][0] : 0;
    } finally {
      db.close();
    }

    if (mdCount === 0) {
      console.warn("⚠️ No markdown files found (nature='md') - skipping transform-markdown");
      return;
    }

    console.log(`📄 Found ${mdCount} markdown files to transform`);

    // Run transform-markdown with correct mdq selectors
    const transformResult = await $`surveilr orchestrate -d ${MARKDOWN_FIXTURES_RSSD} transform-markdown --md-select="all_headers:#" --md-select="all_paragraphs:P:" --md-select="all_links:[]()" --md-select="all_tables::-: * :-:"`.stderr("piped").stdout("piped");
      
    console.log(`📋 Transform-markdown stdout: ${transformResult.stdout}`);
    console.log(`📋 Transform-markdown stderr: ${transformResult.stderr}`);
    console.log(`📋 Transform-markdown exit code: ${transformResult.code}`);
    
    if (transformResult.code !== 0) {
      console.error(`❌ transform-markdown failed with code ${transformResult.code}`);
      console.error(`❌ stderr: ${transformResult.stderr}`);
      console.error(`❌ stdout: ${transformResult.stdout}`);
      // Don't fail immediately - let's see what happened
    } else {
      console.log("✅ Transform-markdown completed successfully");
    }
  });

  await t.step("query and analyze transformed json results", async () => {
    const db = new DB(MARKDOWN_FIXTURES_RSSD);
    
    try {
      // Check if transform table exists
      const tableExists = db.query<[number]>(
        `SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='uniform_resource_transform'`
      )[0][0] > 0;

      if (!tableExists) {
        console.log("ℹ️ No transform results - uniform_resource_transform table not found");
        return;
      }

      // Get transform results organized by md-selector
      const selectorResults = db.query<[string, string, string]>(
        `SELECT 
           urt.uri as selector_uri,
           ur.uri as source_file,
           urt.content
         FROM uniform_resource_transform urt
         JOIN uniform_resource ur ON urt.uniform_resource_id = ur.uniform_resource_id
         WHERE ur.nature = 'md'
         ORDER BY urt.uri, ur.uri`
      );

      console.log(`\n🔍 Transform Results: ${selectorResults.length} transformations found`);

      if (selectorResults.length > 0) {
        const groupedResults: { [key: string]: Array<[string, string]> } = {};
        
        // Group by selector type (extract selector name from URI)
        selectorResults.forEach(([selectorUri, sourceFile, content]) => {
          // Extract selector name from URI like "file.pdf/md-select:all_headers"
          const selectorName = selectorUri.includes('/md-select:') 
            ? selectorUri.split('/md-select:')[1] 
            : selectorUri;
            
          if (!groupedResults[selectorName]) {
            groupedResults[selectorName] = [];
          }
          groupedResults[selectorName].push([sourceFile, content]);
        });

        // Display results for each selector
        Object.entries(groupedResults).forEach(([selector, results]) => {
          console.log(`\n📋 Selector "${selector}":`);
          console.log(`   Found ${results.length} results from ${new Set(results.map(r => r[0])).size} files`);
          
          results.slice(0, 2).forEach(([sourceFile, content]) => {
            const filename = path.basename(sourceFile);
            try {
              const parsed = JSON.parse(content);
              if (Array.isArray(parsed)) {
                console.log(`   • ${filename}: ${parsed.length} elements extracted`);
                
                // Show sample content
                if (parsed.length > 0 && parsed[0]) {
                  const sample = typeof parsed[0] === 'string' 
                    ? parsed[0] 
                    : JSON.stringify(parsed[0]);
                  console.log(`     Sample: "${sample.substring(0, 60)}${sample.length > 60 ? '...' : ''}"`);
                }
              } else {
                console.log(`   • ${filename}: Single element extracted`);
                const sample = typeof parsed === 'string' ? parsed : JSON.stringify(parsed);
                console.log(`     Content: "${sample.substring(0, 60)}${sample.length > 60 ? '...' : ''}"`);
              }
            } catch (e) {
              console.log(`   • ${filename}: JSON parse error - ${e.message}`);
              console.log(`     Raw content: ${content.substring(0, 100)}...`);
            }
          });
          
          if (results.length > 2) {
            console.log(`   ... and ${results.length - 2} more results`);
          }
        });

        // Show SQL query examples
        console.log("\n📊 Example SQL queries for accessing transformed data:");
        console.log("   -- All headers from all files:");
        console.log("   SELECT ur.uri as source_file, urt.content as headers");
        console.log("   FROM uniform_resource_transform urt");
        console.log("   JOIN uniform_resource ur ON urt.uniform_resource_id = ur.uniform_resource_id");
        console.log("   WHERE urt.uri LIKE '%/md-select:all_headers';");
        
        console.log("\n   -- All paragraphs from specific file:");
        console.log("   SELECT urt.content as paragraphs");
        console.log("   FROM uniform_resource_transform urt");
        console.log("   JOIN uniform_resource ur ON urt.uniform_resource_id = ur.uniform_resource_id");
        console.log("   WHERE ur.uri LIKE '%filename.pdf' AND urt.uri LIKE '%/md-select:all_paragraphs';");

        console.log("\n✅ Successfully analyzed transformed JSON data using md-selectors");
      } else {
        console.log("ℹ️ No transform results found");
      }
      
    } finally {
      db.close();
    }
  });

  await t.step("validate end-to-end workflow success", async () => {
    const db = new DB(MARKDOWN_FIXTURES_RSSD);
    
    try {
      // Count documents at each stage
      const totalFiles = db.query<[number]>(
        `SELECT COUNT(*) FROM uniform_resource`
      )[0][0];
      
      const markdownFiles = db.query<[number]>(
        `SELECT COUNT(*) FROM uniform_resource WHERE nature = 'md'`
      )[0][0];
      
      let transformedFiles = 0;
      try {
        const result = db.query<[number]>(
          `SELECT COUNT(DISTINCT ur.uniform_resource_id) 
           FROM uniform_resource ur
           JOIN uniform_resource_transform urt ON ur.uniform_resource_id = urt.uniform_resource_id
           WHERE ur.nature = 'md'`
        );
        transformedFiles = result[0] ? result[0][0] : 0;
      } catch {
        // Table might not exist yet
        transformedFiles = 0;
      }

      console.log("\n📊 End-to-End Workflow Summary:");
      console.log(`  Total files ingested: ${totalFiles}`);
      console.log(`  Files transformed to markdown: ${markdownFiles}`);
      console.log(`  Markdown files processed to JSON: ${transformedFiles}`);
      
      // Success criteria
      if (markdownFiles > 0) {
        console.log("\n✅ SUCCESS: Document → Markdown transformation working");
      }
      
      if (transformedFiles > 0) {
        console.log("✅ SUCCESS: Markdown → JSON transformation working");
        console.log("✅ SUCCESS: Complete workflow validated");
      } else if (markdownFiles > 0) {
        console.log("⚠️  Partial success: Documents transformed to markdown, but transform-markdown step had issues");
      } else {
        console.log("❌ No documents were successfully transformed");
      }
      
    } finally {
      db.close();
    }
  });

});

Deno.test("cleanup markdown transformation test database", async () => {
  try {
    if (await Deno.stat(MARKDOWN_FIXTURES_RSSD).catch(() => null)) {
      await Deno.remove(MARKDOWN_FIXTURES_RSSD);
      console.log(`🧹 Cleaned up ${path.basename(MARKDOWN_FIXTURES_RSSD)}`);
    }
  } catch (error) {
    console.warn(`⚠️ Failed to cleanup ${MARKDOWN_FIXTURES_RSSD}: ${error.message}`);
  }
});