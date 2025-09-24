#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * Drizzle-based Orchestration SQLPages
 * 
 * Recreates the orchestration web UI content using Drizzle decorators instead of SQLa
 */

import { DrizzleSqlPageNotebook, navigationPrimeDrizzle } from "../notebook-drizzle/drizzle-sqlpage.ts";
import { inlinedSQL, SQL } from "../../universal/sql-text.ts";

export class DrizzleOrchestrationSqlPages extends DrizzleSqlPageNotebook {
  constructor() {
    super("orchestration");
  }

  // Orchestration views are now defined in ../../universal/views.ts using Drizzle query builder
  // This ensures consistency and type safety across the system
  supportDDL(): string {
    return inlinedSQL(SQL`-- Orchestration views are now defined in ../../universal/views.ts
-- Views will be created automatically by Drizzle ORM schema introspection
-- This ensures consistency between TypeScript definitions and SQL implementation

-- All orchestration views have been moved to ../../universal/views.ts:
-- - orchestration_session_by_device
-- - orchestration_session_duration
-- - orchestration_success_rate
-- - orchestration_session_script
-- - orchestration_executions_by_type
-- - orchestration_execution_success_rate_by_type
-- - orchestration_session_summary
-- - orchestration_issue_remediation
-- - orchestration_logs_by_session`);
  }

  @navigationPrimeDrizzle({
    caption: "Orchestration",
    description: "View orchestration sessions and performance metrics",
    siblingOrder: 2,
  })
  "orchestration/index.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'Orchestration Sessions' as contents;
    
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT 
        orchestration_session_id AS "Session ID",
        orchestration_nature AS "Nature",
        orch_started_at AS "Started At",
        orch_finished_at AS "Finished At",
        duration_days AS "Duration (Days)"
    FROM orchestration_session_duration
    ORDER BY orch_started_at DESC;

    SELECT 'title' AS component, 'Success Rates by Nature' as contents, 2 as level;
    SELECT 'table' AS component;
    SELECT 
        orchestration_nature AS "Orchestration Nature",
        total_sessions AS "Total Sessions",
        successful_sessions AS "Successful",
        success_rate_percentage || '%' AS "Success Rate"
    FROM orchestration_success_rate;`);
  }

  "orchestration/info-schema.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'Orchestration Information Schema' as contents;
    
    SELECT 'text' AS component,
    'This page provides detailed schema information for orchestration-related tables.' AS contents_md;

    SELECT 'title' AS component, 'Sessions by Device' as contents, 2 as level;
    SELECT 'table' AS component;
    SELECT 
        device_name AS "Device Name",
        total_sessions AS "Total Sessions", 
        completed_sessions AS "Completed",
        failed_sessions AS "Failed"
    FROM orchestration_session_by_device;`);
  }
}