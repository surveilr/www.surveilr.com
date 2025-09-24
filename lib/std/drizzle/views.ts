// ============================================================================
// VIEWS - ALL views from the RSSD system (using proper Drizzle patterns)
// ============================================================================
import { sqliteView } from "npm:drizzle-orm/sqlite-core"
import { sql, count, avg, min, max, sum, eq, and, desc, asc } from "npm:drizzle-orm"
import { 
  codeNotebookCell, 
  codeNotebookKernel,
  codeNotebookState,
  device,
  uniformResource,
  uniformResourceEdge,
  urIngestSessionFsPath,
  urIngestSessionFsPathEntry,
  urIngestSession,
  orchestrationSession,
  orchestrationNature,
  orchestrationSessionState,
  orchestrationSessionExec,
  orchestrationSessionEntry,
  orchestrationSessionIssue,
  orchestrationSessionLog,
  urIngestSessionImapAcctFolderMessage,
  urIngestSessionImapAcctFolder,
  urIngestSessionImapAccount,
  uniformResourceGraph,
  urIngestSessionPlmAcctProjectIssue,
  urIngestSessionTask,
  party,
  partyType,
  person,
  organization,
  urIngestSessionFsPath as urIngestSessionFsPathAlias
} from "./models.ts"

// ============================================================================
// Code Notebook Views
// ============================================================================

export const codeNotebookCellVersions = sqliteView("code_notebook_cell_versions").as((qb) => {
  return qb
    .select({
      notebookName: codeNotebookCell.notebookName,
      notebookKernelId: codeNotebookCell.notebookKernelId,
      cellName: codeNotebookCell.cellName,
      versions: sql<number>`COUNT(*) OVER(PARTITION BY ${codeNotebookCell.notebookName}, ${codeNotebookCell.cellName})`.as("versions"),
      codeNotebookCellId: codeNotebookCell.codeNotebookCellId,
    })
    .from(codeNotebookCell)
    .orderBy(codeNotebookCell.notebookName, codeNotebookCell.cellName);
});

export const codeNotebookCellLatest = sqliteView("code_notebook_cell_latest").as((qb) => {
  return qb
    .select({
      codeNotebookCellId: codeNotebookCell.codeNotebookCellId,
      notebookKernelId: codeNotebookCell.notebookKernelId,
      notebookName: codeNotebookCell.notebookName,
      cellName: codeNotebookCell.cellName,
      interpretableCode: codeNotebookCell.interpretableCode,
      interpretableCodeHash: codeNotebookCell.interpretableCodeHash,
      description: codeNotebookCell.description,
      cellGovernance: codeNotebookCell.cellGovernance,
      arguments: codeNotebookCell.arguments,
      activityLog: codeNotebookCell.activityLog,
      versionTimestamp: sql`COALESCE(${codeNotebookCell.updatedAt}, ${codeNotebookCell.createdAt})`.as("version_timestamp")
    })
    .from(codeNotebookCell)
    .where(sql`${codeNotebookCell.codeNotebookCellId} IN (
      SELECT code_notebook_cell_id 
      FROM (
        SELECT code_notebook_cell_id,
               ROW_NUMBER() OVER (
                 PARTITION BY code_notebook_cell_id
                 ORDER BY COALESCE(updated_at, created_at) DESC
               ) AS rn
        FROM code_notebook_cell
      ) ranked WHERE rn = 1
    )`);
});

export const codeNotebookSqlCellMigratableVersion = sqliteView("code_notebook_sql_cell_migratable_version").as((qb) => {
  return qb
    .select({
      codeNotebookCellId: codeNotebookCell.codeNotebookCellId,
      notebookName: codeNotebookCell.notebookName,
      cellName: codeNotebookCell.cellName,
      interpretableCode: codeNotebookCell.interpretableCode,
      interpretableCodeHash: codeNotebookCell.interpretableCodeHash,
      isIdempotent: sql<boolean>`CASE WHEN ${codeNotebookCell.cellName} LIKE '%_once_%' THEN FALSE ELSE TRUE END`.as("is_idempotent"),
      versionTimestamp: sql`COALESCE(${codeNotebookCell.updatedAt}, ${codeNotebookCell.createdAt})`.as("version_timestamp")
    })
    .from(codeNotebookCell)
    .where(eq(codeNotebookCell.notebookName, 'ConstructionSqlNotebook'))
    .orderBy(codeNotebookCell.cellName);
});

export const codeNotebookSqlCellMigratable = sqliteView("code_notebook_sql_cell_migratable").as((qb) => {
  return qb
    .select({
      codeNotebookCellId: codeNotebookCell.codeNotebookCellId,
      notebookKernelId: codeNotebookCell.notebookKernelId,
      notebookName: codeNotebookCell.notebookName,
      cellName: codeNotebookCell.cellName,
      interpretableCode: codeNotebookCell.interpretableCode,
      interpretableCodeHash: codeNotebookCell.interpretableCodeHash,
      description: codeNotebookCell.description,
      cellGovernance: codeNotebookCell.cellGovernance,
      arguments: codeNotebookCell.arguments,
      activityLog: codeNotebookCell.activityLog,
      isIdempotent: sql<boolean>`CASE WHEN ${codeNotebookCell.cellName} LIKE '%_once_%' THEN FALSE ELSE TRUE END`.as("is_idempotent")
    })
    .from(codeNotebookCell)
    .where(eq(codeNotebookCell.notebookName, 'ConstructionSqlNotebook'))
    .orderBy(codeNotebookCell.cellName);
});

export const codeNotebookSqlCellMigratableState = sqliteView("code_notebook_sql_cell_migratable_state").as((qb) => {
  return qb
    .select({
      codeNotebookCellId: codeNotebookCell.codeNotebookCellId,
      notebookKernelId: codeNotebookCell.notebookKernelId,
      notebookName: codeNotebookCell.notebookName,
      cellName: codeNotebookCell.cellName,
      interpretableCode: codeNotebookCell.interpretableCode,
      interpretableCodeHash: codeNotebookCell.interpretableCodeHash,
      description: codeNotebookCell.description,
      cellGovernance: codeNotebookCell.cellGovernance,
      arguments: codeNotebookCell.arguments,
      activityLog: codeNotebookCell.activityLog,
      fromState: codeNotebookState.fromState,
      toState: codeNotebookState.toState,
      transitionReason: codeNotebookState.transitionReason,
      transitionResult: codeNotebookState.transitionResult,
      transitionedAt: codeNotebookState.transitionedAt
    })
    .from(codeNotebookCell)
    .innerJoin(codeNotebookState, eq(codeNotebookCell.codeNotebookCellId, codeNotebookState.codeNotebookCellId))
    .where(eq(codeNotebookCell.notebookName, 'ConstructionSqlNotebook'))
    .orderBy(codeNotebookCell.cellName);
});

export const codeNotebookSqlCellMigratableNotExecuted = sqliteView("code_notebook_sql_cell_migratable_not_executed").as((qb) => {
  return qb
    .select({
      codeNotebookCellId: codeNotebookCell.codeNotebookCellId,
      notebookKernelId: codeNotebookCell.notebookKernelId,
      notebookName: codeNotebookCell.notebookName,
      cellName: codeNotebookCell.cellName,
      interpretableCode: codeNotebookCell.interpretableCode,
      interpretableCodeHash: codeNotebookCell.interpretableCodeHash,
      description: codeNotebookCell.description,
      cellGovernance: codeNotebookCell.cellGovernance,
      arguments: codeNotebookCell.arguments,
      activityLog: codeNotebookCell.activityLog
    })
    .from(codeNotebookCell)
    .leftJoin(codeNotebookState, and(
      eq(codeNotebookCell.codeNotebookCellId, codeNotebookState.codeNotebookCellId),
      eq(codeNotebookState.toState, 'EXECUTED')
    ))
    .where(
      and(
        eq(codeNotebookCell.notebookName, 'ConstructionSqlNotebook'),
        sql`${codeNotebookState.codeNotebookCellId} IS NULL`
      )
    )
    .orderBy(codeNotebookCell.cellName);
});

export const codeNotebookMigrationSql = sqliteView("code_notebook_migration_sql", {}).as(sql`
  SELECT 'BEGIN TRANSACTION;

  ' ||
        'CREATE TEMP TABLE IF NOT EXISTS "session_state_ephemeral" (
      "key" TEXT PRIMARY KEY NOT NULL,
      "value" TEXT NOT NULL
    );

    ' ||
        GROUP_CONCAT(
          CASE
            -- Case 1: Non-idempotent and already executed
            WHEN c.is_idempotent = FALSE AND s.code_notebook_cell_id IS NOT NULL THEN
              '-- ' || c.notebook_name || '.' || c.cell_name || ' not included because it is non-idempotent and was already executed on ' || s.transitioned_at || '

  '
            -- Case 2: Idempotent and not yet executed, idempotent and being reapplied, or non-idempotent and being run for the first time
            ELSE
              '-- ' || c.notebook_name || '.' || c.cell_name || '
  ' ||
              CASE
                -- First execution (non-idempotent or idempotent)
                WHEN s.code_notebook_cell_id IS NULL THEN
                  '-- Executing for the first time.
  '
                -- Reapplying execution (idempotent)
                ELSE
                  '-- Reapplying execution. Last executed on ' || s.transitioned_at || '
  '
              END ||
              c.interpretable_code || '
  ' ||
              'INSERT INTO code_notebook_state (code_notebook_state_id, code_notebook_cell_id, from_state, to_state, transition_reason, created_at) ' ||
              'VALUES (' ||
              '''' || c.code_notebook_cell_id || '__' || strftime('%Y%m%d%H%M%S', 'now') || '''' || ', ' ||
              '''' || c.code_notebook_cell_id || '''' || ', ' ||
              '''MIGRATION_CANDIDATE''' || ', ' ||
              '''EXECUTED''' || ', ' ||
              CASE
                WHEN s.code_notebook_cell_id IS NULL THEN '''Migration'''
                ELSE '''Reapplication'''
              END || ', ' ||
              'CURRENT_TIMESTAMP' || ')' || '
  ' ||
              'ON CONFLICT(code_notebook_cell_id, from_state, to_state) DO UPDATE SET updated_at = CURRENT_TIMESTAMP, ' ||
                'transition_reason = ''Reapplied ' || datetime('now', 'localtime') || ''';' || '
  '
          END,
          '
  '
        ) || '

  COMMIT;' as migration_sql 
  FROM code_notebook_sql_cell_migratable c
  LEFT JOIN code_notebook_state s
    ON c.code_notebook_cell_id = s.code_notebook_cell_id AND s.to_state = 'EXECUTED'
  ORDER BY c.cell_name`);

// ============================================================================
// Graph Views (using query builder where possible)
// ============================================================================

export const plmGraph = sqliteView("plm_graph").as((qb) => {
  return qb
    .select({
      graphName: uniformResourceEdge.graphName,
      nature: uniformResourceEdge.nature,
      uniformResourceId: uniformResource.uniformResourceId,
      uri: uniformResource.uri,
      urIngestSessionPlmAcctProjectIssueId: urIngestSessionPlmAcctProjectIssue.urIngestSessionPlmAcctProjectIssueId,
      issueId: urIngestSessionPlmAcctProjectIssue.issueId,
      projectId: urIngestSessionPlmAcctProjectIssue.urIngestSessionPlmAcctProjectId,
      title: urIngestSessionPlmAcctProjectIssue.title,
      body: urIngestSessionPlmAcctProjectIssue.body,
    })
    .from(uniformResourceEdge)
    .innerJoin(uniformResource, eq(uniformResourceEdge.uniformResourceId, uniformResource.uniformResourceId))
    .innerJoin(urIngestSessionPlmAcctProjectIssue, eq(uniformResourceEdge.nodeId, urIngestSessionPlmAcctProjectIssue.urIngestSessionPlmAcctProjectIssueId))
    .where(eq(uniformResourceEdge.graphName, 'plm'));
});

export const imapGraph = sqliteView("imap_graph").as((qb) => {
  return qb
    .select({
      graphName: uniformResourceEdge.graphName,
      uniformResourceId: uniformResource.uniformResourceId,
      nature: uniformResource.nature,
      uri: uniformResource.uri,
      content: uniformResource.content,
      urIngestSessionImapAcctFolderMessageId: urIngestSessionImapAcctFolderMessage.urIngestSessionImapAcctFolderMessageId,
      ingestImapAcctFolderId: urIngestSessionImapAcctFolderMessage.ingestImapAcctFolderId,
      messageId: urIngestSessionImapAcctFolderMessage.messageId,
    })
    .from(uniformResourceEdge)
    .innerJoin(uniformResource, eq(uniformResourceEdge.uniformResourceId, uniformResource.uniformResourceId))
    .innerJoin(urIngestSessionImapAcctFolderMessage, eq(uniformResourceEdge.nodeId, urIngestSessionImapAcctFolderMessage.urIngestSessionImapAcctFolderMessageId))
    .where(eq(uniformResourceEdge.graphName, 'imap'));
});

export const filesystemGraph = sqliteView("filesystem_graph").as((qb) => {
  return qb
    .select({
      graphName: uniformResourceEdge.graphName,
      uniformResourceId: uniformResource.uniformResourceId,
      nature: uniformResource.nature,
      uri: uniformResource.uri,
      urIngestSessionFsPathId: urIngestSessionFsPath.urIngestSessionFsPathId,
      rootPath: urIngestSessionFsPath.rootPath,
    })
    .from(uniformResourceEdge)
    .innerJoin(uniformResource, eq(uniformResourceEdge.uniformResourceId, uniformResource.uniformResourceId))
    .innerJoin(urIngestSessionFsPath, eq(uniformResourceEdge.nodeId, urIngestSessionFsPath.urIngestSessionFsPathId))
    .where(eq(uniformResourceEdge.graphName, 'filesystem'));
});

// ============================================================================
// Console Information Schema Views (using Drizzle query builder)
// ============================================================================

export const consoleInformationSchemaTable = sqliteView("console_information_schema_table", {}).as(sql`
  SELECT
    tbl.name AS table_name,
    col.name AS column_name,
    col.type AS data_type,
    CASE WHEN col.pk = 1 THEN 'Yes' ELSE 'No' END AS is_primary_key,
    CASE WHEN col."notnull" = 1 THEN 'Yes' ELSE 'No' END AS is_not_null,
    col.dflt_value AS default_value,
    'console/info-schema/table.sql?name=' || tbl.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || tbl.name || ' (table) Schema](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_full_md,
    'console/content/table/' || tbl.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || tbl.name || ' (table) Content](console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    tbl.sql as sql_ddl
  FROM sqlite_master tbl
  JOIN pragma_table_info(tbl.name) col
  WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%'
`);

export const consoleInformationSchemaView = sqliteView("console_information_schema_view", {}).as(sql`
  SELECT
    vw.name AS view_name,
    col.name AS column_name,
    col.type AS data_type,
    '/console/info-schema/view.sql?name=' || vw.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || vw.name || ' (view) Schema](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/view/' || vw.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || vw.name || ' (view) Content](console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    vw.sql as sql_ddl
  FROM sqlite_master vw
  JOIN pragma_table_info(vw.name) col
  WHERE vw.type = 'view' AND vw.name NOT LIKE 'sqlite_%'
`);

export const consoleContentTabular = sqliteView("console_content_tabular").as((qb) => {
  const tableQuery = qb
    .select({
      tabularNature: sql<string>`'table'`.as("tabular_nature"),
      tabularName: sql`table_name`.as("tabular_name"),
      infoSchemaWebUiPath: sql`info_schema_web_ui_path`.as("info_schema_web_ui_path"),
      infoSchemaLinkAbbrevMd: sql`info_schema_link_abbrev_md`.as("info_schema_link_abbrev_md"),
      infoSchemaLinkFullMd: sql`info_schema_link_full_md`.as("info_schema_link_full_md"),
      contentWebUiPath: sql`content_web_ui_path`.as("content_web_ui_path"),
      contentWebUiLinkAbbrevMd: sql`content_web_ui_link_abbrev_md`.as("content_web_ui_link_abbrev_md"),
      contentWebUiLinkFullMd: sql`content_web_ui_link_full_md`.as("content_web_ui_link_full_md")
    })
    .from(consoleInformationSchemaTable);

  const viewQuery = qb
    .select({
      tabularNature: sql<string>`'view'`.as("tabular_nature"),
      tabularName: sql`view_name`.as("tabular_name"),
      infoSchemaWebUiPath: sql`info_schema_web_ui_path`.as("info_schema_web_ui_path"),
      infoSchemaLinkAbbrevMd: sql`info_schema_link_abbrev_md`.as("info_schema_link_abbrev_md"),
      infoSchemaLinkFullMd: sql`info_schema_link_full_md`.as("info_schema_link_full_md"),
      contentWebUiPath: sql`content_web_ui_path`.as("content_web_ui_path"),
      contentWebUiLinkAbbrevMd: sql`content_web_ui_link_abbrev_md`.as("content_web_ui_link_abbrev_md"),
      contentWebUiLinkFullMd: sql`content_web_ui_link_full_md`.as("content_web_ui_link_full_md")
    })
    .from(consoleInformationSchemaView);

  return tableQuery.unionAll(viewQuery);
});

export const consoleInformationSchemaTableColFkey = sqliteView("console_information_schema_table_col_fkey", {}).as(sql`
  SELECT
    tbl.name AS table_name,
    f."from" AS column_name,
    f."from" || ' references ' || f."table" || '.' || f."to" AS foreign_key
  FROM sqlite_master tbl
  JOIN pragma_foreign_key_list(tbl.name) f
  WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%'
`);

export const consoleInformationSchemaTableColIndex = sqliteView("console_information_schema_table_col_index", {}).as(sql`
  SELECT
    tbl.name AS table_name,
    pi.name AS column_name,
    idx.name AS index_name
  FROM sqlite_master tbl
  JOIN pragma_index_list(tbl.name) idx
  JOIN pragma_index_info(idx.name) pi
  WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%'
`);

// ============================================================================
// Statistics Views (using Drizzle query builder)
// ============================================================================

export const rssdStatisticsOverview = sqliteView("rssd_statistics_overview").as((qb) => {
  return qb
    .select({
      dbSizeMb: sql<number>`(SELECT ROUND(page_count * page_size / (1024.0 * 1024), 2) FROM pragma_page_count(), pragma_page_size())`.as("db_size_mb"),
      dbSizeGb: sql<number>`(SELECT ROUND(page_count * page_size / (1024.0 * 1024 * 1024), 4) FROM pragma_page_count(), pragma_page_size())`.as("db_size_gb"),
      totalTables: sql<number>`(SELECT COUNT(*) FROM sqlite_master WHERE type = 'table')`.as("total_tables"),
      totalIndexes: sql<number>`(SELECT COUNT(*) FROM sqlite_master WHERE type = 'index')`.as("total_indexes"),
      totalRows: sql<number>`(SELECT SUM(tbl_rows) FROM (SELECT name, (SELECT COUNT(*) FROM sqlite_master sm WHERE sm.type='table' AND sm.name=t.name) AS tbl_rows FROM sqlite_master t WHERE type='table'))`.as("total_rows"),
      pageSize: sql<number>`(SELECT page_size FROM pragma_page_size())`.as("page_size"),
      totalPages: sql<number>`(SELECT page_count FROM pragma_page_count())`.as("total_pages")
    })
    .from(sql`(SELECT 1) AS dummy`);
});

export const rssdTableStatistic = sqliteView("rssd_table_statistic", {}).as(sql`
  SELECT 
    m.name AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info(m.name)) AS total_columns,
    (SELECT COUNT(*) FROM pragma_index_list(m.name)) AS total_indexes,
    (SELECT COUNT(*) FROM pragma_foreign_key_list(m.name)) AS foreign_keys,
    (SELECT COUNT(*) FROM pragma_table_info(m.name) WHERE pk != 0) AS primary_keys,
    (SELECT table_size_mb FROM surveilr_table_size WHERE table_name = m.name) AS table_size_mb
  FROM sqlite_master m
  WHERE m.type = 'table'
`);

// ============================================================================
// Uniform Resource Views (mixing query builder and raw SQL)
// ============================================================================

export const uniformResourceFile = sqliteView("uniform_resource_file").as((qb) => {
  return qb
    .select({
      uniformResourceId: uniformResource.uniformResourceId,
      nature: uniformResource.nature,
      sourcePath: urIngestSessionFsPath.rootPath,
      filePathRel: urIngestSessionFsPathEntry.filePathRel,
      sizeBytes: uniformResource.sizeBytes,
    })
    .from(uniformResource)
    .leftJoin(uniformResourceEdge, 
      and(
        eq(uniformResource.uniformResourceId, uniformResourceEdge.uniformResourceId),
        eq(uniformResourceEdge.nature, 'ingest_fs_path')
      )
    )
    .leftJoin(urIngestSessionFsPath, eq(uniformResourceEdge.nodeId, urIngestSessionFsPath.urIngestSessionFsPathId))
    .leftJoin(urIngestSessionFsPathEntry, eq(uniformResource.uniformResourceId, urIngestSessionFsPathEntry.uniformResourceId));
});

export const uniformResourceImap = sqliteView("uniform_resource_imap").as((qb) => {
  return qb
    .select({
      uniformResourceId: uniformResource.uniformResourceId,
      graphName: uniformResourceGraph.name,
      urIngestSessionImapAccountId: urIngestSessionImapAccount.urIngestSessionImapAccountId,
      email: urIngestSessionImapAccount.email,
      host: urIngestSessionImapAccount.host,
      subject: urIngestSessionImapAcctFolderMessage.subject,
      from: urIngestSessionImapAcctFolderMessage.from,
      message: urIngestSessionImapAcctFolderMessage.message,
      date: urIngestSessionImapAcctFolderMessage.date,
      urIngestSessionImapAcctFolderId: urIngestSessionImapAcctFolder.urIngestSessionImapAcctFolderId,
      ingestAccountId: urIngestSessionImapAcctFolder.ingestAccountId,
      folderName: urIngestSessionImapAcctFolder.folderName,
      sizeBytes: uniformResource.sizeBytes,
      nature: uniformResource.nature,
      content: uniformResource.content
    })
    .from(uniformResource)
    .innerJoin(uniformResourceEdge, eq(uniformResourceEdge.uniformResourceId, uniformResource.uniformResourceId))
    .innerJoin(uniformResourceGraph, eq(uniformResourceGraph.name, uniformResourceEdge.graphName))
    .innerJoin(urIngestSessionImapAcctFolderMessage, eq(urIngestSessionImapAcctFolderMessage.urIngestSessionImapAcctFolderMessageId, uniformResourceEdge.nodeId))
    .innerJoin(urIngestSessionImapAcctFolder, eq(urIngestSessionImapAcctFolderMessage.ingestImapAcctFolderId, urIngestSessionImapAcctFolder.urIngestSessionImapAcctFolderId))
    .leftJoin(urIngestSessionImapAccount, eq(urIngestSessionImapAccount.urIngestSessionImapAccountId, urIngestSessionImapAcctFolder.ingestAccountId))
    .where(and(
      eq(uniformResource.nature, 'text'),
      eq(uniformResourceGraph.name, 'imap'),
      sql`${uniformResource.ingestSessionImapAcctFolderMessage} IS NOT NULL`
    ));
});

export const uniformResourceImapContent = sqliteView("uniform_resource_imap_content").as((qb) => {
  return qb
    .select({
      uniformResourceId: uniformResourceImap.uniformResourceId,
      baseId: sql`base_ur.uniform_resource_id`.as("base_id"),
      extId: sql`ext_ur.uniform_resource_id`.as("ext_id"),
      baseUri: sql`base_ur.uri`.as("base_uri"),
      extUri: sql`ext_ur.uri`.as("ext_uri"),
      baseNature: sql`base_ur.nature`.as("base_nature"),
      extNature: sql`ext_ur.nature`.as("ext_nature"),
      htmlContent: sql`json_extract(part.value, '$.body.Html')`.as("html_content")
    })
    .from(uniformResourceImap)
    .innerJoin(sql`uniform_resource base_ur`, sql`base_ur.uniform_resource_id = ${uniformResourceImap.uniformResourceId}`)
    .innerJoin(sql`uniform_resource ext_ur`, sql`ext_ur.uri = base_ur.uri || '/json' AND ext_ur.nature = 'json'`)
    .crossJoin(sql`json_each(ext_ur.content, '$.parts') AS part`)
    .where(and(
      sql`ext_ur.nature = 'json'`,
      sql`json_extract(part.value, '$.body.Html') IS NOT NULL`
    ));
});

// ============================================================================
// Ingestion Session Statistics Views (using raw SQL for complex aggregations)
// ============================================================================

export const urIngestSessionFilesStats = sqliteView("ur_ingest_session_files_stats").as((qb) => {
  return qb
    .select({
      deviceId: device.deviceId,
      ingestSessionId: urIngestSession.urIngestSessionId,
      ingestSessionStartedAt: urIngestSession.ingestStartedAt,
      ingestSessionFinishedAt: urIngestSession.ingestFinishedAt,
      fileExtension: sql`COALESCE(${urIngestSessionFsPathEntry.fileExtn}, '')`.as("file_extension"),
      ingestSessionFsPathId: urIngestSessionFsPath.urIngestSessionFsPathId,
      ingestSessionRootFsPath: urIngestSessionFsPath.rootPath,
      totalFileCount: count(urIngestSessionFsPathEntry.uniformResourceId).as("total_file_count"),
      fileCountWithContent: sum(sql`CASE WHEN ${uniformResource.content} IS NOT NULL THEN 1 ELSE 0 END`).as("file_count_with_content"),
      fileCountWithFrontmatter: sum(sql`CASE WHEN ${uniformResource.frontmatter} IS NOT NULL THEN 1 ELSE 0 END`).as("file_count_with_frontmatter"),
      minFileSizeBytes: min(uniformResource.sizeBytes).as("min_file_size_bytes"),
      averageFileSizeBytes: sql<number>`CAST(ROUND(AVG(${uniformResource.sizeBytes})) AS INTEGER)`.as("average_file_size_bytes"),
      maxFileSizeBytes: max(uniformResource.sizeBytes).as("max_file_size_bytes"),
      oldestFileLastModifiedDatetime: min(uniformResource.lastModifiedAt).as("oldest_file_last_modified_datetime"),
      youngestFileLastModifiedDatetime: max(uniformResource.lastModifiedAt).as("youngest_file_last_modified_datetime")
    })
    .from(urIngestSession)
    .innerJoin(device, eq(urIngestSession.deviceId, device.deviceId))
    .leftJoin(urIngestSessionFsPath, eq(urIngestSession.urIngestSessionId, urIngestSessionFsPath.ingestSessionId))
    .leftJoin(urIngestSessionFsPathEntry, eq(urIngestSessionFsPath.urIngestSessionFsPathId, urIngestSessionFsPathEntry.ingestFsPathId))
    .leftJoin(uniformResource, eq(urIngestSessionFsPathEntry.uniformResourceId, uniformResource.uniformResourceId))
    .groupBy(
      device.deviceId,
      urIngestSession.urIngestSessionId,
      urIngestSession.ingestStartedAt,
      urIngestSession.ingestFinishedAt,
      urIngestSessionFsPathEntry.fileExtn,
      urIngestSessionFsPath.rootPath
    )
    .orderBy(device.deviceId, urIngestSession.ingestFinishedAt, urIngestSessionFsPathEntry.fileExtn);
});

export const urIngestSessionFilesStatsLatest = sqliteView("ur_ingest_session_files_stats_latest").as((qb) => {
  return qb
    .select({
      deviceId: urIngestSessionFilesStats.deviceId,
      ingestSessionId: urIngestSessionFilesStats.ingestSessionId,
      ingestSessionStartedAt: urIngestSessionFilesStats.ingestSessionStartedAt,
      ingestSessionFinishedAt: urIngestSessionFilesStats.ingestSessionFinishedAt,
      fileExtension: urIngestSessionFilesStats.fileExtension,
      ingestSessionFsPathId: urIngestSessionFilesStats.ingestSessionFsPathId,
      ingestSessionRootFsPath: urIngestSessionFilesStats.ingestSessionRootFsPath,
      totalFileCount: urIngestSessionFilesStats.totalFileCount,
      fileCountWithContent: urIngestSessionFilesStats.fileCountWithContent,
      fileCountWithFrontmatter: urIngestSessionFilesStats.fileCountWithFrontmatter,
      minFileSizeBytes: urIngestSessionFilesStats.minFileSizeBytes,
      averageFileSizeBytes: urIngestSessionFilesStats.averageFileSizeBytes,
      maxFileSizeBytes: urIngestSessionFilesStats.maxFileSizeBytes,
      oldestFileLastModifiedDatetime: urIngestSessionFilesStats.oldestFileLastModifiedDatetime,
      youngestFileLastModifiedDatetime: urIngestSessionFilesStats.youngestFileLastModifiedDatetime
    })
    .from(urIngestSessionFilesStats)
    .where(sql`${urIngestSessionFilesStats.ingestSessionId} IN (
      SELECT ${urIngestSession.urIngestSessionId}
      FROM ${urIngestSession}
      ORDER BY ${urIngestSession.ingestFinishedAt} DESC
      LIMIT 1
    )`);
});

export const urIngestSessionTasksStats = sqliteView("ur_ingest_session_tasks_stats").as((qb) => {
  return qb
    .select({
      deviceId: device.deviceId,
      ingestSessionId: urIngestSession.urIngestSessionId,
      ingestSessionStartedAt: urIngestSession.ingestStartedAt,
      ingestSessionFinishedAt: urIngestSession.ingestFinishedAt,
      urStatus: sql`COALESCE(${urIngestSessionTask.urStatus}, 'Ok')`.as("ur_status"),
      nature: sql`COALESCE(${uniformResource.nature}, 'UNKNOWN')`.as("nature"),
      totalFileCount: count(urIngestSessionTask.uniformResourceId).as("total_file_count"),
      fileCountWithContent: sum(sql`CASE WHEN ${uniformResource.content} IS NOT NULL THEN 1 ELSE 0 END`).as("file_count_with_content"),
      fileCountWithFrontmatter: sum(sql`CASE WHEN ${uniformResource.frontmatter} IS NOT NULL THEN 1 ELSE 0 END`).as("file_count_with_frontmatter"),
      minFileSizeBytes: min(uniformResource.sizeBytes).as("min_file_size_bytes"),
      averageFileSizeBytes: sql<number>`CAST(ROUND(AVG(${uniformResource.sizeBytes})) AS INTEGER)`.as("average_file_size_bytes"),
      maxFileSizeBytes: max(uniformResource.sizeBytes).as("max_file_size_bytes"),
      oldestFileLastModifiedDatetime: min(uniformResource.lastModifiedAt).as("oldest_file_last_modified_datetime"),
      youngestFileLastModifiedDatetime: max(uniformResource.lastModifiedAt).as("youngest_file_last_modified_datetime")
    })
    .from(urIngestSession)
    .innerJoin(device, eq(urIngestSession.deviceId, device.deviceId))
    .leftJoin(urIngestSessionTask, eq(urIngestSession.urIngestSessionId, urIngestSessionTask.ingestSessionId))
    .leftJoin(uniformResource, eq(urIngestSessionTask.uniformResourceId, uniformResource.uniformResourceId))
    .groupBy(
      device.deviceId,
      urIngestSession.urIngestSessionId,
      urIngestSession.ingestStartedAt,
      urIngestSession.ingestFinishedAt,
      urIngestSessionTask.capturedExecutable
    )
    .orderBy(device.deviceId, urIngestSession.ingestFinishedAt, urIngestSessionTask.urStatus);
});

export const urIngestSessionTasksStatsLatest = sqliteView("ur_ingest_session_tasks_stats_latest").as((qb) => {
  return qb
    .select({
      deviceId: urIngestSessionTasksStats.deviceId,
      ingestSessionId: urIngestSessionTasksStats.ingestSessionId,
      ingestSessionStartedAt: urIngestSessionTasksStats.ingestSessionStartedAt,
      ingestSessionFinishedAt: urIngestSessionTasksStats.ingestSessionFinishedAt,
      urStatus: urIngestSessionTasksStats.urStatus,
      nature: urIngestSessionTasksStats.nature,
      totalFileCount: urIngestSessionTasksStats.totalFileCount,
      fileCountWithContent: urIngestSessionTasksStats.fileCountWithContent,
      fileCountWithFrontmatter: urIngestSessionTasksStats.fileCountWithFrontmatter,
      minFileSizeBytes: urIngestSessionTasksStats.minFileSizeBytes,
      averageFileSizeBytes: urIngestSessionTasksStats.averageFileSizeBytes,
      maxFileSizeBytes: urIngestSessionTasksStats.maxFileSizeBytes,
      oldestFileLastModifiedDatetime: urIngestSessionTasksStats.oldestFileLastModifiedDatetime,
      youngestFileLastModifiedDatetime: urIngestSessionTasksStats.youngestFileLastModifiedDatetime
    })
    .from(urIngestSessionTasksStats)
    .where(sql`${urIngestSessionTasksStats.ingestSessionId} IN (
      SELECT ${urIngestSession.urIngestSessionId}
      FROM ${urIngestSession}
      ORDER BY ${urIngestSession.ingestFinishedAt} DESC
      LIMIT 1
    )`);
});

export const urIngestSessionFileIssue = sqliteView("ur_ingest_session_file_issue").as((qb) => {
  return qb
    .select({
      deviceId: urIngestSession.deviceId,
      urIngestSessionId: urIngestSession.urIngestSessionId,
      urIngestSessionFsPathId: urIngestSessionFsPath.urIngestSessionFsPathId,
      rootPath: urIngestSessionFsPath.rootPath,
      urIngestSessionFsPathEntryId: urIngestSessionFsPathEntry.urIngestSessionFsPathEntryId,
      filePathAbs: urIngestSessionFsPathEntry.filePathAbs,
      urStatus: urIngestSessionFsPathEntry.urStatus,
      urDiagnostics: urIngestSessionFsPathEntry.urDiagnostics
    })
    .from(urIngestSessionFsPathEntry)
    .innerJoin(urIngestSessionFsPath, eq(urIngestSessionFsPathEntry.ingestFsPathId, urIngestSessionFsPath.urIngestSessionFsPathId))
    .innerJoin(urIngestSession, eq(urIngestSessionFsPath.ingestSessionId, urIngestSession.urIngestSessionId))
    .where(sql`${urIngestSessionFsPathEntry.urStatus} IS NOT NULL`)
    .groupBy(
      urIngestSession.deviceId,
      urIngestSession.urIngestSessionId,
      urIngestSessionFsPath.urIngestSessionFsPathId,
      urIngestSessionFsPath.rootPath,
      urIngestSessionFsPathEntry.urIngestSessionFsPathEntryId,
      urIngestSessionFsPathEntry.filePathAbs,
      urIngestSessionFsPathEntry.urStatus,
      urIngestSessionFsPathEntry.urDiagnostics
    );
});

// ============================================================================
// Orchestration Monitoring Views (using query builder where possible)
// ============================================================================

export const orchestrationSessionByDevice = sqliteView("orchestration_session_by_device").as((qb) => {
  return qb
    .select({
      deviceId: device.deviceId,
      deviceName: device.name,
      sessionCount: count(orchestrationSession.orchestrationSessionId).as("session_count"),
    })
    .from(orchestrationSession)
    .innerJoin(device, eq(orchestrationSession.deviceId, device.deviceId))
    .groupBy(device.deviceId, device.name);
});

export const orchestrationSessionDuration = sqliteView("orchestration_session_duration").as((qb) => {
  return qb
    .select({
      orchestrationSessionId: orchestrationSession.orchestrationSessionId,
      orchestrationNature: orchestrationNature.nature,
      orchStartedAt: orchestrationSession.orchStartedAt,
      orchFinishedAt: orchestrationSession.orchFinishedAt,
      durationSeconds: sql<number>`(JULIANDAY(${orchestrationSession.orchFinishedAt}) - JULIANDAY(${orchestrationSession.orchStartedAt})) * 24 * 60 * 60`.as("duration_seconds"),
    })
    .from(orchestrationSession)
    .innerJoin(orchestrationNature, eq(orchestrationSession.orchestrationNatureId, orchestrationNature.orchestrationNatureId))
    .where(sql`${orchestrationSession.orchFinishedAt} IS NOT NULL`);
});

export const orchestrationSuccessRate = sqliteView("orchestration_success_rate").as((qb) => {
  return qb
    .select({
      orchestrationNature: orchestrationNature.nature,
      totalSessions: count().as("total_sessions"),
      successfulSessions: sum(sql`CASE WHEN ${orchestrationSessionState.toState} = 'surveilr_orch_completed' THEN 1 ELSE 0 END`).as("successful_sessions"),
      successRate: sql<number>`(CAST(SUM(CASE WHEN ${orchestrationSessionState.toState} = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100`.as("success_rate")
    })
    .from(orchestrationSession)
    .innerJoin(orchestrationNature, eq(orchestrationSession.orchestrationNatureId, orchestrationNature.orchestrationNatureId))
    .innerJoin(orchestrationSessionState, eq(orchestrationSession.orchestrationSessionId, orchestrationSessionState.sessionId))
    .where(sql`${orchestrationSessionState.toState} IN ('surveilr_orch_completed', 'surveilr_orch_failed')`)
    .groupBy(orchestrationNature.nature);
});

export const orchestrationSessionScript = sqliteView("orchestration_session_script").as((qb) => {
  return qb
    .select({
      orchestrationSessionId: orchestrationSession.orchestrationSessionId,
      orchestrationNature: orchestrationNature.nature,
      scriptCount: count(orchestrationSessionEntry.orchestrationSessionEntryId).as("script_count"),
    })
    .from(orchestrationSession)
    .innerJoin(orchestrationNature, eq(orchestrationSession.orchestrationNatureId, orchestrationNature.orchestrationNatureId))
    .innerJoin(orchestrationSessionEntry, eq(orchestrationSession.orchestrationSessionId, orchestrationSessionEntry.sessionId))
    .groupBy(orchestrationSession.orchestrationSessionId, orchestrationNature.nature);
});

export const orchestrationExecutionsByType = sqliteView("orchestration_executions_by_type").as((qb) => {
  return qb
    .select({
      execNature: orchestrationSessionExec.execNature,
      executionCount: count(orchestrationSessionExec.orchestrationSessionExecId).as("execution_count"),
    })
    .from(orchestrationSessionExec)
    .groupBy(orchestrationSessionExec.execNature);
});

export const orchestrationExecutionSuccessRateByType = sqliteView("orchestration_execution_success_rate_by_type").as((qb) => {
  return qb
    .select({
      execNature: orchestrationSessionExec.execNature,
      totalExecutions: count().as("total_executions"),
      successfulExecutions: sum(sql`CASE WHEN ${orchestrationSessionExec.execStatus} = 0 THEN 1 ELSE 0 END`).as("successful_executions"),
      successRate: sql<number>`(CAST(SUM(CASE WHEN ${orchestrationSessionExec.execStatus} = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100`.as("success_rate")
    })
    .from(orchestrationSessionExec)
    .groupBy(orchestrationSessionExec.execNature);
});

export const orchestrationSessionSummary = sqliteView("orchestration_session_summary").as((qb) => {
  return qb
    .select({
      issueType: orchestrationSessionIssue.issueType,
      issueCount: count(orchestrationSessionIssue.orchestrationSessionIssueId).as("issue_count"),
    })
    .from(orchestrationSessionIssue)
    .groupBy(orchestrationSessionIssue.issueType);
});

export const orchestrationIssueRemediation = sqliteView("orchestration_issue_remediation").as((qb) => {
  return qb
    .select({
      orchestrationSessionIssueId: orchestrationSessionIssue.orchestrationSessionIssueId,
      issueType: orchestrationSessionIssue.issueType,
      issueMessage: orchestrationSessionIssue.issueMessage,
      remediation: orchestrationSessionIssue.remediation,
    })
    .from(orchestrationSessionIssue)
    .where(sql`${orchestrationSessionIssue.remediation} IS NOT NULL`);
});

export const orchestrationLogsBySession = sqliteView("orchestration_logs_by_session").as((qb) => {
  return qb
    .select({
      orchestrationSessionId: orchestrationSession.orchestrationSessionId,
      orchestrationNature: orchestrationNature.nature,
      category: orchestrationSessionLog.category,
      logCount: count(orchestrationSessionLog.orchestrationSessionLogId).as("log_count"),
    })
    .from(orchestrationSession)
    .innerJoin(orchestrationNature, eq(orchestrationSession.orchestrationNatureId, orchestrationNature.orchestrationNatureId))
    .innerJoin(orchestrationSessionExec, eq(orchestrationSession.orchestrationSessionId, orchestrationSessionExec.sessionId))
    .innerJoin(orchestrationSessionLog, eq(orchestrationSessionExec.orchestrationSessionExecId, orchestrationSessionLog.parentExecId))
    .groupBy(orchestrationSession.orchestrationSessionId, orchestrationNature.nature, orchestrationSessionLog.category);
});