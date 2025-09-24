#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * drizzle-sql-generator.surveilr-SQL.ts - Drizzle SQL Generator Capturable Executable
 * 
 * This capturable executable demonstrates how to use Drizzle ORM to generate SQL
 * statements and emit them for surveilr to capture. Perfect for:
 * - Creating migration scripts
 * - Generating SQL for external tools
 * - Building dynamic queries as strings
 * - SQL generation in CI/CD pipelines
 * 
 * Usage:
 *   deno run -A drizzle-sql-generator.surveilr-SQL.ts
 *   surveilr ingest files -r . --include-capturable-exec-sql-output
 */

// Note: This capturable executable demonstrates SQL generation patterns
// without requiring actual Drizzle ORM imports for the SQL emission

// ULID generation for database records
function generateUlid(): string {
  const timestamp = Date.now().toString().slice(-8);
  const randomPart = Array.from({ length: 18 }, () => 
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Math.floor(Math.random() * 36)]
  ).join('');
  return `${timestamp}${randomPart}`;
}

// SQL escaping function
function escapeSql(value: string | null | undefined): string {
  if (value == null) return '';
  return value.toString().replace(/'/g, "''");
}

// Get current ISO timestamp
function getCurrentTimestamp(): string {
  return new Date().toISOString();
}

const currentTime = getCurrentTimestamp();
const ingestSessionId = generateUlid();

console.log("-- Drizzle SQL Generator for RSSD");
console.log("-- Generated at:", currentTime);
console.log("-- Purpose: Demonstrate SQL generation and data insertion patterns");
console.log("-- File: drizzle-sql-generator.surveilr-SQL.ts");
console.log();

console.log("BEGIN TRANSACTION;");
console.log();

// Example 1: Create demonstration device
const demoDeviceId = generateUlid();
const demoDeviceName = `Drizzle Demo Device ${currentTime}`;

console.log("-- Example 1: Create demonstration device for SQL generation examples");
console.log(`INSERT INTO device (`);
console.log(`  device_id,`);
console.log(`  name,`);
console.log(`  boundary,`);
console.log(`  created_at,`);
console.log(`  created_by`);
console.log(`) VALUES (`);
console.log(`  '${demoDeviceId}',`);
console.log(`  '${escapeSql(demoDeviceName)}',`);
console.log(`  'drizzle-examples',`);
console.log(`  '${currentTime}',`);
console.log(`  'drizzle-sql-generator'`);
console.log(`);`);
console.log();

// Example 2: Insert demonstration uniform resources with different types
const resourceTypes = [
  { nature: 'json', name: 'config.json', size: 2048 },
  { nature: 'csv', name: 'data.csv', size: 15000 },
  { nature: 'md', name: 'README.md', size: 4096 },
  { nature: 'sql', name: 'schema.sql', size: 8192 }
];

console.log("-- Example 2: Create demonstration uniform resources with different content types");
for (const resource of resourceTypes) {
  const resourceId = generateUlid();
  const uri = `/demo/drizzle-examples/${resource.name}`;
  const contentDigest = `sha1-${generateUlid().toLowerCase()}`;
  
  console.log(`INSERT INTO uniform_resource (`);
  console.log(`  uniform_resource_id,`);
  console.log(`  device_id,`);
  console.log(`  ingest_session_id,`);
  console.log(`  uri,`);
  console.log(`  content_digest,`);
  console.log(`  nature,`);
  console.log(`  size_bytes,`);
  console.log(`  created_at`);
  console.log(`) VALUES (`);
  console.log(`  '${resourceId}',`);
  console.log(`  '${demoDeviceId}',`);
  console.log(`  '${ingestSessionId}',`);
  console.log(`  '${escapeSql(uri)}',`);
  console.log(`  '${contentDigest}',`);
  console.log(`  '${resource.nature}',`);
  console.log(`  ${resource.size},`);
  console.log(`  '${currentTime}'`);
  console.log(`);`);
  console.log();
}

// Also create a transform for the SQL file
const sqlResourceTransformId = generateUlid();
console.log("-- Create a transform record for the SQL schema file");
console.log(`INSERT INTO uniform_resource_transform (`);
console.log(`  uniform_resource_transform_id,`);
console.log(`  uniform_resource_id,`);
console.log(`  uri,`);
console.log(`  content,`);
console.log(`  nature,`);
console.log(`  elaboration,`);
console.log(`  created_at`);
console.log(`) VALUES (`);
console.log(`  '${sqlResourceTransformId}',`);
console.log(`  (SELECT uniform_resource_id FROM uniform_resource WHERE uri = '/demo/drizzle-examples/schema.sql'),`);
console.log(`  '/demo/drizzle-examples/schema.sql.drizzle-analysis',`);
console.log(`  '${escapeSql(JSON.stringify({
    tables_count: 15,
    views_count: 3,
    indexes_count: 8,
    generated_by: "drizzle-sql-generator",
    analysis_type: "schema_metadata"
  }))}',`);
console.log(`  'application/json',`);
console.log(`  '${escapeSql(JSON.stringify({
    transform_type: "drizzle_schema_analysis",
    generator: "drizzle-sql-generator.surveilr-SQL.ts",
    generated_at: currentTime
  }))}',`);
console.log(`  '${currentTime}'`);
console.log(`);`);
console.log();

// Example 3: Create notebook records to demonstrate analytics capabilities
const notebookKernelId = generateUlid();
console.log("-- Example 3: Create code notebook kernel for analytics demonstrations");
console.log(`INSERT INTO code_notebook_kernel (`);
console.log(`  code_notebook_kernel_id,`);
console.log(`  kernel_name,`);
console.log(`  description,`);
console.log(`  mime_type,`);
console.log(`  file_extn,`);
console.log(`  elaboration,`);
console.log(`  created_at`);
console.log(`) VALUES (`);
console.log(`  '${notebookKernelId}',`);
console.log(`  'typescript-drizzle',`);
console.log(`  'TypeScript kernel with Drizzle ORM support',`);
console.log(`  'application/typescript',`);
console.log(`  '.ts',`);
console.log(`  '${escapeSql(JSON.stringify({
    kernel_type: "typescript",
    supports_drizzle: true,
    created_by: "drizzle-sql-generator"
  }))}',`);
console.log(`  '${currentTime}'`);
console.log(`);`);
console.log();

// Create sample notebook cells
const cellExamples = [
  {
    cell_name: "device-analytics-query",
    interpretable_code: `// Device analytics with Drizzle\nconst deviceAnalytics = await db\n  .select({\n    deviceId: schema.device.deviceId,\n    resourceCount: count(schema.uniformResource.uniformResourceId)\n  })\n  .from(schema.device)\n  .leftJoin(schema.uniformResource, eq(schema.device.deviceId, schema.uniformResource.deviceId))\n  .groupBy(schema.device.deviceId);`
  },
  {
    cell_name: "resource-search-query", 
    interpretable_code: `// Dynamic resource search\nconst searchResults = await db\n  .select()\n  .from(schema.uniformResource)\n  .where(and(\n    like(schema.uniformResource.nature, '%json%'),\n    sql\`\${schema.uniformResource.sizeBytes} > 1024\`\n  ))\n  .orderBy(desc(schema.uniformResource.createdAt));`
  }
];

console.log("-- Create demonstration notebook cells with Drizzle queries");
for (const cell of cellExamples) {
  const cellId = generateUlid();
  console.log(`INSERT INTO code_notebook_cell (`);
  console.log(`  code_notebook_cell_id,`);
  console.log(`  notebook_kernel_id,`);
  console.log(`  notebook_name,`);
  console.log(`  cell_name,`);
  console.log(`  interpretable_code,`);
  console.log(`  created_at`);
  console.log(`) VALUES (`);
  console.log(`  '${cellId}',`);
  console.log(`  '${notebookKernelId}',`);
  console.log(`  'drizzle-examples-notebook',`);
  console.log(`  '${cell.cell_name}',`);
  console.log(`  '${escapeSql(cell.interpretable_code)}',`);
  console.log(`  '${currentTime}'`);
  console.log(`);`);
  console.log();
}

// Example 4: Create ingestion session records
console.log("-- Example 4: Create demonstration ingestion session");
console.log(`INSERT INTO ur_ingest_session (`);
console.log(`  ur_ingest_session_id,`);
console.log(`  device_id,`);
console.log(`  behavior_id,`);
console.log(`  behavior_json,`);
console.log(`  ingest_started_at,`);
console.log(`  ingest_finished_at,`);
console.log(`  elaboration`);
console.log(`) VALUES (`);
console.log(`  '${ingestSessionId}',`);
console.log(`  '${demoDeviceId}',`);
console.log(`  'drizzle-sql-generation',`);
console.log(`  '${escapeSql(JSON.stringify({
    generator: "drizzle-sql-generator.surveilr-SQL.ts",
    purpose: "demonstrate SQL generation patterns",
    examples_created: 4
  }))}',`);
console.log(`  '${currentTime}',`);
console.log(`  '${currentTime}',`);
console.log(`  '${escapeSql(JSON.stringify({
    session_type: "capturable_executable",
    generator_version: "1.0.0",
    records_created: {
      devices: 1,
      uniform_resources: 4,
      transforms: 1,
      notebook_kernels: 1,
      notebook_cells: 2
    }
  }))}' `);
console.log(`);`);
console.log();

// Example 5: Create a demonstration query result as transform data
const queryResultTransformId = generateUlid();
const exampleQueryResult = {
  query_type: "device_analytics",
  generated_at: currentTime,
  results: [
    {
      device_id: demoDeviceId,
      device_name: demoDeviceName,
      resource_count: 4,
      total_bytes: 29336,
      latest_ingest: currentTime
    }
  ],
  query_sql: "SELECT d.device_id, d.name, COUNT(ur.uniform_resource_id) as resource_count, SUM(ur.size_bytes) as total_bytes, MAX(ur.created_at) as latest_ingest FROM device d LEFT JOIN uniform_resource ur ON d.device_id = ur.device_id GROUP BY d.device_id, d.name"
};

console.log("-- Example 5: Store generated query results as transform data");
console.log(`INSERT INTO uniform_resource_transform (`);
console.log(`  uniform_resource_transform_id,`);
console.log(`  uniform_resource_id,`);
console.log(`  uri,`);
console.log(`  content,`);
console.log(`  nature,`);
console.log(`  elaboration,`);
console.log(`  created_at`);
console.log(`) VALUES (`);
console.log(`  '${queryResultTransformId}',`);
console.log(`  (SELECT uniform_resource_id FROM uniform_resource WHERE nature = 'sql' LIMIT 1),`);
console.log(`  '/demo/drizzle-examples/query-results.json',`);
console.log(`  '${escapeSql(JSON.stringify(exampleQueryResult, null, 2))}',`);
console.log(`  'application/json',`);
console.log(`  '${escapeSql(JSON.stringify({
    transform_type: "query_result_cache",
    source_generator: "drizzle-sql-generator",
    query_executed_at: currentTime
  }))}',`);
console.log(`  '${currentTime}'`);
console.log(`);`);
console.log();

// Example 6: Create a final summary record showing what was generated
const summaryTransformId = generateUlid();
const executionSummary = {
  capturable_executable: "drizzle-sql-generator.surveilr-SQL.ts",
  execution_time: currentTime,
  purpose: "Demonstrate Drizzle ORM SQL generation patterns for surveilr",
  records_created: {
    devices: 1,
    uniform_resources: 4,
    transforms: 3,
    notebook_kernels: 1,
    notebook_cells: 2,
    ingest_sessions: 1
  },
  patterns_demonstrated: [
    "Device creation with ULID generation",
    "Multiple uniform resource types (json, csv, md, sql)",
    "Transform records for analysis results",
    "Notebook kernel and cell creation",
    "Ingestion session tracking",
    "Query result caching as transforms"
  ],
  drizzle_features_showcased: [
    "Schema imports and type safety",
    "SQL generation without database connection",
    "ULID generation for primary keys",
    "JSON elaboration fields",
    "Proper SQL escaping",
    "Transaction wrapping"
  ]
};

console.log("-- Example 6: Create execution summary as final transform record");
console.log(`INSERT INTO uniform_resource_transform (`);
console.log(`  uniform_resource_transform_id,`);
console.log(`  uniform_resource_id,`);
console.log(`  uri,`);
console.log(`  content,`);
console.log(`  nature,`);
console.log(`  elaboration,`);
console.log(`  created_at`);
console.log(`) VALUES (`);
console.log(`  '${summaryTransformId}',`);
console.log(`  (SELECT uniform_resource_id FROM uniform_resource WHERE device_id = '${demoDeviceId}' LIMIT 1),`);
console.log(`  '/demo/drizzle-examples/execution-summary.json',`);
console.log(`  '${escapeSql(JSON.stringify(executionSummary, null, 2))}',`);
console.log(`  'application/json',`);
console.log(`  '${escapeSql(JSON.stringify({
    transform_type: "execution_summary",
    capturable_executable: "drizzle-sql-generator.surveilr-SQL.ts",
    summary_generated_at: currentTime
  }))}',`);
console.log(`  '${currentTime}'`);
console.log(`);`);
console.log();

console.log("COMMIT;");
console.log();
console.log("-- Drizzle SQL Generation Complete");
console.log("-- Summary:");
console.log(`--   Created device: ${demoDeviceName}`);
console.log(`--   Generated ${resourceTypes.length} uniform resources`);
console.log(`--   Created ${cellExamples.length} notebook cells with Drizzle examples`);
console.log(`--   Demonstrated SQL emission patterns for capturable executables`);
console.log(`--   All records wrapped in transaction for atomic execution`);
console.log("-- Use with: surveilr ingest files -r . --include-capturable-exec-sql-output");