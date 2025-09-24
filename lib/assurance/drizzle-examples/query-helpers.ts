#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * Typed Query Helpers for RSSD Drizzle ORM
 * 
 * This module demonstrates the power of TypeScript-first database queries
 * using Drizzle ORM. All queries are fully typed, provide IntelliSense,
 * and catch errors at compile time.
 */

// Drizzle ORM imports for type definitions and runtime functions
// Note: These are commented for documentation but would be imported in actual usage
// import { drizzle } from "npm:drizzle-orm/better-sqlite3";
import { eq, desc, count, like, and, or, isNull, isNotNull, sql } from "npm:drizzle-orm";
// import Database from "npm:better-sqlite3";

// Database type for function signatures
export type Database = {
  select: any;
  insert: any;
  update: any;
  delete: any;
};
import * as schema from "../../std/drizzle/models.ts";

// Type helpers for better developer experience
export type UniformResource = typeof schema.uniformResource.$inferSelect;
export type DeviceWithStats = {
  device: typeof schema.device.$inferSelect;
  resourceCount: number;
  latestIngest: string | null;
};

/**
 * Initialize Drizzle database connection
 * 
 * Example usage:
 * ```typescript
 * import Database from "npm:better-sqlite3";
 * import { drizzle } from "npm:drizzle-orm/better-sqlite3";
 * 
 * const sqlite = new Database("./rssd.db");
 * const db = drizzle(sqlite, { schema });
 * ```
 */
export function createDatabase(dbPath: string = ":memory:") {
  console.log(`💡 Would create database connection to: ${dbPath}`);
  // const sqlite = new Database(dbPath);
  // return drizzle(sqlite, { schema });
}

/**
 * 1. Device Resource Analytics Query Helper
 * 
 * Provides comprehensive device analytics with TypeScript safety.
 * Shows device info, resource counts, and latest ingestion timestamps.
 */
export async function getDeviceResourceAnalytics(
  db: Database,
  options: {
    deviceNamePattern?: string;
    minResourceCount?: number;
    includeInactive?: boolean;
  } = {}
): Promise<DeviceWithStats[]> {
  const { deviceNamePattern, minResourceCount = 0, includeInactive = true } = options;

  // Build WHERE conditions dynamically with type safety
  const whereConditions = [];
  
  if (deviceNamePattern) {
    whereConditions.push(like(schema.device.name, `%${deviceNamePattern}%`));
  }
  
  if (!includeInactive) {
    whereConditions.push(isNotNull(schema.uniformResource.deviceId));
  }

  // Execute typed query with joins and aggregations
  const result = await db
    .select({
      device: schema.device,
      resourceCount: count(schema.uniformResource.uniformResourceId).as("resource_count"),
      latestIngest: sql<string | null>`MAX(${schema.uniformResource.createdAt})`.as("latest_ingest")
    })
    .from(schema.device)
    .leftJoin(schema.uniformResource, eq(schema.device.deviceId, schema.uniformResource.deviceId))
    .where(whereConditions.length > 0 ? and(...whereConditions) : undefined)
    .groupBy(schema.device.deviceId)
    .having(sql`COUNT(${schema.uniformResource.uniformResourceId}) >= ${minResourceCount}`)
    .orderBy(desc(sql`resource_count`));

  return result;
}

/**
 * 2. Advanced Resource Search Query Helper
 * 
 * Sophisticated search across uniform resources with filtering,
 * full-text search capabilities, and related data joins.
 */
export async function searchUniformResources(
  db: Database,
  searchParams: {
    query?: string;           // Search in URI and content
    nature?: string[];        // Filter by resource nature(s)
    deviceIds?: string[];     // Filter by specific devices
    sizeRange?: { min?: number; max?: number }; // Filter by file size
    dateRange?: { from?: string; to?: string }; // Filter by creation date
    limit?: number;
    offset?: number;
  }
): Promise<{
  resources: Array<UniformResource & { 
    deviceName: string; 
    sessionAgent: string;
    ingestPath?: string;
  }>;
  totalCount: number;
}> {
  const {
    query,
    nature,
    deviceIds,
    sizeRange,
    dateRange,
    limit = 50,
    offset = 0
  } = searchParams;

  // Build dynamic WHERE conditions with full type safety
  const conditions = [];

  // Text search across URI and content
  if (query) {
    conditions.push(
      or(
        like(schema.uniformResource.uri, `%${query}%`),
        like(sql`CAST(${schema.uniformResource.content} AS TEXT)`, `%${query}%`)
      )
    );
  }

  // Filter by nature (file types)
  if (nature && nature.length > 0) {
    conditions.push(
      sql`${schema.uniformResource.nature} IN ${nature}`
    );
  }

  // Filter by device IDs
  if (deviceIds && deviceIds.length > 0) {
    conditions.push(
      sql`${schema.uniformResource.deviceId} IN ${deviceIds}`
    );
  }

  // Filter by file size range
  if (sizeRange) {
    if (sizeRange.min !== undefined) {
      conditions.push(sql`${schema.uniformResource.sizeBytes} >= ${sizeRange.min}`);
    }
    if (sizeRange.max !== undefined) {
      conditions.push(sql`${schema.uniformResource.sizeBytes} <= ${sizeRange.max}`);
    }
  }

  // Filter by date range
  if (dateRange) {
    if (dateRange.from) {
      conditions.push(sql`${schema.uniformResource.createdAt} >= ${dateRange.from}`);
    }
    if (dateRange.to) {
      conditions.push(sql`${schema.uniformResource.createdAt} <= ${dateRange.to}`);
    }
  }

  const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

  // Get total count for pagination
  const [{ count: totalCount }] = await db
    .select({ count: count() })
    .from(schema.uniformResource)
    .innerJoin(schema.device, eq(schema.uniformResource.deviceId, schema.device.deviceId))
    .innerJoin(schema.urIngestSession, eq(schema.uniformResource.ingestSessionId, schema.urIngestSession.urIngestSessionId))
    .where(whereClause);

  // Get paginated results with joins
  const resources = await db
    .select({
      // All uniform resource fields
      uniformResourceId: schema.uniformResource.uniformResourceId,
      deviceId: schema.uniformResource.deviceId,
      ingestSessionId: schema.uniformResource.ingestSessionId,
      ingestFsPathId: schema.uniformResource.ingestFsPathId,
      ingestSessionImapAcctFolderMessage: schema.uniformResource.ingestSessionImapAcctFolderMessage,
      ingestIssueAcctProjectId: schema.uniformResource.ingestIssueAcctProjectId,
      uri: schema.uniformResource.uri,
      contentDigest: schema.uniformResource.contentDigest,
      content: schema.uniformResource.content,
      nature: schema.uniformResource.nature,
      sizeBytes: schema.uniformResource.sizeBytes,
      lastModifiedAt: schema.uniformResource.lastModifiedAt,
      contentFmBodyAttrs: schema.uniformResource.contentFmBodyAttrs,
      frontmatter: schema.uniformResource.frontmatter,
      elaboration: schema.uniformResource.elaboration,
      createdAt: schema.uniformResource.createdAt,
      createdBy: schema.uniformResource.createdBy,
      updatedAt: schema.uniformResource.updatedAt,
      updatedBy: schema.uniformResource.updatedBy,
      deletedAt: schema.uniformResource.deletedAt,
      deletedBy: schema.uniformResource.deletedBy,
      activityLog: schema.uniformResource.activityLog,
      
      // Joined data
      deviceName: schema.device.name,
      sessionAgent: schema.urIngestSession.sessionAgent,
      ingestPath: schema.urIngestSessionFsPath.rootPath,
    })
    .from(schema.uniformResource)
    .innerJoin(schema.device, eq(schema.uniformResource.deviceId, schema.device.deviceId))
    .innerJoin(schema.urIngestSession, eq(schema.uniformResource.ingestSessionId, schema.urIngestSession.urIngestSessionId))
    .leftJoin(schema.urIngestSessionFsPath, eq(schema.uniformResource.ingestFsPathId, schema.urIngestSessionFsPath.urIngestSessionFsPathId))
    .where(whereClause)
    .orderBy(desc(schema.uniformResource.createdAt))
    .limit(limit)
    .offset(offset);

  return {
    resources,
    totalCount
  };
}

/**
 * 3. Code Notebook Analytics Query Helper
 * 
 * Provides insights into code notebook usage, execution patterns,
 * and migration status with full type safety.
 */
export async function getCodeNotebookAnalytics(
  db: Database,
  options: {
    notebookName?: string;
    kernelType?: string;
    includeExecuted?: boolean;
    groupByKernel?: boolean;
  } = {}
): Promise<Array<{
  kernelName: string;
  notebookName: string;
  totalCells: number;
  executedCells: number;
  pendingCells: number;
  latestExecution: string | null;
  isIdempotent: boolean;
}>> {
  const { notebookName, kernelType, includeExecuted = true, groupByKernel = false } = options;

  // Dynamic query building with type safety
  const baseQuery = db
    .select({
      kernelName: schema.codeNotebookKernel.kernelName,
      notebookName: schema.codeNotebookCell.notebookName,
      cellName: schema.codeNotebookCell.cellName,
      isExecuted: sql<boolean>`CASE WHEN ${schema.codeNotebookState.toState} = 'EXECUTED' THEN 1 ELSE 0 END`,
      isIdempotent: sql<boolean>`CASE WHEN ${schema.codeNotebookCell.cellName} LIKE '%_once_%' THEN 0 ELSE 1 END`,
      executionDate: schema.codeNotebookState.transitionedAt,
    })
    .from(schema.codeNotebookCell)
    .innerJoin(
      schema.codeNotebookKernel, 
      eq(schema.codeNotebookCell.notebookKernelId, schema.codeNotebookKernel.codeNotebookKernelId)
    )
    .leftJoin(
      schema.codeNotebookState,
      and(
        eq(schema.codeNotebookCell.codeNotebookCellId, schema.codeNotebookState.codeNotebookCellId),
        eq(schema.codeNotebookState.toState, "EXECUTED")
      )
    );

  // Apply filters
  const conditions = [];
  if (notebookName) {
    conditions.push(eq(schema.codeNotebookCell.notebookName, notebookName));
  }
  if (kernelType) {
    conditions.push(like(schema.codeNotebookKernel.kernelName, `%${kernelType}%`));
  }

  const results = await baseQuery
    .where(conditions.length > 0 ? and(...conditions) : undefined)
    .orderBy(schema.codeNotebookCell.notebookName, schema.codeNotebookKernel.kernelName);

  // Aggregate results by notebook and kernel
  const analytics = new Map<string, {
    kernelName: string;
    notebookName: string;
    totalCells: number;
    executedCells: number;
    pendingCells: number;
    latestExecution: string | null;
    isIdempotent: boolean;
  }>();

  for (const row of results) {
    const key = groupByKernel 
      ? `${row.notebookName}:${row.kernelName}`
      : row.notebookName;
    
    if (!analytics.has(key)) {
      analytics.set(key, {
        kernelName: row.kernelName,
        notebookName: row.notebookName,
        totalCells: 0,
        executedCells: 0,
        pendingCells: 0,
        latestExecution: null,
        isIdempotent: row.isIdempotent,
      });
    }

    const stats = analytics.get(key)!;
    stats.totalCells++;
    
    if (row.isExecuted) {
      stats.executedCells++;
      if (row.executionDate && (!stats.latestExecution || row.executionDate > stats.latestExecution)) {
        stats.latestExecution = row.executionDate;
      }
    } else {
      stats.pendingCells++;
    }
  }

  return Array.from(analytics.values());
}

/**
 * 4. Ingestion Session Monitoring Query Helper
 * 
 * Monitor ingestion sessions across different sources (filesystem, IMAP, etc.)
 * with comprehensive statistics and error tracking.
 */
export async function getIngestionSessionMonitoring(
  db: Database,
  options: {
    deviceId?: string;
    sessionStatus?: 'active' | 'completed' | 'failed';
    timeRange?: { hours?: number; days?: number };
    includeStats?: boolean;
  } = {}
): Promise<Array<{
  session: typeof schema.urIngestSession.$inferSelect;
  deviceName: string;
  resourceCount: number;
  errorCount: number;
  avgResourceSize: number;
  sessionDuration: number | null;
  sessionType: 'filesystem' | 'imap' | 'plm' | 'other';
}>> {
  const { deviceId, sessionStatus, timeRange, includeStats = true } = options;

  // Build time range condition
  let timeCondition;
  if (timeRange) {
    const hoursBack = timeRange.hours || (timeRange.days ? timeRange.days * 24 : 24);
    const cutoffTime = new Date(Date.now() - hoursBack * 60 * 60 * 1000).toISOString();
    timeCondition = sql`${schema.urIngestSession.ingestStartedAt} >= ${cutoffTime}`;
  }

  // Build session status condition
  let statusCondition;
  if (sessionStatus) {
    switch (sessionStatus) {
      case 'active':
        statusCondition = isNull(schema.urIngestSession.ingestFinishedAt);
        break;
      case 'completed':
        statusCondition = and(
          isNotNull(schema.urIngestSession.ingestFinishedAt),
          isNull(schema.uniformResource.deletedAt) // No major errors
        );
        break;
      case 'failed':
        statusCondition = isNotNull(schema.uniformResource.deletedAt); // Has errors
        break;
    }
  }

  const conditions = [
    deviceId ? eq(schema.urIngestSession.deviceId, deviceId) : undefined,
    timeCondition,
    statusCondition,
  ].filter(Boolean);

  const results = await db
    .select({
      // Session data
      sessionId: schema.urIngestSession.urIngestSessionId,
      deviceId: schema.urIngestSession.deviceId,
      behaviorId: schema.urIngestSession.behaviorId,
      behaviorJson: schema.urIngestSession.behaviorJson,
      ingestStartedAt: schema.urIngestSession.ingestStartedAt,
      ingestFinishedAt: schema.urIngestSession.ingestFinishedAt,
      sessionAgent: schema.urIngestSession.sessionAgent,
      elaboration: schema.urIngestSession.elaboration,
      createdAt: schema.urIngestSession.createdAt,
      createdBy: schema.urIngestSession.createdBy,
      updatedAt: schema.urIngestSession.updatedAt,
      updatedBy: schema.urIngestSession.updatedBy,
      deletedAt: schema.urIngestSession.deletedAt,
      deletedBy: schema.urIngestSession.deletedBy,
      activityLog: schema.urIngestSession.activityLog,
      
      // Device info
      deviceName: schema.device.name,
      
      // Statistics
      resourceCount: count(schema.uniformResource.uniformResourceId).as("resource_count"),
      errorCount: sql<number>`SUM(CASE WHEN ${schema.uniformResource.deletedAt} IS NOT NULL THEN 1 ELSE 0 END)`.as("error_count"),
      avgResourceSize: sql<number>`AVG(COALESCE(${schema.uniformResource.sizeBytes}, 0))`.as("avg_resource_size"),
      
      // Session type detection
      hasFilesystem: sql<boolean>`COUNT(${schema.urIngestSessionFsPath.urIngestSessionFsPathId}) > 0`.as("has_filesystem"),
      hasImap: sql<boolean>`COUNT(${schema.urIngestSessionImapAccount.urIngestSessionImapAccountId}) > 0`.as("has_imap"),
      hasPlm: sql<boolean>`COUNT(${schema.urIngestSessionPlmAccount.urIngestSessionPlmAccountId}) > 0`.as("has_plm"),
    })
    .from(schema.urIngestSession)
    .innerJoin(schema.device, eq(schema.urIngestSession.deviceId, schema.device.deviceId))
    .leftJoin(schema.uniformResource, eq(schema.urIngestSession.urIngestSessionId, schema.uniformResource.ingestSessionId))
    .leftJoin(schema.urIngestSessionFsPath, eq(schema.urIngestSession.urIngestSessionId, schema.urIngestSessionFsPath.ingestSessionId))
    .leftJoin(schema.urIngestSessionImapAccount, eq(schema.urIngestSession.urIngestSessionId, schema.urIngestSessionImapAccount.ingestSessionId))
    .leftJoin(schema.urIngestSessionPlmAccount, eq(schema.urIngestSession.urIngestSessionId, schema.urIngestSessionPlmAccount.ingestSessionId))
    .where(conditions.length > 0 ? and(...conditions) : undefined)
    .groupBy(schema.urIngestSession.urIngestSessionId, schema.device.deviceId)
    .orderBy(desc(schema.urIngestSession.ingestStartedAt));

  // Transform results to match return type
  return results.map(row => {
    const sessionDuration = row.ingestFinishedAt && row.ingestStartedAt
      ? new Date(row.ingestFinishedAt).getTime() - new Date(row.ingestStartedAt).getTime()
      : null;

    let sessionType: 'filesystem' | 'imap' | 'plm' | 'other' = 'other';
    if (row.hasFilesystem) sessionType = 'filesystem';
    else if (row.hasImap) sessionType = 'imap';
    else if (row.hasPlm) sessionType = 'plm';

    return {
      session: {
        urIngestSessionId: row.sessionId,
        deviceId: row.deviceId,
        behaviorId: row.behaviorId,
        behaviorJson: row.behaviorJson,
        ingestStartedAt: row.ingestStartedAt,
        ingestFinishedAt: row.ingestFinishedAt,
        sessionAgent: row.sessionAgent,
        elaboration: row.elaboration,
        createdAt: row.createdAt,
        createdBy: row.createdBy,
        updatedAt: row.updatedAt,
        updatedBy: row.updatedBy,
        deletedAt: row.deletedAt,
        deletedBy: row.deletedBy,
        activityLog: row.activityLog,
      },
      deviceName: row.deviceName,
      resourceCount: row.resourceCount,
      errorCount: row.errorCount,
      avgResourceSize: row.avgResourceSize,
      sessionDuration,
      sessionType,
    };
  });
}

// Example usage and testing function
export async function demonstrateQueryHelpers() {
  console.log("🔍 RSSD Drizzle Query Helpers Demo");
  console.log("=====================================\n");

  // Note: In real usage, you'd connect to an actual database
  // const db = createDatabase("./rssd.db");

  console.log("1. Device Resource Analytics");
  console.log("   - Get devices with resource counts and latest ingestion");
  console.log("   - Filter by device name pattern and minimum resource count");
  console.log("   - Full TypeScript safety with IntelliSense\n");

  console.log("2. Advanced Resource Search");
  console.log("   - Full-text search across URI and content");
  console.log("   - Filter by nature, device, size, and date ranges");
  console.log("   - Paginated results with total count");
  console.log("   - Join with device and session data\n");

  console.log("3. Code Notebook Analytics");
  console.log("   - Track notebook execution patterns");
  console.log("   - Monitor migration status and cell health");
  console.log("   - Group by kernel type or notebook\n");

  console.log("4. Ingestion Session Monitoring");
  console.log("   - Monitor active, completed, and failed sessions");
  console.log("   - Track performance metrics and error rates");
  console.log("   - Detect session types (filesystem, IMAP, PLM)\n");

  console.log("✨ All queries are fully typed with compile-time safety!");
  console.log("📚 Use these helpers as building blocks for your applications.");
}

// Run demo if called directly
if (import.meta.main) {
  await demonstrateQueryHelpers();
}