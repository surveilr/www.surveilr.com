# Quickstart: Writing Capturable Executables with Typed SQL

This guide shows how to create capturable executables that generate SQL using Drizzle ORM with full TypeScript safety. Perfect for building dynamic SQL generation tools, migration scripts, and data transformation pipelines.

## What are Capturable Executables?

Capturable executables are scripts that:
- Follow the `[description].surveilr-SQL.[extension]` naming convention
- Output SQL that can be captured and executed by surveilr
- Emit SQL with proper transaction wrappers (BEGIN/COMMIT)
- Can be written in Python, TypeScript/Deno, or Node.js
- Generate type-safe SQL using Drizzle ORM

## Quick Examples

### 1. Deno + Drizzle SQL Generator

```typescript
#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * device-analytics.surveilr-SQL.ts - Generate analytics SQL using Drizzle
 */

import { eq, desc, count, like, sql } from "npm:drizzle-orm";
import * as schema from "../../std/drizzle/models.ts";

// Generate ULID for records
function generateUlid() {
  const timestamp = Date.now().toString().slice(-8);
  const randomPart = Array.from({ length: 18 }, () => 
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Math.floor(Math.random() * 36)]
  ).join('');
  return `${timestamp}${randomPart}`;
}

console.log("BEGIN TRANSACTION;");
console.log();

console.log("-- Device Analytics Query");
console.log("SELECT");
console.log("  d.device_id,");
console.log("  d.name as device_name,");
console.log("  COUNT(ur.uniform_resource_id) as resource_count");
console.log("FROM device d");
console.log("LEFT JOIN uniform_resource ur ON d.device_id = ur.device_id");
console.log("GROUP BY d.device_id, d.name");
console.log("ORDER BY resource_count DESC;");
console.log();

console.log("COMMIT;");
```

### 2. Node.js + better-sqlite3

```javascript
#!/usr/bin/env node

/**
 * performance-analytics.surveilr-SQL.cjs - Performance analytics with better-sqlite3
 */

const Database = require('better-sqlite3');

const db = new Database(process.env.RSSD_DB_PATH || './rssd.db');

// Generate optimized query
console.log("-- High-Performance Device Query");
const stmt = db.prepare(`
  SELECT device_id, name, COUNT(*) as resources
  FROM device d
  LEFT JOIN uniform_resource ur USING(device_id)
  GROUP BY device_id, name
  ORDER BY resources DESC
`);

console.log(stmt.source);
db.close();
```

### 3. Python + SQL Generation

```python
#!/usr/bin/env python3

"""
surveilr[python-transform] - Data transformation SQL generator
"""

import sys
from datetime import datetime

def generate_transform_sql():
    print("-- Data Transformation Query")
    print(f"-- Generated at: {datetime.now().isoformat()}")
    print("SELECT")
    print("  uri,")
    print("  nature,")
    print("  CASE")
    print("    WHEN size_bytes < 1024 THEN 'small'")
    print("    WHEN size_bytes < 1048576 THEN 'medium'")
    print("    ELSE 'large'")
    print("  END as size_category")
    print("FROM uniform_resource")
    print("WHERE nature IS NOT NULL;")

if __name__ == "__main__":
    generate_transform_sql()
```

## File Naming Convention

Use the `surveilr[type]` pattern:

- `surveilr[deno-analytics].ts` - Deno-based analytics
- `surveilr[node-reporting].js` - Node.js reporting
- `surveilr[python-etl].py` - Python ETL operations
- `surveilr[sql-migration].sql` - Pure SQL migrations

## Using Drizzle for Type-Safe SQL Generation

### Schema Import

```typescript
// Import your Drizzle schema
import * as schema from "../../std/drizzle/models.ts";
import { eq, desc, count, like, and, sql } from "npm:drizzle-orm";
```

### Type-Safe Query Building

```typescript
// Type-safe device analytics
const deviceAnalytics = {
  deviceId: schema.device.deviceId,
  deviceName: schema.device.name,
  resourceCount: count(schema.uniformResource.uniformResourceId),
  latestIngest: sql`MAX(${schema.uniformResource.createdAt})`
};

// Generate SQL string
console.log("SELECT");
console.log("  device_id,");
console.log("  name as device_name,");
console.log("  COUNT(uniform_resource_id) as resource_count,");
console.log("  MAX(created_at) as latest_ingest");
console.log("FROM device d");
console.log("LEFT JOIN uniform_resource ur ON d.device_id = ur.device_id");
console.log("GROUP BY d.device_id, d.name;");
```

### Dynamic Query Generation

```typescript
function generateFilteredQuery(filters: {
  devicePattern?: string;
  minResources?: number;
  contentType?: string;
}) {
  const conditions: string[] = [];
  
  if (filters.devicePattern) {
    conditions.push(`d.name LIKE '%${filters.devicePattern}%'`);
  }
  
  if (filters.minResources) {
    conditions.push(`COUNT(ur.uniform_resource_id) >= ${filters.minResources}`);
  }
  
  if (filters.contentType) {
    conditions.push(`ur.nature = '${filters.contentType}'`);
  }
  
  console.log("SELECT d.device_id, d.name, COUNT(*) as resources");
  console.log("FROM device d");
  console.log("LEFT JOIN uniform_resource ur ON d.device_id = ur.device_id");
  
  if (conditions.length > 0) {
    console.log("WHERE " + conditions.join(" AND "));
  }
  
  console.log("GROUP BY d.device_id, d.name;");
}
```

## Connection Patterns

### 1. SQL Generation Only (No Database)

Perfect for creating migration scripts or SQL templates:

```typescript
// Mock database for SQL generation
const mockDb = {
  select: () => ({ from: () => ({ toSQL: () => ({ sql: "" }) }) })
} as any;

// Use Drizzle query builder to generate SQL structure
const query = mockDb.select({...}).from(schema.device);
// Output the generated SQL
```

### 2. Live Database Connection

For real-time analytics and operations:

```typescript
import { drizzle } from "npm:drizzle-orm/better-sqlite3";
import Database from "npm:better-sqlite3";

const sqlite = new Database(Deno.env.get("RSSD_DB_PATH") || "./rssd.db");
const db = drizzle(sqlite, { schema });

// Execute queries and output results as SQL
const devices = await db.select().from(schema.device);
devices.forEach(device => {
  console.log(`-- Device: ${device.name}`);
});
```

### 3. Remote/Edge Connections

Using libsql for remote databases:

```typescript
import { createClient } from "npm:@libsql/client";
import { drizzle } from "npm:drizzle-orm/libsql";

const client = createClient({
  url: Deno.env.get("LIBSQL_URL") || "file:./rssd.db",
  authToken: Deno.env.get("LIBSQL_AUTH_TOKEN")
});

const db = drizzle(client);
// Execute remote queries
```

## Best Practices

### 1. Error Handling

```typescript
try {
  // Database operations
  const results = await db.select().from(schema.device);
  // Output SQL
} catch (error) {
  console.log(`-- Error: ${error.message}`);
  console.log("SELECT 'ERROR' as status;");
}
```

### 2. Environment Configuration

```typescript
const config = {
  dbPath: Deno.env.get("RSSD_DB_PATH") || "./rssd.db",
  verbose: Deno.env.get("RSSD_VERBOSE") === "true",
  timeout: parseInt(Deno.env.get("RSSD_TIMEOUT") || "30000")
};
```

### 3. Output Formatting

```typescript
// Always start with comments
console.log("-- Generated SQL for device analytics");
console.log(`-- Execution ID: ${Date.now()}`);
console.log(`-- Timestamp: ${new Date().toISOString()}`);
console.log();

// Format SQL for readability
console.log("SELECT");
console.log("  device_id,");
console.log("  name,");
console.log("  created_at");
console.log("FROM device");
console.log("ORDER BY created_at DESC;");
```

### 4. Type Safety

```typescript
// Use Drizzle's type inference
type Device = typeof schema.device.$inferSelect;
type NewDevice = typeof schema.device.$inferInsert;

// Type-safe functions
function createDeviceInsert(device: NewDevice): string {
  return `INSERT INTO device (device_id, name, boundary) VALUES ('${device.deviceId}', '${device.name}', '${device.boundary}');`;
}
```

## Integration with surveilr

### Running Capturable Executables

```bash
# Direct execution
deno run -A surveilr[deno-analytics].ts

# Via surveilr ingestion
surveilr ingest files -r . --include-capturable-exec-sql-output

# With environment variables
RSSD_DB_PATH=./production.db deno run -A surveilr[deno-analytics].ts
```

### Capturing Output

The generated SQL can be:
- Piped to SQLite: `deno run -A script.ts | sqlite3 database.db`
- Saved to file: `deno run -A script.ts > migration.sql`
- Executed by surveilr: `surveilr exec sql < generated.sql`

## Example Use Cases

1. **Data Migration**: Generate SQL to transform data between schema versions
2. **Analytics Reports**: Create dynamic queries based on runtime parameters
3. **ETL Pipelines**: Transform data with type-safe SQL generation
4. **Schema Validation**: Compare expected vs actual database structure
5. **Performance Testing**: Generate load testing queries
6. **Data Auditing**: Create compliance and audit trail queries

## Next Steps

1. Study the example capturable executables in `lib/assurance/examples/`
2. Create your own using the patterns above
3. Test with different database connections (local, remote, edge)
4. Integrate with your surveilr workflows

For more examples and advanced patterns, see:
- `surveilr[deno-drizzle-generator].ts` - SQL generation without database
- `surveilr[deno-drizzle-direct].ts` - Live database operations
- `surveilr[node-better-sqlite3].js` - High-performance local operations
- `surveilr[node-libsql].js` - Remote/edge database operations