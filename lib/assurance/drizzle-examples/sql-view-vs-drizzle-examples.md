# SQL Views vs Imperative Drizzle: Worked Examples

This document demonstrates the differences between traditional SQL views and imperative Drizzle ORM queries, showing when to use each approach in RSSD.

## Overview

**SQL Views**: Declarative, stored in database, optimized by query planner
**Drizzle Queries**: Imperative, type-safe, dynamic, built at runtime

## Example 1: Device Resource Analytics

### Traditional SQL View Approach

```sql
-- Create a view in the database
CREATE VIEW device_resource_analytics AS
SELECT 
  d.device_id,
  d.name as device_name,
  d.boundary,
  COUNT(ur.uniform_resource_id) as resource_count,
  SUM(COALESCE(ur.size_bytes, 0)) as total_bytes,
  AVG(COALESCE(ur.size_bytes, 0)) as avg_bytes,
  MIN(ur.created_at) as first_resource,
  MAX(ur.created_at) as latest_resource,
  COUNT(DISTINCT ur.nature) as content_types
FROM device d
LEFT JOIN uniform_resource ur ON d.device_id = ur.device_id
GROUP BY d.device_id, d.name, d.boundary
ORDER BY resource_count DESC;

-- Query the view
SELECT * FROM device_resource_analytics 
WHERE resource_count > 100;
```

**Pros:**
- ✅ Stored in database, available to all clients
- ✅ Query planner optimizes automatically
- ✅ Simple to use once created
- ✅ Works with any SQL client

**Cons:**
- ❌ Fixed logic, hard to customize
- ❌ No type safety
- ❌ Hard to test without database
- ❌ Schema changes break views

### Drizzle Imperative Approach

```typescript
import { eq, desc, count, sum, avg, min, max, sql } from "npm:drizzle-orm";
import * as schema from "../../std/drizzle/models.ts";

export async function getDeviceResourceAnalytics(
  db: Database,
  options: {
    minResourceCount?: number;
    devicePattern?: string;
    includeEmpty?: boolean;
    sortBy?: 'resources' | 'bytes' | 'name';
    limit?: number;
  } = {}
) {
  let query = db
    .select({
      deviceId: schema.device.deviceId,
      deviceName: schema.device.name,
      boundary: schema.device.boundary,
      resourceCount: count(schema.uniformResource.uniformResourceId),
      totalBytes: sum(schema.uniformResource.sizeBytes),
      avgBytes: avg(schema.uniformResource.sizeBytes),
      firstResource: min(schema.uniformResource.createdAt),
      latestResource: max(schema.uniformResource.createdAt),
      contentTypes: sql<number>`COUNT(DISTINCT ${schema.uniformResource.nature})`
    })
    .from(schema.device);

  // Dynamic joins based on options
  if (options.includeEmpty) {
    query = query.leftJoin(
      schema.uniformResource, 
      eq(schema.device.deviceId, schema.uniformResource.deviceId)
    );
  } else {
    query = query.innerJoin(
      schema.uniformResource, 
      eq(schema.device.deviceId, schema.uniformResource.deviceId)
    );
  }

  // Dynamic filtering
  const whereConditions = [];
  
  if (options.devicePattern) {
    whereConditions.push(like(schema.device.name, `%${options.devicePattern}%`));
  }

  if (whereConditions.length > 0) {
    query = query.where(and(...whereConditions));
  }

  // Group by
  query = query.groupBy(
    schema.device.deviceId, 
    schema.device.name, 
    schema.device.boundary
  );

  // Dynamic having clause
  if (options.minResourceCount) {
    query = query.having(
      sql`COUNT(${schema.uniformResource.uniformResourceId}) >= ${options.minResourceCount}`
    );
  }

  // Dynamic sorting
  switch (options.sortBy) {
    case 'resources':
      query = query.orderBy(desc(sql`COUNT(${schema.uniformResource.uniformResourceId})`));
      break;
    case 'bytes':
      query = query.orderBy(desc(sql`SUM(COALESCE(${schema.uniformResource.sizeBytes}, 0))`));
      break;
    case 'name':
      query = query.orderBy(schema.device.name);
      break;
    default:
      query = query.orderBy(desc(sql`COUNT(${schema.uniformResource.uniformResourceId})`));
  }

  // Dynamic limit
  if (options.limit) {
    query = query.limit(options.limit);
  }

  return await query;
}

// Usage examples with type safety
const results1 = await getDeviceResourceAnalytics(db, {
  minResourceCount: 100,
  sortBy: 'bytes',
  limit: 10
});

const results2 = await getDeviceResourceAnalytics(db, {
  devicePattern: 'production',
  includeEmpty: false
});
```

**Pros:**
- ✅ Fully type-safe with IntelliSense
- ✅ Dynamic parameters and filtering
- ✅ Composable and reusable
- ✅ Testable without database
- ✅ Runtime flexibility

**Cons:**
- ❌ More complex code
- ❌ Not available to non-TypeScript clients
- ❌ Query built at runtime (slight overhead)

## Example 2: Ingestion Session Monitoring

### SQL View Approach

```sql
CREATE VIEW ingestion_session_status AS
SELECT 
  uis.ur_ingest_session_id,
  d.name as device_name,
  uis.behavior_id,
  uis.ingest_started_at,
  uis.ingest_finished_at,
  CASE 
    WHEN uis.ingest_finished_at IS NULL THEN 'in_progress'
    WHEN uis.ingest_finished_at IS NOT NULL THEN 'completed'
  END as status,
  COALESCE(
    julianday(uis.ingest_finished_at) - julianday(uis.ingest_started_at),
    julianday('now') - julianday(uis.ingest_started_at)
  ) * 24 * 60 as duration_minutes,
  COUNT(ur.uniform_resource_id) as resources_ingested,
  SUM(COALESCE(ur.size_bytes, 0)) as total_bytes_ingested
FROM ur_ingest_session uis
INNER JOIN device d ON uis.device_id = d.device_id
LEFT JOIN uniform_resource ur ON uis.ur_ingest_session_id = ur.ingest_session_id
GROUP BY uis.ur_ingest_session_id, d.name, uis.behavior_id, 
         uis.ingest_started_at, uis.ingest_finished_at;

-- Query recent sessions
SELECT * FROM ingestion_session_status 
WHERE ingest_started_at >= datetime('now', '-24 hours')
ORDER BY ingest_started_at DESC;
```

### Drizzle Imperative Approach

```typescript
export async function getIngestSessionStatus(
  db: Database,
  filters: {
    timeRange?: 'last_hour' | 'last_day' | 'last_week' | 'all';
    status?: 'in_progress' | 'completed' | 'failed';
    deviceId?: string;
    behaviorId?: string;
    minResources?: number;
  } = {}
) {
  const baseQuery = db
    .select({
      sessionId: schema.urIngestSession.urIngestSessionId,
      deviceName: schema.device.name,
      behaviorId: schema.urIngestSession.behaviorId,
      startedAt: schema.urIngestSession.ingestStartedAt,
      finishedAt: schema.urIngestSession.ingestFinishedAt,
      status: sql<string>`
        CASE 
          WHEN ${schema.urIngestSession.ingestFinishedAt} IS NULL THEN 'in_progress'
          WHEN ${schema.urIngestSession.ingestFinishedAt} IS NOT NULL THEN 'completed'
        END
      `,
      durationMinutes: sql<number>`
        COALESCE(
          julianday(${schema.urIngestSession.ingestFinishedAt}) - julianday(${schema.urIngestSession.ingestStartedAt}),
          julianday('now') - julianday(${schema.urIngestSession.ingestStartedAt})
        ) * 24 * 60
      `,
      resourcesIngested: count(schema.uniformResource.uniformResourceId),
      totalBytesIngested: sum(schema.uniformResource.sizeBytes)
    })
    .from(schema.urIngestSession)
    .innerJoin(schema.device, eq(schema.urIngestSession.deviceId, schema.device.deviceId))
    .leftJoin(schema.uniformResource, eq(schema.urIngestSession.urIngestSessionId, schema.uniformResource.ingestSessionId));

  // Dynamic WHERE conditions
  const conditions = [];

  // Time range filtering
  switch (filters.timeRange) {
    case 'last_hour':
      conditions.push(sql`${schema.urIngestSession.ingestStartedAt} >= datetime('now', '-1 hour')`);
      break;
    case 'last_day':
      conditions.push(sql`${schema.urIngestSession.ingestStartedAt} >= datetime('now', '-1 day')`);
      break;
    case 'last_week':
      conditions.push(sql`${schema.urIngestSession.ingestStartedAt} >= datetime('now', '-7 days')`);
      break;
  }

  // Status filtering
  if (filters.status === 'in_progress') {
    conditions.push(isNull(schema.urIngestSession.ingestFinishedAt));
  } else if (filters.status === 'completed') {
    conditions.push(isNotNull(schema.urIngestSession.ingestFinishedAt));
  }

  // Device filtering
  if (filters.deviceId) {
    conditions.push(eq(schema.device.deviceId, filters.deviceId));
  }

  // Behavior filtering
  if (filters.behaviorId) {
    conditions.push(eq(schema.urIngestSession.behaviorId, filters.behaviorId));
  }

  let query = baseQuery;
  if (conditions.length > 0) {
    query = query.where(and(...conditions));
  }

  query = query.groupBy(
    schema.urIngestSession.urIngestSessionId,
    schema.device.name,
    schema.urIngestSession.behaviorId,
    schema.urIngestSession.ingestStartedAt,
    schema.urIngestSession.ingestFinishedAt
  );

  // Having clause for minimum resources
  if (filters.minResources) {
    query = query.having(
      sql`COUNT(${schema.uniformResource.uniformResourceId}) >= ${filters.minResources}`
    );
  }

  return await query.orderBy(desc(schema.urIngestSession.ingestStartedAt));
}

// Type-safe usage with different filters
const activeSessions = await getIngestSessionStatus(db, {
  status: 'in_progress',
  timeRange: 'last_day'
});

const productiveSessionsLastWeek = await getIngestSessionStatus(db, {
  timeRange: 'last_week',
  minResources: 50
});
```

## Example 3: Content Analysis Dashboard

### Hybrid Approach: Views + Drizzle

Sometimes the best approach combines both:

```sql
-- Base view for common calculations
CREATE VIEW resource_content_base AS
SELECT 
  ur.uniform_resource_id,
  ur.nature,
  ur.size_bytes,
  ur.created_at,
  d.name as device_name,
  d.boundary,
  CASE 
    WHEN ur.size_bytes < 1024 THEN 'tiny'
    WHEN ur.size_bytes < 1048576 THEN 'small'
    WHEN ur.size_bytes < 104857600 THEN 'medium'
    ELSE 'large'
  END as size_category,
  DATE(ur.created_at) as ingestion_date
FROM uniform_resource ur
INNER JOIN device d ON ur.device_id = d.device_id
WHERE ur.nature IS NOT NULL;
```

```typescript
// Drizzle queries that use the view
export async function getContentAnalytics(
  db: Database,
  analysis: 'by_type' | 'by_size' | 'by_date' | 'by_device',
  options: {
    startDate?: string;
    endDate?: string;
    contentTypes?: string[];
    sizeCategories?: string[];
    devices?: string[];
  } = {}
) {
  const baseQuery = db.select().from(sql`resource_content_base`);
  
  // Dynamic filtering using the view
  const conditions = [];
  
  if (options.startDate) {
    conditions.push(sql`ingestion_date >= ${options.startDate}`);
  }
  
  if (options.endDate) {
    conditions.push(sql`ingestion_date <= ${options.endDate}`);
  }
  
  if (options.contentTypes?.length) {
    conditions.push(sql`nature IN (${options.contentTypes.map(t => `'${t}'`).join(',')})`);
  }
  
  if (options.sizeCategories?.length) {
    conditions.push(sql`size_category IN (${options.sizeCategories.map(s => `'${s}'`).join(',')})`);
  }
  
  if (options.devices?.length) {
    conditions.push(sql`device_name IN (${options.devices.map(d => `'${d}'`).join(',')})`);
  }
  
  let query = baseQuery;
  if (conditions.length > 0) {
    query = query.where(and(...conditions));
  }
  
  // Dynamic grouping and aggregation
  switch (analysis) {
    case 'by_type':
      return await db
        .select({
          contentType: sql`nature`,
          fileCount: sql`COUNT(*)`,
          totalBytes: sql`SUM(size_bytes)`,
          avgBytes: sql`AVG(size_bytes)`
        })
        .from(sql`(${query.getSQL()})`)
        .groupBy(sql`nature`)
        .orderBy(sql`COUNT(*) DESC`);
        
    case 'by_size':
      return await db
        .select({
          sizeCategory: sql`size_category`,
          fileCount: sql`COUNT(*)`,
          totalBytes: sql`SUM(size_bytes)`
        })
        .from(sql`(${query.getSQL()})`)
        .groupBy(sql`size_category`)
        .orderBy(sql`SUM(size_bytes) DESC`);
        
    case 'by_date':
      return await db
        .select({
          date: sql`ingestion_date`,
          fileCount: sql`COUNT(*)`,
          uniqueTypes: sql`COUNT(DISTINCT nature)`,
          totalBytes: sql`SUM(size_bytes)`
        })
        .from(sql`(${query.getSQL()})`)
        .groupBy(sql`ingestion_date`)
        .orderBy(sql`ingestion_date DESC`);
        
    case 'by_device':
      return await db
        .select({
          deviceName: sql`device_name`,
          boundary: sql`boundary`,
          fileCount: sql`COUNT(*)`,
          uniqueTypes: sql`COUNT(DISTINCT nature)`,
          totalBytes: sql`SUM(size_bytes)`
        })
        .from(sql`(${query.getSQL()})`)
        .groupBy(sql`device_name, boundary`)
        .orderBy(sql`COUNT(*) DESC`);
  }
}
```

## When to Use Each Approach

### Use SQL Views When:

- ✅ **Fixed analytics**: Reports that don't change often
- ✅ **Cross-application**: Multiple tools need the same data
- ✅ **Performance critical**: Complex queries that benefit from view optimization
- ✅ **Simple filtering**: Basic WHERE clauses are sufficient
- ✅ **Database-centric**: Working primarily with SQL tools

### Use Drizzle Queries When:

- ✅ **Dynamic parameters**: Runtime filtering and sorting
- ✅ **Type safety**: Need compile-time checking
- ✅ **Testing**: Want to unit test query logic
- ✅ **Composition**: Building queries from reusable parts
- ✅ **Application-centric**: TypeScript/JavaScript ecosystem

### Use Hybrid Approach When:

- ✅ **Best of both**: Want performance AND flexibility
- ✅ **Base calculations**: Complex computations in views, dynamic filtering in Drizzle
- ✅ **Migration**: Gradually moving from views to Drizzle
- ✅ **Mixed teams**: SQL experts create views, TypeScript developers use Drizzle

## Performance Considerations

### SQL Views
```sql
-- Query planner optimizes automatically
EXPLAIN QUERY PLAN 
SELECT * FROM device_resource_analytics 
WHERE resource_count > 100;
```

### Drizzle Queries
```typescript
// Use .prepare() for repeated queries
const preparedQuery = db
  .select()
  .from(schema.device)
  .where(eq(schema.device.deviceId, placeholder("deviceId")))
  .prepare();

// Execute multiple times efficiently
const device1 = await preparedQuery.execute({ deviceId: "dev1" });
const device2 = await preparedQuery.execute({ deviceId: "dev2" });
```

## Testing Strategies

### SQL Views
```sql
-- Test with sample data
INSERT INTO device (device_id, name) VALUES ('test1', 'Test Device');
SELECT * FROM device_resource_analytics WHERE device_name = 'Test Device';
```

### Drizzle Queries
```typescript
// Unit test without database
import { createMockDatabase } from "./test-utils";

test("device analytics with filters", () => {
  const mockDb = createMockDatabase();
  const query = getDeviceResourceAnalytics(mockDb, {
    minResourceCount: 10,
    devicePattern: "test"
  });
  
  expect(query).toBeDefined();
  // Verify query structure
});
```

This demonstrates the trade-offs and appropriate use cases for SQL views versus imperative Drizzle queries in the RSSD ecosystem.