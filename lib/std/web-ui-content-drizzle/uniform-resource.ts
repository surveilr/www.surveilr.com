#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * Drizzle-based Uniform Resource SQLPages
 * 
 * Recreates the uniform resource web UI content using Drizzle decorators instead of SQLa
 */

import { DrizzleSqlPageNotebook, navigationPrimeDrizzle } from "../notebook-drizzle/drizzle-sqlpage.ts";
import { inlinedSQL, SQL } from "../../universal/sql-text.ts";

export class DrizzleUniformResourceSqlPages extends DrizzleSqlPageNotebook {
  constructor() {
    super("ur");
  }

  // Uniform Resource views are now defined in ../../universal/views.ts using Drizzle query builder
  // This ensures consistency and type safety across the system  
  supportDDL(): string {
    return inlinedSQL(SQL`-- Uniform Resource views are now defined in ../../universal/views.ts
-- Views will be created automatically by Drizzle ORM schema introspection
-- This ensures consistency between TypeScript definitions and SQL implementation

-- All uniform resource views have been moved to ../../universal/views.ts:
-- - uniform_resource_file
-- - uniform_resource_imap
-- - uniform_resource_imap_content  
-- - ur_ingest_session_files_stats
-- - ur_ingest_session_files_stats_latest
-- - ur_ingest_session_tasks_stats
-- - ur_ingest_session_tasks_stats_latest
-- - ur_ingest_session_file_issue`);
  }

  @navigationPrimeDrizzle({
    caption: "Uniform Resources",
    abbreviatedCaption: "UR",
    description: "Explore ingested uniform resources",
    siblingOrder: 3,
  })
  "ur/index.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'Uniform Resources Overview' as contents;
    
    SELECT 'card' AS component;
    SELECT 
        'File Resources' AS title,
        'Browse ingested files and their metadata' AS description,
        '/ur/uniform-resource-files.sql' AS link;
    SELECT 
        'IMAP Resources' AS title,
        'Browse ingested IMAP email accounts and messages' AS description,
        '/ur/uniform-resource-imap-account.sql' AS link;
    
    SELECT 'title' AS component, 'Recent Uniform Resources' as contents, 2 as level;
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT 
        uniform_resource_id AS "Resource ID",
        nature AS "Nature",
        uri AS "URI",
        size_bytes AS "Size (Bytes)",
        created_at AS "Created At"
    FROM uniform_resource
    ORDER BY created_at DESC
    LIMIT 100;`);
  }

  "ur/info-schema.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'Uniform Resource Information Schema' as contents;
    
    SELECT 'text' AS component,
    'This page provides detailed schema information for uniform resource tables and their relationships.' AS contents_md;

    SELECT 'title' AS component, 'Uniform Resource Statistics' as contents, 2 as level;
    SELECT 'table' AS component;
    SELECT 
        nature AS "Resource Nature",
        COUNT(*) AS "Count",
        AVG(size_bytes) AS "Average Size (Bytes)",
        SUM(size_bytes) AS "Total Size (Bytes)"
    FROM uniform_resource
    GROUP BY nature
    ORDER BY COUNT(*) DESC;`);
  }

  "ur/uniform-resource-files.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'File Uniform Resources' as contents;
    
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT 
        uniform_resource_id AS "Resource ID",
        nature AS "Nature",
        source_path AS "Source Path",
        file_path_rel AS "File Path",
        size_bytes AS "Size (Bytes)"
    FROM uniform_resource_file
    ORDER BY uniform_resource_id DESC;`);
  }

  "ur/uniform-resource-imap-account.sql"() {
    return inlinedSQL(SQL`SELECT 'title' AS component, 'IMAP Account Resources' as contents;
    
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT 
        ur_ingest_session_imap_account_id AS "Account ID",
        email AS "Email Address",
        '[Folders](/ur/uniform-resource-imap-folder.sql?account_id=' || ur_ingest_session_imap_account_id || ')' AS "View Folders"
    FROM uniform_resource_imap
    GROUP BY ur_ingest_session_imap_account_id, email
    ORDER BY email;`);
  }

  "ur/uniform-resource-imap-folder.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Uniform Resources' as title, '/ur/index.sql' as link;
    SELECT 'IMAP Accounts' as title, '/ur/uniform-resource-imap-account.sql' as link;
    SELECT 'Folder: ' || $folder_name as title;

    SELECT 'title' AS component, 'IMAP Folder: ' || COALESCE($folder_name, 'All Folders') as contents;
    
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT 
        ur_ingest_session_imap_acct_folder_id AS "Folder ID",
        email AS "Email Account",
        folder_name AS "Folder Name",
        '[Messages](/ur/uniform-resource-imap-mail-list.sql?folder_id=' || ur_ingest_session_imap_acct_folder_id || ')' AS "View Messages"
    FROM uniform_resource_imap
    WHERE ($account_id IS NULL OR ur_ingest_session_imap_account_id = $account_id)
      AND ($folder_name IS NULL OR folder_name = $folder_name)
    GROUP BY ur_ingest_session_imap_acct_folder_id, email, folder_name
    ORDER BY email, folder_name;`);
  }

  "ur/uniform-resource-imap-mail-list.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Uniform Resources' as title, '/ur/index.sql' as link;
    SELECT 'IMAP Accounts' as title, '/ur/uniform-resource-imap-account.sql' as link;
    SELECT 'Messages' as title;

    SELECT 'title' AS component, 'IMAP Messages' as contents;
    
    SELECT 'table' AS component, 1 AS search, 1 AS sort;
    SELECT 
        message_id AS "Message ID",
        email AS "Email Account",
        folder_name AS "Folder",
        subject AS "Subject",
        '[View](/ur/uniform-resource-imap-mail-detail.sql?message_id=' || ur_ingest_session_imap_acct_folder_message_id || ')' AS "Details"
    FROM uniform_resource_imap
    WHERE ($folder_id IS NULL OR ur_ingest_session_imap_acct_folder_id = $folder_id)
    ORDER BY ur_ingest_session_imap_acct_folder_message_id DESC;`);
  }

  "ur/uniform-resource-imap-mail-detail.sql"() {
    return inlinedSQL(SQL`SELECT 'breadcrumb' AS component;
    SELECT 'Home' as title, '/' as link;
    SELECT 'Uniform Resources' as title, '/ur/index.sql' as link;
    SELECT 'IMAP Messages' as title, '/ur/uniform-resource-imap-mail-list.sql' as link;
    SELECT 'Message: ' || $message_id as title;

    SELECT 'title' AS component, 'IMAP Message Details' as contents;
    
    SELECT 'table' AS component;
    SELECT 
        'Message ID' AS "Field",
        message_id AS "Value"
    FROM uniform_resource_imap
    WHERE ur_ingest_session_imap_acct_folder_message_id = $message_id
    UNION ALL
    SELECT 
        'Subject' AS "Field",
        subject AS "Value"
    FROM uniform_resource_imap
    WHERE ur_ingest_session_imap_acct_folder_message_id = $message_id
    UNION ALL
    SELECT 
        'Email Account' AS "Field",
        email AS "Value"
    FROM uniform_resource_imap
    WHERE ur_ingest_session_imap_acct_folder_message_id = $message_id
    UNION ALL
    SELECT 
        'Folder' AS "Field",
        folder_name AS "Value"
    FROM uniform_resource_imap
    WHERE ur_ingest_session_imap_acct_folder_message_id = $message_id;`);
  }
}