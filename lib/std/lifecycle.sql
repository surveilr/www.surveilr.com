CREATE TEMP TABLE IF NOT EXISTS "session_state_ephemeral" (
    "key" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL
);
-- code provenance: `RssdInitSqlNotebook.bootstrapDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
INSERT INTO "session_state_ephemeral" ("key", "value") VALUES ('current_user', 'runner') ON CONFLICT DO UPDATE SET value = excluded.value;
INSERT INTO "session_state_ephemeral" ("key", "value") VALUES ('current_user_name', 'UNKNOWN') ON CONFLICT DO UPDATE SET value = excluded.value;

CREATE TABLE IF NOT EXISTS "assurance_schema" (
    "assurance_schema_id" VARCHAR PRIMARY KEY NOT NULL,
    "assurance_type" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "code_json" TEXT CHECK(json_valid(code_json) OR code_json IS NULL),
    "governance" TEXT CHECK(json_valid(governance) OR governance IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "code_notebook_kernel" (
    "code_notebook_kernel_id" VARCHAR PRIMARY KEY NOT NULL,
    "kernel_name" TEXT NOT NULL,
    "description" TEXT,
    "mime_type" TEXT,
    "file_extn" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "governance" TEXT CHECK(json_valid(governance) OR governance IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("kernel_name")
);
CREATE TABLE IF NOT EXISTS "code_notebook_cell" (
    "code_notebook_cell_id" VARCHAR PRIMARY KEY NOT NULL,
    "notebook_kernel_id" VARCHAR NOT NULL,
    "notebook_name" TEXT NOT NULL,
    "cell_name" TEXT NOT NULL,
    "cell_governance" TEXT CHECK(json_valid(cell_governance) OR cell_governance IS NULL),
    "interpretable_code" TEXT NOT NULL,
    "interpretable_code_hash" TEXT NOT NULL,
    "description" TEXT,
    "arguments" TEXT CHECK(json_valid(arguments) OR arguments IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("notebook_kernel_id") REFERENCES "code_notebook_kernel"("code_notebook_kernel_id"),
    UNIQUE("notebook_name", "cell_name", "interpretable_code_hash")
);
CREATE TABLE IF NOT EXISTS "code_notebook_state" (
    "code_notebook_state_id" VARCHAR PRIMARY KEY NOT NULL,
    "code_notebook_cell_id" VARCHAR NOT NULL,
    "from_state" TEXT NOT NULL,
    "to_state" TEXT NOT NULL,
    "transition_result" TEXT CHECK(json_valid(transition_result) OR transition_result IS NULL),
    "transition_reason" TEXT,
    "transitioned_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("code_notebook_cell_id") REFERENCES "code_notebook_cell"("code_notebook_cell_id"),
    UNIQUE("code_notebook_cell_id", "from_state", "to_state")
);



DROP VIEW IF EXISTS "code_notebook_cell_versions";
CREATE VIEW IF NOT EXISTS "code_notebook_cell_versions" AS
      -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
      -- All cells and how many different versions of each cell are available
      SELECT notebook_name,
            notebook_kernel_id,
            cell_name,
            COUNT(*) OVER(PARTITION BY notebook_name, cell_name) AS versions,
            code_notebook_cell_id
        FROM code_notebook_cell
    ORDER BY notebook_name, cell_name;
DROP VIEW IF EXISTS "code_notebook_cell_latest";
CREATE VIEW IF NOT EXISTS "code_notebook_cell_latest" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- Retrieve the latest version of each code_notebook_cell.
    -- Notebooks can have multiple versions of cells, where the interpretable_code and other metadata may be updated over time.
    -- The latest record is determined by the most recent COALESCE(updated_at, created_at) timestamp.
    SELECT
        c.code_notebook_cell_id,    -- Selects the unique ID of the notebook cell
        c.notebook_kernel_id,       -- References the kernel associated with this cell
        c.notebook_name,            -- The name of the notebook containing this cell
        c.cell_name,                -- The name of the cell within the notebook
        c.interpretable_code,       -- The latest interpretable code associated with the cell
        c.interpretable_code_hash,  -- Hash of the latest interpretable code
        c.description,              -- Description of the cell's purpose or content
        c.cell_governance,          -- Governance details for the cell (if any)
        c.arguments,                -- Arguments or parameters related to the cell's execution
        c.activity_log,             -- Log of activities related to this cell
        COALESCE(c.updated_at, c.created_at) AS version_timestamp  -- The latest timestamp (updated or created)
    FROM (
        SELECT
            code_notebook_cell_id,
            notebook_kernel_id,
            notebook_name,
            cell_name,
            interpretable_code,
            interpretable_code_hash,
            description,
            cell_governance,
            arguments,
            activity_log,
            updated_at,
            created_at,
            ROW_NUMBER() OVER (
                PARTITION BY code_notebook_cell_id
                ORDER BY COALESCE(updated_at, created_at) DESC  -- Orders by the latest timestamp
            ) AS rn
        FROM
            code_notebook_cell
    ) c WHERE c.rn = 1;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable_version";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable_version" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All cells that are candidates for migration (including duplicates)
    SELECT c.code_notebook_cell_id,
          c.notebook_name,
          c.cell_name,
          c.interpretable_code,
          c.interpretable_code_hash,
          CASE WHEN c.cell_name LIKE '%_once_%' THEN FALSE ELSE TRUE END AS is_idempotent,
          COALESCE(c.updated_at, c.created_at) version_timestamp
      FROM code_notebook_cell c
    WHERE c.notebook_name = 'ConstructionSqlNotebook'
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All cells that are candidates for migration (latest only)
    SELECT c.*,
           CASE WHEN c.cell_name LIKE '%_once_%' THEN FALSE ELSE TRUE END AS is_idempotent
      FROM code_notebook_cell_latest c
    WHERE c.notebook_name = 'ConstructionSqlNotebook'
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable_state";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable_state" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All cells that are candidates for migration (latest only)
    SELECT
        c.*,                  -- All columns from the code_notebook_sql_cell_migratable view
        s.from_state,         -- The state the cell transitioned from
        s.to_state,           -- The state the cell transitioned to
        s.transition_reason,  -- The reason for the state transition
        s.transition_result,  -- The result of the state transition
        s.transitioned_at     -- The timestamp of the state transition
    FROM
        code_notebook_sql_cell_migratable c
    JOIN
        code_notebook_state s
        ON c.code_notebook_cell_id = s.code_notebook_cell_id
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable_not_executed";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable_not_executed" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All latest migratable cells that have not yet been "executed" (based on the code_notebook_state table)
    SELECT c.*
      FROM code_notebook_sql_cell_migratable c
      LEFT JOIN code_notebook_state s
        ON c.code_notebook_cell_id = s.code_notebook_cell_id AND s.to_state = 'EXECUTED'
      WHERE s.code_notebook_cell_id IS NULL
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_migration_sql";
CREATE VIEW IF NOT EXISTS "code_notebook_migration_sql" AS
    
            -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
            -- Creates a dynamic migration script by concatenating all interpretable_code for cells that should be migrated.
            -- Excludes cells with names containing '_once_' if they have already been executed.
            -- Includes comments before each block and special comments for excluded cells.
            -- Wraps everything in a single transaction
            SELECT
                'BEGIN TRANSACTION;
    
    '||
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
    
    COMMIT;' AS migration_sql
            FROM
                code_notebook_sql_cell_migratable c
            LEFT JOIN
                code_notebook_state s
                ON c.code_notebook_cell_id = s.code_notebook_cell_id AND s.to_state = 'EXECUTED'
            ORDER BY
                c.cell_name;
  
DROP TABLE IF EXISTS surveilr_function_doc;
CREATE TABLE IF NOT EXISTS surveilr_function_doc (
    name TEXT PRIMARY KEY,
    description TEXT,
    parameters JSON,
    return_type TEXT,
    version TEXT
);

INSERT INTO surveilr_function_doc (name, description, parameters, return_type, version)
SELECT name, description, parameters, return_type, version
FROM surveilr_function_docs();
;
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('Documentation', 'Documentation', NULL, 'text/plain', '.txt', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('SQL', 'SQLite SQL Statements', NULL, 'application/sql', '.sql', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('AI LLM Prompt', 'Generative AI Large Language Model Prompt', NULL, 'text/plain', '.llm-prompt.txt', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('Text Asset (.puml)', 'Text Asset (.puml)', NULL, 'text/plain', '.puml', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('Text Asset (.rs)', 'Text Asset (.rs)', NULL, 'text/plain', '.rs', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W4T4Z1R7BCQSZP6R9W', 'Documentation', 'rssd-init', 'Boostrap SQL', NULL, '-- code provenance: `RssdInitSqlNotebook.bootstrapDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
INSERT INTO "session_state_ephemeral" ("key", "value") VALUES (''current_user'', ''runner'') ON CONFLICT DO UPDATE SET value = excluded.value;
INSERT INTO "session_state_ephemeral" ("key", "value") VALUES (''current_user_name'', ''UNKNOWN'') ON CONFLICT DO UPDATE SET value = excluded.value;

CREATE TABLE IF NOT EXISTS "assurance_schema" (
    "assurance_schema_id" VARCHAR PRIMARY KEY NOT NULL,
    "assurance_type" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "code_json" TEXT CHECK(json_valid(code_json) OR code_json IS NULL),
    "governance" TEXT CHECK(json_valid(governance) OR governance IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "code_notebook_kernel" (
    "code_notebook_kernel_id" VARCHAR PRIMARY KEY NOT NULL,
    "kernel_name" TEXT NOT NULL,
    "description" TEXT,
    "mime_type" TEXT,
    "file_extn" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "governance" TEXT CHECK(json_valid(governance) OR governance IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("kernel_name")
);
CREATE TABLE IF NOT EXISTS "code_notebook_cell" (
    "code_notebook_cell_id" VARCHAR PRIMARY KEY NOT NULL,
    "notebook_kernel_id" VARCHAR NOT NULL,
    "notebook_name" TEXT NOT NULL,
    "cell_name" TEXT NOT NULL,
    "cell_governance" TEXT CHECK(json_valid(cell_governance) OR cell_governance IS NULL),
    "interpretable_code" TEXT NOT NULL,
    "interpretable_code_hash" TEXT NOT NULL,
    "description" TEXT,
    "arguments" TEXT CHECK(json_valid(arguments) OR arguments IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("notebook_kernel_id") REFERENCES "code_notebook_kernel"("code_notebook_kernel_id"),
    UNIQUE("notebook_name", "cell_name", "interpretable_code_hash")
);
CREATE TABLE IF NOT EXISTS "code_notebook_state" (
    "code_notebook_state_id" VARCHAR PRIMARY KEY NOT NULL,
    "code_notebook_cell_id" VARCHAR NOT NULL,
    "from_state" TEXT NOT NULL,
    "to_state" TEXT NOT NULL,
    "transition_result" TEXT CHECK(json_valid(transition_result) OR transition_result IS NULL),
    "transition_reason" TEXT,
    "transitioned_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("code_notebook_cell_id") REFERENCES "code_notebook_cell"("code_notebook_cell_id"),
    UNIQUE("code_notebook_cell_id", "from_state", "to_state")
);



DROP VIEW IF EXISTS "code_notebook_cell_versions";
CREATE VIEW IF NOT EXISTS "code_notebook_cell_versions" AS
      -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
      -- All cells and how many different versions of each cell are available
      SELECT notebook_name,
            notebook_kernel_id,
            cell_name,
            COUNT(*) OVER(PARTITION BY notebook_name, cell_name) AS versions,
            code_notebook_cell_id
        FROM code_notebook_cell
    ORDER BY notebook_name, cell_name;
DROP VIEW IF EXISTS "code_notebook_cell_latest";
CREATE VIEW IF NOT EXISTS "code_notebook_cell_latest" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- Retrieve the latest version of each code_notebook_cell.
    -- Notebooks can have multiple versions of cells, where the interpretable_code and other metadata may be updated over time.
    -- The latest record is determined by the most recent COALESCE(updated_at, created_at) timestamp.
    SELECT
        c.code_notebook_cell_id,    -- Selects the unique ID of the notebook cell
        c.notebook_kernel_id,       -- References the kernel associated with this cell
        c.notebook_name,            -- The name of the notebook containing this cell
        c.cell_name,                -- The name of the cell within the notebook
        c.interpretable_code,       -- The latest interpretable code associated with the cell
        c.interpretable_code_hash,  -- Hash of the latest interpretable code
        c.description,              -- Description of the cell''s purpose or content
        c.cell_governance,          -- Governance details for the cell (if any)
        c.arguments,                -- Arguments or parameters related to the cell''s execution
        c.activity_log,             -- Log of activities related to this cell
        COALESCE(c.updated_at, c.created_at) AS version_timestamp  -- The latest timestamp (updated or created)
    FROM (
        SELECT
            code_notebook_cell_id,
            notebook_kernel_id,
            notebook_name,
            cell_name,
            interpretable_code,
            interpretable_code_hash,
            description,
            cell_governance,
            arguments,
            activity_log,
            updated_at,
            created_at,
            ROW_NUMBER() OVER (
                PARTITION BY code_notebook_cell_id
                ORDER BY COALESCE(updated_at, created_at) DESC  -- Orders by the latest timestamp
            ) AS rn
        FROM
            code_notebook_cell
    ) c WHERE c.rn = 1;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable_version";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable_version" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All cells that are candidates for migration (including duplicates)
    SELECT c.code_notebook_cell_id,
          c.notebook_name,
          c.cell_name,
          c.interpretable_code,
          c.interpretable_code_hash,
          CASE WHEN c.cell_name LIKE ''%_once_%'' THEN FALSE ELSE TRUE END AS is_idempotent,
          COALESCE(c.updated_at, c.created_at) version_timestamp
      FROM code_notebook_cell c
    WHERE c.notebook_name = ''ConstructionSqlNotebook''
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All cells that are candidates for migration (latest only)
    SELECT c.*,
           CASE WHEN c.cell_name LIKE ''%_once_%'' THEN FALSE ELSE TRUE END AS is_idempotent
      FROM code_notebook_cell_latest c
    WHERE c.notebook_name = ''ConstructionSqlNotebook''
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable_state";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable_state" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All cells that are candidates for migration (latest only)
    SELECT
        c.*,                  -- All columns from the code_notebook_sql_cell_migratable view
        s.from_state,         -- The state the cell transitioned from
        s.to_state,           -- The state the cell transitioned to
        s.transition_reason,  -- The reason for the state transition
        s.transition_result,  -- The result of the state transition
        s.transitioned_at     -- The timestamp of the state transition
    FROM
        code_notebook_sql_cell_migratable c
    JOIN
        code_notebook_state s
        ON c.code_notebook_cell_id = s.code_notebook_cell_id
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable_not_executed";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable_not_executed" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All latest migratable cells that have not yet been "executed" (based on the code_notebook_state table)
    SELECT c.*
      FROM code_notebook_sql_cell_migratable c
      LEFT JOIN code_notebook_state s
        ON c.code_notebook_cell_id = s.code_notebook_cell_id AND s.to_state = ''EXECUTED''
      WHERE s.code_notebook_cell_id IS NULL
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_migration_sql";
CREATE VIEW IF NOT EXISTS "code_notebook_migration_sql" AS
    
            -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
            -- Creates a dynamic migration script by concatenating all interpretable_code for cells that should be migrated.
            -- Excludes cells with names containing ''_once_'' if they have already been executed.
            -- Includes comments before each block and special comments for excluded cells.
            -- Wraps everything in a single transaction
            SELECT
                ''BEGIN TRANSACTION;
    
    ''||
                ''CREATE TEMP TABLE IF NOT EXISTS "session_state_ephemeral" (
        "key" TEXT PRIMARY KEY NOT NULL,
        "value" TEXT NOT NULL
    );
    
    '' ||
                GROUP_CONCAT(
                  CASE
                      -- Case 1: Non-idempotent and already executed
                      WHEN c.is_idempotent = FALSE AND s.code_notebook_cell_id IS NOT NULL THEN
                          ''-- '' || c.notebook_name || ''.'' || c.cell_name || '' not included because it is non-idempotent and was already executed on '' || s.transitioned_at || ''
    ''
    
                      -- Case 2: Idempotent and not yet executed, idempotent and being reapplied, or non-idempotent and being run for the first time
                      ELSE
                          ''-- '' || c.notebook_name || ''.'' || c.cell_name || ''
    '' ||
                          CASE
                              -- First execution (non-idempotent or idempotent)
                              WHEN s.code_notebook_cell_id IS NULL THEN
                                  ''-- Executing for the first time.
    ''
    
                              -- Reapplying execution (idempotent)
                              ELSE
                                  ''-- Reapplying execution. Last executed on '' || s.transitioned_at || ''
    ''
                          END ||
                          c.interpretable_code || ''
    '' ||
                          ''INSERT INTO code_notebook_state (code_notebook_state_id, code_notebook_cell_id, from_state, to_state, transition_reason, created_at) '' ||
                          ''VALUES ('' ||
                          '''''''' || c.code_notebook_cell_id || ''__'' || strftime(''%Y%m%d%H%M%S'', ''now'') || '''''''' || '', '' ||
                          '''''''' || c.code_notebook_cell_id || '''''''' || '', '' ||
                          ''''''MIGRATION_CANDIDATE'''''' || '', '' ||
                          ''''''EXECUTED'''''' || '', '' ||
                          CASE
                              WHEN s.code_notebook_cell_id IS NULL THEN ''''''Migration''''''
                              ELSE ''''''Reapplication''''''
                          END || '', '' ||
                          ''CURRENT_TIMESTAMP'' || '')'' || ''
    '' ||
                          ''ON CONFLICT(code_notebook_cell_id, from_state, to_state) DO UPDATE SET updated_at = CURRENT_TIMESTAMP, '' ||
                            ''transition_reason = ''''Reapplied '' || datetime(''now'', ''localtime'') || '''''';'' || ''
    ''
                  END,
                  ''
    ''
                ) || ''
    
    COMMIT;'' AS migration_sql
            FROM
                code_notebook_sql_cell_migratable c
            LEFT JOIN
                code_notebook_state s
                ON c.code_notebook_cell_id = s.code_notebook_cell_id AND s.to_state = ''EXECUTED''
            ORDER BY
                c.cell_name;
  
DROP TABLE IF EXISTS surveilr_function_doc;
CREATE TABLE IF NOT EXISTS surveilr_function_doc (
    name TEXT PRIMARY KEY,
    description TEXT,
    parameters JSON,
    return_type TEXT,
    version TEXT
);

INSERT INTO surveilr_function_doc (name, description, parameters, return_type, version)
SELECT name, description, parameters, return_type, version
FROM surveilr_function_docs();
;', '98cb72e872d8d098ad741aa0eb33a49c101a166c', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W5RK7F4TVXJF549DMT', 'SQL', 'ConstructionSqlNotebook', 'v001_once_initialDDL', NULL, '-- code provenance: `RssdInitSqlNotebook.v001_once_initialDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)

CREATE TABLE IF NOT EXISTS "party_type" (
    "party_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "party" (
    "party_id" VARCHAR PRIMARY KEY NOT NULL,
    "party_type_id" ULID NOT NULL,
    "party_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_type_id") REFERENCES "party_type"("party_type_id")
);
CREATE TABLE IF NOT EXISTS "party_relation_type" (
    "party_relation_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "party_relation" (
    "party_relation_id" VARCHAR PRIMARY KEY NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "related_party_id" VARCHAR NOT NULL,
    "relation_type_id" ULID NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("related_party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("relation_type_id") REFERENCES "party_relation_type"("party_relation_type_id"),
    UNIQUE("party_id", "related_party_id", "relation_type_id")
);
CREATE TABLE IF NOT EXISTS "gender_type" (
    "gender_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "sex_type" (
    "sex_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "person_type" (
    "person_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "person" (
    "person_id" ULID PRIMARY KEY NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "person_type_id" ULID NOT NULL,
    "person_first_name" TEXT NOT NULL,
    "person_middle_name" TEXT,
    "person_last_name" TEXT NOT NULL,
    "previous_name" TEXT,
    "honorific_prefix" TEXT,
    "honorific_suffix" TEXT,
    "gender_id" ULID NOT NULL,
    "sex_id" ULID NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("person_type_id") REFERENCES "person_type"("person_type_id"),
    FOREIGN KEY("gender_id") REFERENCES "gender_type"("gender_type_id"),
    FOREIGN KEY("sex_id") REFERENCES "sex_type"("sex_type_id")
);
CREATE TABLE IF NOT EXISTS "organization" (
    "organization_id" ULID PRIMARY KEY NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "name" TEXT NOT NULL,
    "alias" TEXT,
    "description" TEXT,
    "license" TEXT NOT NULL,
    "federal_tax_id_num" TEXT,
    "registration_date" DATE NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "organization_role_type" (
    "organization_role_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "organization_role" (
    "organization_role_id" VARCHAR PRIMARY KEY NOT NULL,
    "person_id" VARCHAR NOT NULL,
    "organization_id" VARCHAR NOT NULL,
    "organization_role_type_id" ULID NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("person_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("organization_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("organization_role_type_id") REFERENCES "organization_role_type"("organization_role_type_id"),
    UNIQUE("person_id", "organization_id", "organization_role_type_id")
);
CREATE TABLE IF NOT EXISTS "device" (
    "device_id" VARCHAR PRIMARY KEY NOT NULL,
    "name" TEXT NOT NULL,
    "state" TEXT CHECK(json_valid(state)) NOT NULL,
    "boundary" TEXT NOT NULL,
    "segmentation" TEXT CHECK(json_valid(segmentation) OR segmentation IS NULL),
    "state_sysinfo" TEXT CHECK(json_valid(state_sysinfo) OR state_sysinfo IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("name", "state", "boundary")
);
CREATE TABLE IF NOT EXISTS "device_party_relationship" (
    "device_party_relationship_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    UNIQUE("device_id", "party_id")
);
CREATE TABLE IF NOT EXISTS "behavior" (
    "behavior_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "behavior_name" TEXT NOT NULL,
    "behavior_conf_json" TEXT CHECK(json_valid(behavior_conf_json)) NOT NULL,
    "assurance_schema_id" VARCHAR,
    "governance" TEXT CHECK(json_valid(governance) OR governance IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("assurance_schema_id") REFERENCES "assurance_schema"("assurance_schema_id"),
    UNIQUE("device_id", "behavior_name")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_resource_path_match_rule" (
    "ur_ingest_resource_path_match_rule_id" VARCHAR PRIMARY KEY NOT NULL,
    "namespace" TEXT NOT NULL,
    "regex" TEXT NOT NULL,
    "flags" TEXT NOT NULL,
    "nature" TEXT,
    "priority" TEXT,
    "description" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("namespace", "regex")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_resource_path_rewrite_rule" (
    "ur_ingest_resource_path_rewrite_rule_id" VARCHAR PRIMARY KEY NOT NULL,
    "namespace" TEXT NOT NULL,
    "regex" TEXT NOT NULL,
    "replace" TEXT NOT NULL,
    "priority" TEXT,
    "description" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("namespace", "regex", "replace")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session" (
    "ur_ingest_session_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "behavior_id" VARCHAR,
    "behavior_json" TEXT CHECK(json_valid(behavior_json) OR behavior_json IS NULL),
    "ingest_started_at" TIMESTAMPTZ NOT NULL,
    "ingest_finished_at" TIMESTAMPTZ,
    "session_agent" TEXT CHECK(json_valid(session_agent)) NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("behavior_id") REFERENCES "behavior"("behavior_id"),
    UNIQUE("device_id", "created_at")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_fs_path" (
    "ur_ingest_session_fs_path_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "root_path" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    UNIQUE("ingest_session_id", "root_path", "created_at")
);
CREATE TABLE IF NOT EXISTS "uniform_resource" (
    "uniform_resource_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_fs_path_id" VARCHAR,
    "ingest_session_imap_acct_folder_message" VARCHAR,
    "ingest_issue_acct_project_id" VARCHAR,
    "uri" TEXT NOT NULL,
    "content_digest" TEXT NOT NULL,
    "content" BLOB,
    "nature" TEXT,
    "size_bytes" INTEGER,
    "last_modified_at" TIMESTAMPTZ,
    "content_fm_body_attrs" TEXT CHECK(json_valid(content_fm_body_attrs) OR content_fm_body_attrs IS NULL),
    "frontmatter" TEXT CHECK(json_valid(frontmatter) OR frontmatter IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_fs_path_id") REFERENCES "ur_ingest_session_fs_path"("ur_ingest_session_fs_path_id"),
    FOREIGN KEY("ingest_session_imap_acct_folder_message") REFERENCES "ur_ingest_session_imap_acct_folder_message"("ur_ingest_session_imap_acct_folder_message_id"),
    FOREIGN KEY("ingest_issue_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id"),
    UNIQUE("device_id", "content_digest", "uri", "size_bytes")
);
CREATE TABLE IF NOT EXISTS "uniform_resource_transform" (
    "uniform_resource_transform_id" VARCHAR PRIMARY KEY NOT NULL,
    "uniform_resource_id" VARCHAR NOT NULL,
    "uri" TEXT NOT NULL,
    "content_digest" TEXT NOT NULL,
    "content" BLOB,
    "nature" TEXT,
    "size_bytes" INTEGER,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    UNIQUE("uniform_resource_id", "content_digest", "nature", "size_bytes")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_fs_path_entry" (
    "ur_ingest_session_fs_path_entry_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_fs_path_id" VARCHAR NOT NULL,
    "uniform_resource_id" VARCHAR,
    "file_path_abs" TEXT NOT NULL,
    "file_path_rel_parent" TEXT NOT NULL,
    "file_path_rel" TEXT NOT NULL,
    "file_basename" TEXT NOT NULL,
    "file_extn" TEXT,
    "captured_executable" TEXT CHECK(json_valid(captured_executable) OR captured_executable IS NULL),
    "ur_status" TEXT,
    "ur_diagnostics" TEXT CHECK(json_valid(ur_diagnostics) OR ur_diagnostics IS NULL),
    "ur_transformations" TEXT CHECK(json_valid(ur_transformations) OR ur_transformations IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_fs_path_id") REFERENCES "ur_ingest_session_fs_path"("ur_ingest_session_fs_path_id"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_task" (
    "ur_ingest_session_task_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "uniform_resource_id" VARCHAR,
    "captured_executable" TEXT CHECK(json_valid(captured_executable)) NOT NULL,
    "ur_status" TEXT,
    "ur_diagnostics" TEXT CHECK(json_valid(ur_diagnostics) OR ur_diagnostics IS NULL),
    "ur_transformations" TEXT CHECK(json_valid(ur_transformations) OR ur_transformations IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_imap_account" (
    "ur_ingest_session_imap_account_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "email" TEXT,
    "password" TEXT,
    "host" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    UNIQUE("ingest_session_id", "email")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_imap_acct_folder" (
    "ur_ingest_session_imap_acct_folder_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_account_id" VARCHAR NOT NULL,
    "folder_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_account_id") REFERENCES "ur_ingest_session_imap_account"("ur_ingest_session_imap_account_id"),
    UNIQUE("ingest_account_id", "folder_name")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_imap_acct_folder_message" (
    "ur_ingest_session_imap_acct_folder_message_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_imap_acct_folder_id" VARCHAR NOT NULL,
    "message" TEXT NOT NULL,
    "message_id" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "from" TEXT NOT NULL,
    "cc" TEXT CHECK(json_valid(cc)) NOT NULL,
    "bcc" TEXT CHECK(json_valid(bcc)) NOT NULL,
    "status" TEXT[] NOT NULL,
    "date" DATE,
    "email_references" TEXT CHECK(json_valid(email_references)) NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_imap_acct_folder_id") REFERENCES "ur_ingest_session_imap_acct_folder"("ur_ingest_session_imap_acct_folder_id"),
    UNIQUE("message", "message_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_account" (
    "ur_ingest_session_plm_account_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "provider" TEXT NOT NULL,
    "org_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    UNIQUE("provider", "org_name")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_acct_project" (
    "ur_ingest_session_plm_acct_project_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_account_id" VARCHAR NOT NULL,
    "parent_project_id" TEXT,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "id" TEXT,
    "key" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_account_id") REFERENCES "ur_ingest_session_plm_account"("ur_ingest_session_plm_account_id"),
    UNIQUE("name", "description")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_acct_project_issue" (
    "ur_ingest_session_plm_acct_project_issue_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ur_ingest_session_plm_acct_project_id" VARCHAR NOT NULL,
    "uniform_resource_id" VARCHAR,
    "issue_id" TEXT NOT NULL,
    "issue_number" INTEGER,
    "parent_issue_id" TEXT,
    "title" TEXT NOT NULL,
    "body" TEXT,
    "body_text" TEXT,
    "body_html" TEXT,
    "state" TEXT NOT NULL,
    "assigned_to" TEXT,
    "user" VARCHAR NOT NULL,
    "url" TEXT NOT NULL,
    "closed_at" TEXT,
    "issue_type_id" VARCHAR,
    "time_estimate" INTEGER,
    "aggregate_time_estimate" INTEGER,
    "time_original_estimate" INTEGER,
    "time_spent" INTEGER,
    "aggregate_time_spent" INTEGER,
    "aggregate_time_original_estimate" INTEGER,
    "workratio" INTEGER,
    "current_progress" INTEGER,
    "total_progress" INTEGER,
    "resolution_name" TEXT,
    "resolution_date" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ur_ingest_session_plm_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    FOREIGN KEY("user") REFERENCES "ur_ingest_session_plm_user"("ur_ingest_session_plm_user_id"),
    FOREIGN KEY("issue_type_id") REFERENCES "ur_ingest_session_plm_issue_type"("ur_ingest_session_plm_issue_type_id"),
    UNIQUE("title", "issue_id", "state", "assigned_to")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_acct_label" (
    "ur_ingest_session_plm_acct_label_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_id" VARCHAR NOT NULL,
    "ur_ingest_session_plm_acct_project_issue_id" VARCHAR NOT NULL,
    "label" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id"),
    FOREIGN KEY("ur_ingest_session_plm_acct_project_issue_id") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_milestone" (
    "ur_ingest_session_plm_milestone_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_id" VARCHAR NOT NULL,
    "title" TEXT NOT NULL,
    "milestone_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "html_url" TEXT NOT NULL,
    "open_issues" INTEGER,
    "closed_issues" INTEGER,
    "due_on" TIMESTAMPTZ,
    "closed_at" TIMESTAMPTZ,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_acct_relationship" (
    "ur_ingest_session_plm_acct_relationship_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_id_prime" VARCHAR NOT NULL,
    "ur_ingest_session_plm_acct_project_id_related" TEXT NOT NULL,
    "ur_ingest_session_plm_acct_project_issue_id_prime" VARCHAR NOT NULL,
    "ur_ingest_session_plm_acct_project_issue_id_related" TEXT NOT NULL,
    "relationship" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_id_prime") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id"),
    FOREIGN KEY("ur_ingest_session_plm_acct_project_issue_id_prime") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_user" (
    "ur_ingest_session_plm_user_id" VARCHAR PRIMARY KEY NOT NULL,
    "user_id" TEXT NOT NULL,
    "login" TEXT NOT NULL,
    "email" TEXT,
    "name" TEXT,
    "url" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("user_id", "login")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_comment" (
    "ur_ingest_session_plm_comment_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_issue_id" VARCHAR NOT NULL,
    "comment_id" TEXT NOT NULL,
    "node_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "body" TEXT,
    "body_text" TEXT,
    "body_html" TEXT,
    "user" VARCHAR NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_issue_id") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id"),
    FOREIGN KEY("user") REFERENCES "ur_ingest_session_plm_user"("ur_ingest_session_plm_user_id"),
    UNIQUE("comment_id", "url", "body")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_reaction" (
    "ur_ingest_session_plm_reaction_id" VARCHAR PRIMARY KEY NOT NULL,
    "reaction_id" TEXT NOT NULL,
    "reaction_type" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("reaction_type")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_issue_reaction" (
    "ur_ingest_session_plm_issue_reaction_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_plm_reaction_id" VARCHAR NOT NULL,
    "ur_ingest_plm_issue_id" VARCHAR NOT NULL,
    "count" INTEGER NOT NULL DEFAULT 1,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_plm_reaction_id") REFERENCES "ur_ingest_session_plm_reaction"("ur_ingest_session_plm_reaction_id"),
    FOREIGN KEY("ur_ingest_plm_issue_id") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id"),
    UNIQUE("ur_ingest_plm_issue_id", "ur_ingest_plm_reaction_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_issue_type" (
    "ur_ingest_session_plm_issue_type_id" VARCHAR PRIMARY KEY NOT NULL,
    "avatar_id" TEXT,
    "description" TEXT NOT NULL,
    "icon_url" TEXT NOT NULL,
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "subtask" BOOLEAN NOT NULL,
    "url" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("id", "name")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_attachment" (
    "ur_ingest_session_attachment_id" VARCHAR PRIMARY KEY NOT NULL,
    "uniform_resource_id" VARCHAR,
    "name" TEXT,
    "uri" TEXT NOT NULL,
    "content" BLOB,
    "nature" TEXT,
    "size" INTEGER,
    "checksum" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    UNIQUE("uniform_resource_id", "checksum", "nature", "size")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_udi_pgp_sql" (
    "ur_ingest_session_udi_pgp_sql_id" VARCHAR PRIMARY KEY NOT NULL,
    "sql" TEXT NOT NULL,
    "nature" TEXT NOT NULL,
    "content" BLOB,
    "behaviour" TEXT CHECK(json_valid(behaviour) OR behaviour IS NULL),
    "query_error" TEXT,
    "uniform_resource_id" VARCHAR,
    "ingest_session_id" VARCHAR,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    UNIQUE("sql", "ingest_session_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_nature" (
    "orchestration_nature_id" TEXT PRIMARY KEY NOT NULL,
    "nature" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("orchestration_nature_id", "nature")
);
CREATE TABLE IF NOT EXISTS "orchestration_session" (
    "orchestration_session_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "orchestration_nature_id" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "orch_started_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "orch_finished_at" TIMESTAMPTZ,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "args_json" TEXT CHECK(json_valid(args_json) OR args_json IS NULL),
    "diagnostics_json" TEXT CHECK(json_valid(diagnostics_json) OR diagnostics_json IS NULL),
    "diagnostics_md" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("orchestration_nature_id") REFERENCES "orchestration_nature"("orchestration_nature_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_entry" (
    "orchestration_session_entry_id" VARCHAR PRIMARY KEY NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "ingest_src" TEXT NOT NULL,
    "ingest_table_name" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_state" (
    "orchestration_session_state_id" VARCHAR PRIMARY KEY NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "session_entry_id" VARCHAR,
    "from_state" TEXT NOT NULL,
    "to_state" TEXT NOT NULL,
    "transition_result" TEXT CHECK(json_valid(transition_result) OR transition_result IS NULL),
    "transition_reason" TEXT,
    "transitioned_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id"),
    FOREIGN KEY("session_entry_id") REFERENCES "orchestration_session_entry"("orchestration_session_entry_id"),
    UNIQUE("orchestration_session_state_id", "from_state", "to_state")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_exec" (
    "orchestration_session_exec_id" VARCHAR PRIMARY KEY NOT NULL,
    "exec_nature" TEXT NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "session_entry_id" VARCHAR,
    "parent_exec_id" VARCHAR,
    "namespace" TEXT,
    "exec_identity" TEXT,
    "exec_code" TEXT NOT NULL,
    "exec_status" INTEGER NOT NULL,
    "input_text" TEXT,
    "exec_error_text" TEXT,
    "output_text" TEXT,
    "output_nature" TEXT CHECK(json_valid(output_nature) OR output_nature IS NULL),
    "narrative_md" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id"),
    FOREIGN KEY("session_entry_id") REFERENCES "orchestration_session_entry"("orchestration_session_entry_id"),
    FOREIGN KEY("parent_exec_id") REFERENCES "orchestration_session_exec"("orchestration_session_exec_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_issue" (
    "orchestration_session_issue_id" UUID PRIMARY KEY NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "session_entry_id" VARCHAR,
    "issue_type" TEXT NOT NULL,
    "issue_message" TEXT NOT NULL,
    "issue_row" INTEGER,
    "issue_column" TEXT,
    "invalid_value" TEXT,
    "remediation" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id"),
    FOREIGN KEY("session_entry_id") REFERENCES "orchestration_session_entry"("orchestration_session_entry_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_issue_relation" (
    "orchestration_session_issue_relation_id" UUID PRIMARY KEY NOT NULL,
    "issue_id_prime" UUID NOT NULL,
    "issue_id_rel" TEXT NOT NULL,
    "relationship_nature" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("issue_id_prime") REFERENCES "orchestration_session_issue"("orchestration_session_issue_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_log" (
    "orchestration_session_log_id" UUID PRIMARY KEY NOT NULL,
    "category" TEXT,
    "parent_exec_id" UUID,
    "content" TEXT NOT NULL,
    "sibling_order" INTEGER,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("parent_exec_id") REFERENCES "orchestration_session_log"("orchestration_session_log_id")
);
CREATE TABLE IF NOT EXISTS "uniform_resource_graph" (
    "name" VARCHAR PRIMARY KEY NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL)
);
CREATE TABLE IF NOT EXISTS "uniform_resource_edge" (
    "graph_name" VARCHAR NOT NULL,
    "nature" TEXT NOT NULL,
    "node_id" TEXT NOT NULL,
    "uniform_resource_id" VARCHAR NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("graph_name") REFERENCES "uniform_resource_graph"("name"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    UNIQUE("graph_name", "nature", "node_id", "uniform_resource_id")
);
CREATE TABLE IF NOT EXISTS "surveilr_osquery_ms_node" (
    "surveilr_osquery_ms_node_id" VARCHAR PRIMARY KEY NOT NULL,
    "node_key" TEXT NOT NULL,
    "host_identifier" TEXT NOT NULL,
    "tls_cert_subject" TEXT,
    "os_version" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "last_seen" TIMESTAMP NOT NULL,
    "status" TEXT NOT NULL DEFAULT ''active'',
    "osquery_version" TEXT,
    "osquery_build_platform" TEXT NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "behavior_id" VARCHAR,
    "accelerate" INTEGER NOT NULL DEFAULT 60,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("behavior_id") REFERENCES "behavior"("behavior_id"),
    UNIQUE("host_identifier", "os_version"),
    UNIQUE("node_key")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_osquery_ms_log" (
    "ur_ingest_session_osquery_ms_log_id" VARCHAR PRIMARY KEY NOT NULL,
    "node_key" TEXT NOT NULL,
    "log_type" TEXT NOT NULL,
    "log_data" TEXT CHECK(json_valid(log_data)) NOT NULL,
    "applied_jq_filters" TEXT CHECK(json_valid(applied_jq_filters) OR applied_jq_filters IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("node_key") REFERENCES "surveilr_osquery_ms_node"("node_key"),
    UNIQUE("node_key", "log_type", "log_data")
);
CREATE TABLE IF NOT EXISTS "osquery_policy" (
    "osquery_policy_id" VARCHAR PRIMARY KEY NOT NULL,
    "policy_group" TEXT,
    "policy_name" TEXT NOT NULL,
    "osquery_code" TEXT NOT NULL,
    "policy_description" TEXT NOT NULL,
    "policy_pass_label" TEXT NOT NULL DEFAULT ''Pass'',
    "policy_fail_label" TEXT NOT NULL DEFAULT ''Fail'',
    "policy_pass_remarks" TEXT,
    "policy_fail_remarks" TEXT,
    "osquery_platforms" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("policy_name", "osquery_code")
);
CREATE TABLE IF NOT EXISTS "surveilr_table_size" (
    "table_name" VARCHAR PRIMARY KEY NOT NULL,
    "table_size_mb" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "surveilr_osquery_ms_distributed_query" (
    "query_id" VARCHAR PRIMARY KEY NOT NULL,
    "node_key" TEXT NOT NULL,
    "query_name" TEXT NOT NULL,
    "query_sql" TEXT NOT NULL,
    "discovery_query" TEXT,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("node_key") REFERENCES "surveilr_osquery_ms_node"("node_key")
);
CREATE TABLE IF NOT EXISTS "surveilr_osquery_ms_distributed_result" (
    "surveilr_osquery_ms_distributed_result_id" VARCHAR PRIMARY KEY NOT NULL,
    "query_id" VARCHAR NOT NULL,
    "node_key" TEXT NOT NULL,
    "results" TEXT CHECK(json_valid(results)) NOT NULL,
    "status_code" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("query_id") REFERENCES "surveilr_osquery_ms_distributed_query"("query_id"),
    FOREIGN KEY("node_key") REFERENCES "surveilr_osquery_ms_node"("node_key")
);
CREATE TABLE IF NOT EXISTS "surveilr_osquery_ms_carve" (
    "surveilr_osquery_ms_carve_id" VARCHAR PRIMARY KEY NOT NULL,
    "node_key" TEXT NOT NULL,
    "session_id" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "carve_guid" TEXT NOT NULL,
    "carve_size" INTEGER NOT NULL,
    "block_count" INTEGER NOT NULL,
    "block_size" INTEGER NOT NULL,
    "received_blocks" INTEGER NOT NULL DEFAULT 0,
    "carve_path" TEXT,
    "status" TEXT NOT NULL,
    "start_time" TIMESTAMPTZ NOT NULL,
    "completion_time" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("node_key") REFERENCES "surveilr_osquery_ms_node"("node_key"),
    UNIQUE("session_id")
);

CREATE INDEX IF NOT EXISTS "idx_party__party_type_id__party_name" ON "party"("party_type_id", "party_name");
CREATE INDEX IF NOT EXISTS "idx_party_relation__party_id__related_party_id__relation_type_id" ON "party_relation"("party_id", "related_party_id", "relation_type_id");
CREATE INDEX IF NOT EXISTS "idx_organization_role__person_id__organization_id__organization_role_type_id" ON "organization_role"("person_id", "organization_id", "organization_role_type_id");
CREATE INDEX IF NOT EXISTS "idx_device__name__state" ON "device"("name", "state");
CREATE INDEX IF NOT EXISTS "idx_device_party_relationship__device_id__party_id" ON "device_party_relationship"("device_id", "party_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_fs_path__ingest_session_id__root_path" ON "ur_ingest_session_fs_path"("ingest_session_id", "root_path");
CREATE INDEX IF NOT EXISTS "idx_uniform_resource__device_id__uri" ON "uniform_resource"("device_id", "uri");
CREATE INDEX IF NOT EXISTS "idx_uniform_resource_transform__uniform_resource_id__content_digest" ON "uniform_resource_transform"("uniform_resource_id", "content_digest");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_fs_path_entry__ingest_session_id__file_path_abs" ON "ur_ingest_session_fs_path_entry"("ingest_session_id", "file_path_abs");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_task__ingest_session_id" ON "ur_ingest_session_task"("ingest_session_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_imap_acct_folder__ingest_session_id__folder_name" ON "ur_ingest_session_imap_acct_folder"("ingest_session_id", "folder_name");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_imap_acct_folder_message__ingest_session_id" ON "ur_ingest_session_imap_acct_folder_message"("ingest_session_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_imap_account__ingest_session_id__email" ON "ur_ingest_session_imap_account"("ingest_session_id", "email");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_account__provider__org_name" ON "ur_ingest_session_plm_account"("provider", "org_name");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_acct_project__name__description" ON "ur_ingest_session_plm_acct_project"("name", "description");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_acct_project_issue__title__issue_id__state__assigned_to" ON "ur_ingest_session_plm_acct_project_issue"("title", "issue_id", "state", "assigned_to");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_acct_label__ur_ingest_session_plm_acct_project_issue_id" ON "ur_ingest_session_plm_acct_label"("ur_ingest_session_plm_acct_project_issue_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_milestone__ur_ingest_session_plm_acct_project_id" ON "ur_ingest_session_plm_milestone"("ur_ingest_session_plm_acct_project_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_acct_relationship__ur_ingest_session_plm_acct_project_id_prime" ON "ur_ingest_session_plm_acct_relationship"("ur_ingest_session_plm_acct_project_id_prime");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_user__user_id__login" ON "ur_ingest_session_plm_user"("user_id", "login");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_comment__ur_ingest_session_plm_acct_project_issue_id" ON "ur_ingest_session_plm_comment"("ur_ingest_session_plm_acct_project_issue_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_reaction__ur_ingest_session_plm_reaction_id" ON "ur_ingest_session_plm_reaction"("ur_ingest_session_plm_reaction_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_issue_reaction__ur_ingest_session_plm_issue_reaction_id" ON "ur_ingest_session_plm_issue_reaction"("ur_ingest_session_plm_issue_reaction_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_issue_type__id" ON "ur_ingest_session_plm_issue_type"("id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_attachment__uniform_resource_id__content" ON "ur_ingest_session_attachment"("uniform_resource_id", "content");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_udi_pgp_sql__ingest_session_id" ON "ur_ingest_session_udi_pgp_sql"("ingest_session_id");
CREATE INDEX IF NOT EXISTS "idx_orchestration_nature__orchestration_nature_id__nature" ON "orchestration_nature"("orchestration_nature_id", "nature");
CREATE INDEX IF NOT EXISTS "idx_uniform_resource_edge__uniform_resource_id" ON "uniform_resource_edge"("uniform_resource_id");
CREATE INDEX IF NOT EXISTS "idx_surveilr_osquery_ms_node__node_key" ON "surveilr_osquery_ms_node"("node_key");', 'b422d6dfca0ca56100d2f74dde415e7971cac944', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W59QWPCXRTHZM6TY45', 'SQL', 'ConstructionSqlNotebook', 'session_ephemeral_table', NULL, 'CREATE TEMP TABLE IF NOT EXISTS "session_state_ephemeral" (
    "key" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL
);', 'b739acd000cf37091bbb365085506f975345351d', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W5SPNMR3XZJ0VZ7VM5', 'SQL', 'ConstructionSqlNotebook', 'surveilr_table_size', NULL, 'CREATE TABLE IF NOT EXISTS surveilr_table_size (
    table_name TEXT PRIMARY KEY,
    table_size_mb REAL
);

DELETE FROM surveilr_table_size;
INSERT INTO surveilr_table_size (table_name, table_size_mb)
SELECT name, 
      ROUND(SUM(pgsize) / (1024.0 * 1024), 2)
FROM dbstat
GROUP BY name;', '0213397f35c9eaf525cce0fa6276a02243f5d877', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W5R9J94GNHYJFE3TAZ', 'SQL', 'ConstructionSqlNotebook', 'v001_seedDML', NULL, 'INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''ignore .git and node_modules paths'', ''default'', ''/(\.git|node_modules)/'', ''IGNORE_RESOURCE'', NULL, NULL, ''Ignore any entry with `/.git/` or `/node_modules/` in the path.'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''typical ingestion extensions'', ''default'', ''\.(?P<nature>md|mdx|html|json|jsonc|puml|txt|toml|yml|xml|tap|csv|tsv|ssv|psv|tm7|pdf|docx|doc|pptx|ppt|xlsx|xls)$'', ''CONTENT_ACQUIRABLE'', ''?P<nature>'', NULL, ''Ingest the content for md, mdx, html, json, jsonc, puml, txt, toml, and yml extensions. Assume the nature is the same as the extension.'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-[NATURE] style capturable executable'', ''default'', ''surveilr\[(?P<nature>[^\]]*)\]'', ''CAPTURABLE_EXECUTABLE'', ''?P<nature>'', NULL, ''Any entry with `surveilr-[XYZ]` in the path will be treated as a capturable executable extracting `XYZ` as the nature'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-SQL capturable executable'', ''default'', ''surveilr-SQL'', ''CAPTURABLE_EXECUTABLE | CAPTURABLE_SQL'', NULL, NULL, ''Any entry with surveilr-SQL in the path will be treated as a capturable SQL executable and allow execution of the SQL'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');

INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.plantuml -> .puml'', ''default'', ''(\.plantuml)$'', ''.puml'', NULL, ''Treat .plantuml as .puml files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.text -> .txt'', ''default'', ''(\.text)$'', ''.txt'', NULL, ''Treat .text as .txt files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.yaml -> .yml'', ''default'', ''(\.yaml)$'', ''.yml'', NULL, ''Treat .yaml as .yml files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

INSERT INTO "party_type" ("party_type_id", "code", "value", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), ''ORGANIZATION'', ''Organization'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "party_type" ("party_type_id", "code", "value", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), ''PERSON'', ''Person'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-csv'', ''Transform CSV'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-xml'', ''Transform XML'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-html'', ''Transform HTML'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

INSERT INTO "uniform_resource_graph" ("name", "elaboration") VALUES (''filesystem'', ''{}'') ON CONFLICT DO NOTHING;
INSERT INTO "uniform_resource_graph" ("name", "elaboration") VALUES (''imap'', ''{}'') ON CONFLICT DO NOTHING;
INSERT INTO "uniform_resource_graph" ("name", "elaboration") VALUES (''plm'', ''{}'') ON CONFLICT DO NOTHING;
INSERT INTO "uniform_resource_graph" ("name", "elaboration") VALUES (''osquery-ms'', ''{}'') ON CONFLICT DO NOTHING;

DROP VIEW IF EXISTS "plm_graph";
CREATE VIEW IF NOT EXISTS "plm_graph" AS
    SELECT
        ure.graph_name,
        ure.nature,
        ur.uniform_resource_id,
        ur.uri,
        ur_ingest_plm.ur_ingest_session_plm_acct_project_issue_id,
        ur_ingest_plm.issue_id,
        ur_ingest_plm.ur_ingest_session_plm_acct_project_id as project_id,
        ur_ingest_plm.title,
        ur_ingest_plm.body
    FROM
        uniform_resource_edge ure
    JOIN
        uniform_resource ur ON ure.uniform_resource_id = ur.uniform_resource_id
    JOIN
        ur_ingest_session_plm_acct_project_issue ur_ingest_plm ON ure.node_id = ur_ingest_plm.ur_ingest_session_plm_acct_project_issue_id
    WHERE
        ure.graph_name = ''plm'';
          ;
DROP VIEW IF EXISTS "imap_graph";
CREATE VIEW IF NOT EXISTS "imap_graph" AS
      SELECT
        ure.graph_name,
        ur.uniform_resource_id,
        ur.nature,
        ur.uri,
        ur.content,
        ur_ingest_imap.ur_ingest_session_imap_acct_folder_message_id,
        ur_ingest_imap.ingest_imap_acct_folder_id,
        ur_ingest_imap.message_id
    FROM
        uniform_resource_edge ure
    JOIN
        uniform_resource ur ON ure.uniform_resource_id = ur.uniform_resource_id
    JOIN
        ur_ingest_session_imap_acct_folder_message ur_ingest_imap ON ure.node_id = ur_ingest_imap.ur_ingest_session_imap_acct_folder_message_id
    WHERE
        ure.graph_name = ''imap'';
    ;
DROP VIEW IF EXISTS "filesystem_graph";
CREATE VIEW IF NOT EXISTS "filesystem_graph" AS
    SELECT
        ure.graph_name,
        ur.uniform_resource_id,
        ur.nature,
        ur.uri,
        ur_ingest_fs_path.ur_ingest_session_fs_path_id,
        ur_ingest_fs_path.root_path
    FROM
        uniform_resource_edge ure
    JOIN
        uniform_resource ur ON ure.uniform_resource_id = ur.uniform_resource_id
    JOIN
        ur_ingest_session_fs_path ur_ingest_fs_path ON ure.node_id = ur_ingest_fs_path.ur_ingest_session_fs_path_id
    WHERE
        ure.graph_name = ''filesystem'';
          ;

INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Ad tracking is limited (macOS)'', ''SELECT CASE WHEN EXISTS (SELECT 1 FROM managed_policies WHERE domain=''''com.apple.AdLib'''' AND name=''''forceLimitAdTracking'''' AND value=''''1'''' LIMIT 1) THEN ''''true'''' ELSE ''''false'''' END AS policy_result;'', ''Checks that a mobile device management (MDM) solution configures the Mac to limit advertisement tracking.'', ''Pass'', ''Fail'', NULL, ''Contact your IT administrator to ensure your Mac is receiving a profile that disables advertisement tracking.'', ''["macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Antivirus healthy (Linux)'', ''SELECT score FROM (SELECT CASE WHEN COUNT(*) = 2 THEN ''''true'''' ELSE ''''false'''' END AS score FROM processes WHERE (name = ''''clamd'''') OR (name = ''''freshclam'''')) WHERE score = ''''true'''';'', ''Checks that both ClamAV''''s daemon and its updater service (freshclam) are running.'', ''Pass'', ''Fail'', NULL, ''Ensure ClamAV and Freshclam are installed and running.'', ''["linux","windows","macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Antivirus healthy (macOS)'', ''SELECT score FROM (SELECT case when COUNT(*) = 2 then 1 ELSE 0 END AS score FROM plist WHERE (key = ''''CFBundleShortVersionString'''' AND path = ''''/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Info.plist'''' AND value>=2162) OR (key = ''''CFBundleShortVersionString'''' AND path = ''''/Library/Apple/System/Library/CoreServices/MRT.app/Contents/Info.plist'''' and value>=1.93)) WHERE score == 1;'', ''Checks the version of Malware Removal Tool (MRT) and the built-in macOS AV (Xprotect). Replace version numbers with the latest version regularly.'', ''Pass'', ''Fail'', NULL, ''To enable automatic security definition updates, on the failing device, select System Preferences > Software Update > Advanced > Turn on Install system data files and security updates.'', ''["macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Antivirus healthy (Windows)'', ''SELECT 1 from windows_security_center wsc CROSS JOIN windows_security_products wsp WHERE antivirus = ''''Good'''' AND type = ''''Antivirus'''' AND signatures_up_to_date=1;'', ''Checks the status of antivirus and signature updates from the Windows Security Center.'', ''Pass'', ''Fail'', NULL, ''Ensure Windows Defender or your third-party antivirus is running, up to date, and visible in the Windows Security Center.'', ''["windows"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Automatic installation of application updates is enabled (macOS)'', ''SELECT 1 FROM managed_policies WHERE domain=''''com.apple.SoftwareUpdate'''' AND name=''''AutomaticallyInstallAppUpdates'''' AND value=1 LIMIT 1;'', ''Checks that a mobile device management (MDM) solution configures the Mac to automatically install updates to App Store applications.'', ''Pass'', ''Fail'', NULL, ''Contact your IT administrator to ensure your Mac is receiving a profile that enables automatic installation of application updates.'', ''["macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Automatic installation of operating system updates is enabled (macOS)'', ''SELECT 1 FROM managed_policies WHERE domain=''''com.apple.SoftwareUpdate'''' AND name=''''AutomaticallyInstallMacOSUpdates'''' AND value=1 LIMIT 1;'', ''Checks that a mobile device management (MDM) solution configures the Mac to automatically install operating system updates.'', ''Pass'', ''Fail'', NULL, ''Contact your IT administrator to ensure your Mac is receiving a profile that enables automatic installation of operating system updates.'', ''["macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Ensure ''''Minimum password length'''' is set to ''''14 or more characters'''''', ''SELECT 1 FROM security_profile_info WHERE minimum_password_length >= 14;'', ''This policy setting determines the least number of characters that make up a password for a user account.'', ''Pass'', ''Fail'', NULL, ''Automatic method:
Ask your system administrator to establish the recommended configuration via GP, set the following UI path to 14 or more characters
''''Computer ConfigurationPoliciesWindows SettingsSecurity SettingsAccount PoliciesPassword PolicyMinimum password length'''''', ''["windows"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;', '5feb5b3fc2a9da3baf805c97a0901d89ef76d0c0', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W669Y844S8299FB9C3', 'AI LLM Prompt', 'rssd-init', 'understand notebooks schema', NULL, 'Understand the following structure of an SQLite database designed to store code notebooks and execution kernels.
The database comprises three main tables: ''code_notebook_kernel'', ''code_notebook_cell'', and ''code_notebook_state''.

1. ''code_notebook_kernel'': A Notebook is a group of Cells. A kernel is a computational engine that executes the code contained in a notebook cell.
Each notebook is associated with a kernel of a specific programming language or code transformer which can interpret
code and produce a result. For example, a SQL notebook might use a SQLite kernel for running SQL code and an AI Prompt
might prepare AI prompts for LLMs.

2. ''code_notebook_cell'': Each Notebook is divided into cells, which are individual units of interpretable code.
Each cell is linked to a kernel in the ''code_notebook_kernel'' table via ''notebook_kernel_id''.
The content of Cells depends on the Notebook Kernel and contain the source code to be
executed by the Notebook''s Kernel. The output of the code (text, graphics, etc.) can be
stateless or may be stateful and store its results and state transitions in code_notebook_state.
Notebooks can have multiple versions of cells, where the interpretable_code and other metadata
may be updated over time. Code notebook cells are unique for notebook_name, cell_name and
interpretable_code_hash which means there may be "duplicate" cells when interpretable_code
has been edited and updated over time.

3. ''code_notebook_state'': Records the state of a notebook''s cells'' executions, computations, and results for Kernels that are stateful.
For example, a SQL Notebook Cell that creates tables should only be run once (meaning it''s stateful).
Other Kernels might store results for functions and output defined in one cell can be used in later cells.
Each record links to a cell in the ''code_notebook_cell'' table and includes information about the state transition,
such as the previous and new states, transition reason, and timestamps. Surveilr tracks "migratable" SQL by
looking in a special notebook called "ConstructionSqlNotebook" and any cells in that notebook are "candidates"
for migration. Candidates that do not have a ''EXECUTED'' in the state table mean that specific cell has not been
"migrated" yet.

The relationships are as follows:
- Each cell in ''code_notebook_cell'' is associated with a kernel in ''code_notebook_kernel''.
- The ''code_notebook_state'' table tracks changes in the state of each cell, linking back to the ''code_notebook_cell'' table.

Use the following SQLite tables and views to generate SQL queries that interact with these tables and once you understand them let me know so I can ask you for help:

-- code provenance: `RssdInitSqlNotebook.bootstrapDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
INSERT INTO "session_state_ephemeral" ("key", "value") VALUES (''current_user'', ''runner'') ON CONFLICT DO UPDATE SET value = excluded.value;
INSERT INTO "session_state_ephemeral" ("key", "value") VALUES (''current_user_name'', ''UNKNOWN'') ON CONFLICT DO UPDATE SET value = excluded.value;

CREATE TABLE IF NOT EXISTS "assurance_schema" (
    "assurance_schema_id" VARCHAR PRIMARY KEY NOT NULL,
    "assurance_type" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "code_json" TEXT CHECK(json_valid(code_json) OR code_json IS NULL),
    "governance" TEXT CHECK(json_valid(governance) OR governance IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "code_notebook_kernel" (
    "code_notebook_kernel_id" VARCHAR PRIMARY KEY NOT NULL,
    "kernel_name" TEXT NOT NULL,
    "description" TEXT,
    "mime_type" TEXT,
    "file_extn" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "governance" TEXT CHECK(json_valid(governance) OR governance IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("kernel_name")
);
CREATE TABLE IF NOT EXISTS "code_notebook_cell" (
    "code_notebook_cell_id" VARCHAR PRIMARY KEY NOT NULL,
    "notebook_kernel_id" VARCHAR NOT NULL,
    "notebook_name" TEXT NOT NULL,
    "cell_name" TEXT NOT NULL,
    "cell_governance" TEXT CHECK(json_valid(cell_governance) OR cell_governance IS NULL),
    "interpretable_code" TEXT NOT NULL,
    "interpretable_code_hash" TEXT NOT NULL,
    "description" TEXT,
    "arguments" TEXT CHECK(json_valid(arguments) OR arguments IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("notebook_kernel_id") REFERENCES "code_notebook_kernel"("code_notebook_kernel_id"),
    UNIQUE("notebook_name", "cell_name", "interpretable_code_hash")
);
CREATE TABLE IF NOT EXISTS "code_notebook_state" (
    "code_notebook_state_id" VARCHAR PRIMARY KEY NOT NULL,
    "code_notebook_cell_id" VARCHAR NOT NULL,
    "from_state" TEXT NOT NULL,
    "to_state" TEXT NOT NULL,
    "transition_result" TEXT CHECK(json_valid(transition_result) OR transition_result IS NULL),
    "transition_reason" TEXT,
    "transitioned_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("code_notebook_cell_id") REFERENCES "code_notebook_cell"("code_notebook_cell_id"),
    UNIQUE("code_notebook_cell_id", "from_state", "to_state")
);



DROP VIEW IF EXISTS "code_notebook_cell_versions";
CREATE VIEW IF NOT EXISTS "code_notebook_cell_versions" AS
      -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
      -- All cells and how many different versions of each cell are available
      SELECT notebook_name,
            notebook_kernel_id,
            cell_name,
            COUNT(*) OVER(PARTITION BY notebook_name, cell_name) AS versions,
            code_notebook_cell_id
        FROM code_notebook_cell
    ORDER BY notebook_name, cell_name;
DROP VIEW IF EXISTS "code_notebook_cell_latest";
CREATE VIEW IF NOT EXISTS "code_notebook_cell_latest" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- Retrieve the latest version of each code_notebook_cell.
    -- Notebooks can have multiple versions of cells, where the interpretable_code and other metadata may be updated over time.
    -- The latest record is determined by the most recent COALESCE(updated_at, created_at) timestamp.
    SELECT
        c.code_notebook_cell_id,    -- Selects the unique ID of the notebook cell
        c.notebook_kernel_id,       -- References the kernel associated with this cell
        c.notebook_name,            -- The name of the notebook containing this cell
        c.cell_name,                -- The name of the cell within the notebook
        c.interpretable_code,       -- The latest interpretable code associated with the cell
        c.interpretable_code_hash,  -- Hash of the latest interpretable code
        c.description,              -- Description of the cell''s purpose or content
        c.cell_governance,          -- Governance details for the cell (if any)
        c.arguments,                -- Arguments or parameters related to the cell''s execution
        c.activity_log,             -- Log of activities related to this cell
        COALESCE(c.updated_at, c.created_at) AS version_timestamp  -- The latest timestamp (updated or created)
    FROM (
        SELECT
            code_notebook_cell_id,
            notebook_kernel_id,
            notebook_name,
            cell_name,
            interpretable_code,
            interpretable_code_hash,
            description,
            cell_governance,
            arguments,
            activity_log,
            updated_at,
            created_at,
            ROW_NUMBER() OVER (
                PARTITION BY code_notebook_cell_id
                ORDER BY COALESCE(updated_at, created_at) DESC  -- Orders by the latest timestamp
            ) AS rn
        FROM
            code_notebook_cell
    ) c WHERE c.rn = 1;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable_version";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable_version" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All cells that are candidates for migration (including duplicates)
    SELECT c.code_notebook_cell_id,
          c.notebook_name,
          c.cell_name,
          c.interpretable_code,
          c.interpretable_code_hash,
          CASE WHEN c.cell_name LIKE ''%_once_%'' THEN FALSE ELSE TRUE END AS is_idempotent,
          COALESCE(c.updated_at, c.created_at) version_timestamp
      FROM code_notebook_cell c
    WHERE c.notebook_name = ''ConstructionSqlNotebook''
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All cells that are candidates for migration (latest only)
    SELECT c.*,
           CASE WHEN c.cell_name LIKE ''%_once_%'' THEN FALSE ELSE TRUE END AS is_idempotent
      FROM code_notebook_cell_latest c
    WHERE c.notebook_name = ''ConstructionSqlNotebook''
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable_state";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable_state" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All cells that are candidates for migration (latest only)
    SELECT
        c.*,                  -- All columns from the code_notebook_sql_cell_migratable view
        s.from_state,         -- The state the cell transitioned from
        s.to_state,           -- The state the cell transitioned to
        s.transition_reason,  -- The reason for the state transition
        s.transition_result,  -- The result of the state transition
        s.transitioned_at     -- The timestamp of the state transition
    FROM
        code_notebook_sql_cell_migratable c
    JOIN
        code_notebook_state s
        ON c.code_notebook_cell_id = s.code_notebook_cell_id
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_sql_cell_migratable_not_executed";
CREATE VIEW IF NOT EXISTS "code_notebook_sql_cell_migratable_not_executed" AS
    -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
    -- All latest migratable cells that have not yet been "executed" (based on the code_notebook_state table)
    SELECT c.*
      FROM code_notebook_sql_cell_migratable c
      LEFT JOIN code_notebook_state s
        ON c.code_notebook_cell_id = s.code_notebook_cell_id AND s.to_state = ''EXECUTED''
      WHERE s.code_notebook_cell_id IS NULL
    ORDER BY c.cell_name;
DROP VIEW IF EXISTS "code_notebook_migration_sql";
CREATE VIEW IF NOT EXISTS "code_notebook_migration_sql" AS
    
            -- code provenance: `RssdInitSqlNotebook.notebookBusinessLogicViews` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
            -- Creates a dynamic migration script by concatenating all interpretable_code for cells that should be migrated.
            -- Excludes cells with names containing ''_once_'' if they have already been executed.
            -- Includes comments before each block and special comments for excluded cells.
            -- Wraps everything in a single transaction
            SELECT
                ''BEGIN TRANSACTION;
    
    ''||
                ''CREATE TEMP TABLE IF NOT EXISTS "session_state_ephemeral" (
        "key" TEXT PRIMARY KEY NOT NULL,
        "value" TEXT NOT NULL
    );
    
    '' ||
                GROUP_CONCAT(
                  CASE
                      -- Case 1: Non-idempotent and already executed
                      WHEN c.is_idempotent = FALSE AND s.code_notebook_cell_id IS NOT NULL THEN
                          ''-- '' || c.notebook_name || ''.'' || c.cell_name || '' not included because it is non-idempotent and was already executed on '' || s.transitioned_at || ''
    ''
    
                      -- Case 2: Idempotent and not yet executed, idempotent and being reapplied, or non-idempotent and being run for the first time
                      ELSE
                          ''-- '' || c.notebook_name || ''.'' || c.cell_name || ''
    '' ||
                          CASE
                              -- First execution (non-idempotent or idempotent)
                              WHEN s.code_notebook_cell_id IS NULL THEN
                                  ''-- Executing for the first time.
    ''
    
                              -- Reapplying execution (idempotent)
                              ELSE
                                  ''-- Reapplying execution. Last executed on '' || s.transitioned_at || ''
    ''
                          END ||
                          c.interpretable_code || ''
    '' ||
                          ''INSERT INTO code_notebook_state (code_notebook_state_id, code_notebook_cell_id, from_state, to_state, transition_reason, created_at) '' ||
                          ''VALUES ('' ||
                          '''''''' || c.code_notebook_cell_id || ''__'' || strftime(''%Y%m%d%H%M%S'', ''now'') || '''''''' || '', '' ||
                          '''''''' || c.code_notebook_cell_id || '''''''' || '', '' ||
                          ''''''MIGRATION_CANDIDATE'''''' || '', '' ||
                          ''''''EXECUTED'''''' || '', '' ||
                          CASE
                              WHEN s.code_notebook_cell_id IS NULL THEN ''''''Migration''''''
                              ELSE ''''''Reapplication''''''
                          END || '', '' ||
                          ''CURRENT_TIMESTAMP'' || '')'' || ''
    '' ||
                          ''ON CONFLICT(code_notebook_cell_id, from_state, to_state) DO UPDATE SET updated_at = CURRENT_TIMESTAMP, '' ||
                            ''transition_reason = ''''Reapplied '' || datetime(''now'', ''localtime'') || '''''';'' || ''
    ''
                  END,
                  ''
    ''
                ) || ''
    
    COMMIT;'' AS migration_sql
            FROM
                code_notebook_sql_cell_migratable c
            LEFT JOIN
                code_notebook_state s
                ON c.code_notebook_cell_id = s.code_notebook_cell_id AND s.to_state = ''EXECUTED''
            ORDER BY
                c.cell_name;
  
DROP TABLE IF EXISTS surveilr_function_doc;
CREATE TABLE IF NOT EXISTS surveilr_function_doc (
    name TEXT PRIMARY KEY,
    description TEXT,
    parameters JSON,
    return_type TEXT,
    version TEXT
);

INSERT INTO surveilr_function_doc (name, description, parameters, return_type, version)
SELECT name, description, parameters, return_type, version
FROM surveilr_function_docs();
;', '2c684647147ba540c82c3467da596c985ff39eab', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3WBBJWP0H8SGZY5SQVK', 'AI LLM Prompt', 'rssd-init', 'understand service schema', NULL, 'Understand the following structure of an SQLite database designed to store cybersecurity and compliance data for files in a file system.
The database is designed to store devices in the ''device'' table and entities called ''resources'' stored in the immutable append-only
''uniform_resource'' table. Each time files are "walked" they are stored in ingestion session and link back to ''uniform_resource''. Because all
tables are generally append only and immutable it means that the ingest_session_fs_path_entry table can be used for revision control
and historical tracking of file changes.

Use the following SQLite Schema to generate SQL queries that interact with these tables and once you understand them let me know so I can ask you for help:

-- code provenance: `RssdInitSqlNotebook.v001_once_initialDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)

CREATE TABLE IF NOT EXISTS "party_type" (
    "party_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "party" (
    "party_id" VARCHAR PRIMARY KEY NOT NULL,
    "party_type_id" ULID NOT NULL,
    "party_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_type_id") REFERENCES "party_type"("party_type_id")
);
CREATE TABLE IF NOT EXISTS "party_relation_type" (
    "party_relation_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "party_relation" (
    "party_relation_id" VARCHAR PRIMARY KEY NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "related_party_id" VARCHAR NOT NULL,
    "relation_type_id" ULID NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("related_party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("relation_type_id") REFERENCES "party_relation_type"("party_relation_type_id"),
    UNIQUE("party_id", "related_party_id", "relation_type_id")
);
CREATE TABLE IF NOT EXISTS "gender_type" (
    "gender_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "sex_type" (
    "sex_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "person_type" (
    "person_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "person" (
    "person_id" ULID PRIMARY KEY NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "person_type_id" ULID NOT NULL,
    "person_first_name" TEXT NOT NULL,
    "person_middle_name" TEXT,
    "person_last_name" TEXT NOT NULL,
    "previous_name" TEXT,
    "honorific_prefix" TEXT,
    "honorific_suffix" TEXT,
    "gender_id" ULID NOT NULL,
    "sex_id" ULID NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("person_type_id") REFERENCES "person_type"("person_type_id"),
    FOREIGN KEY("gender_id") REFERENCES "gender_type"("gender_type_id"),
    FOREIGN KEY("sex_id") REFERENCES "sex_type"("sex_type_id")
);
CREATE TABLE IF NOT EXISTS "organization" (
    "organization_id" ULID PRIMARY KEY NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "name" TEXT NOT NULL,
    "alias" TEXT,
    "description" TEXT,
    "license" TEXT NOT NULL,
    "federal_tax_id_num" TEXT,
    "registration_date" DATE NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "organization_role_type" (
    "organization_role_type_id" ULID PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "organization_role" (
    "organization_role_id" VARCHAR PRIMARY KEY NOT NULL,
    "person_id" VARCHAR NOT NULL,
    "organization_id" VARCHAR NOT NULL,
    "organization_role_type_id" ULID NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("person_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("organization_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("organization_role_type_id") REFERENCES "organization_role_type"("organization_role_type_id"),
    UNIQUE("person_id", "organization_id", "organization_role_type_id")
);
CREATE TABLE IF NOT EXISTS "device" (
    "device_id" VARCHAR PRIMARY KEY NOT NULL,
    "name" TEXT NOT NULL,
    "state" TEXT CHECK(json_valid(state)) NOT NULL,
    "boundary" TEXT NOT NULL,
    "segmentation" TEXT CHECK(json_valid(segmentation) OR segmentation IS NULL),
    "state_sysinfo" TEXT CHECK(json_valid(state_sysinfo) OR state_sysinfo IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("name", "state", "boundary")
);
CREATE TABLE IF NOT EXISTS "device_party_relationship" (
    "device_party_relationship_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    UNIQUE("device_id", "party_id")
);
CREATE TABLE IF NOT EXISTS "behavior" (
    "behavior_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "behavior_name" TEXT NOT NULL,
    "behavior_conf_json" TEXT CHECK(json_valid(behavior_conf_json)) NOT NULL,
    "assurance_schema_id" VARCHAR,
    "governance" TEXT CHECK(json_valid(governance) OR governance IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("assurance_schema_id") REFERENCES "assurance_schema"("assurance_schema_id"),
    UNIQUE("device_id", "behavior_name")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_resource_path_match_rule" (
    "ur_ingest_resource_path_match_rule_id" VARCHAR PRIMARY KEY NOT NULL,
    "namespace" TEXT NOT NULL,
    "regex" TEXT NOT NULL,
    "flags" TEXT NOT NULL,
    "nature" TEXT,
    "priority" TEXT,
    "description" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("namespace", "regex")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_resource_path_rewrite_rule" (
    "ur_ingest_resource_path_rewrite_rule_id" VARCHAR PRIMARY KEY NOT NULL,
    "namespace" TEXT NOT NULL,
    "regex" TEXT NOT NULL,
    "replace" TEXT NOT NULL,
    "priority" TEXT,
    "description" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("namespace", "regex", "replace")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session" (
    "ur_ingest_session_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "behavior_id" VARCHAR,
    "behavior_json" TEXT CHECK(json_valid(behavior_json) OR behavior_json IS NULL),
    "ingest_started_at" TIMESTAMPTZ NOT NULL,
    "ingest_finished_at" TIMESTAMPTZ,
    "session_agent" TEXT CHECK(json_valid(session_agent)) NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("behavior_id") REFERENCES "behavior"("behavior_id"),
    UNIQUE("device_id", "created_at")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_fs_path" (
    "ur_ingest_session_fs_path_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "root_path" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    UNIQUE("ingest_session_id", "root_path", "created_at")
);
CREATE TABLE IF NOT EXISTS "uniform_resource" (
    "uniform_resource_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_fs_path_id" VARCHAR,
    "ingest_session_imap_acct_folder_message" VARCHAR,
    "ingest_issue_acct_project_id" VARCHAR,
    "uri" TEXT NOT NULL,
    "content_digest" TEXT NOT NULL,
    "content" BLOB,
    "nature" TEXT,
    "size_bytes" INTEGER,
    "last_modified_at" TIMESTAMPTZ,
    "content_fm_body_attrs" TEXT CHECK(json_valid(content_fm_body_attrs) OR content_fm_body_attrs IS NULL),
    "frontmatter" TEXT CHECK(json_valid(frontmatter) OR frontmatter IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_fs_path_id") REFERENCES "ur_ingest_session_fs_path"("ur_ingest_session_fs_path_id"),
    FOREIGN KEY("ingest_session_imap_acct_folder_message") REFERENCES "ur_ingest_session_imap_acct_folder_message"("ur_ingest_session_imap_acct_folder_message_id"),
    FOREIGN KEY("ingest_issue_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id"),
    UNIQUE("device_id", "content_digest", "uri", "size_bytes")
);
CREATE TABLE IF NOT EXISTS "uniform_resource_transform" (
    "uniform_resource_transform_id" VARCHAR PRIMARY KEY NOT NULL,
    "uniform_resource_id" VARCHAR NOT NULL,
    "uri" TEXT NOT NULL,
    "content_digest" TEXT NOT NULL,
    "content" BLOB,
    "nature" TEXT,
    "size_bytes" INTEGER,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    UNIQUE("uniform_resource_id", "content_digest", "nature", "size_bytes")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_fs_path_entry" (
    "ur_ingest_session_fs_path_entry_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_fs_path_id" VARCHAR NOT NULL,
    "uniform_resource_id" VARCHAR,
    "file_path_abs" TEXT NOT NULL,
    "file_path_rel_parent" TEXT NOT NULL,
    "file_path_rel" TEXT NOT NULL,
    "file_basename" TEXT NOT NULL,
    "file_extn" TEXT,
    "captured_executable" TEXT CHECK(json_valid(captured_executable) OR captured_executable IS NULL),
    "ur_status" TEXT,
    "ur_diagnostics" TEXT CHECK(json_valid(ur_diagnostics) OR ur_diagnostics IS NULL),
    "ur_transformations" TEXT CHECK(json_valid(ur_transformations) OR ur_transformations IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_fs_path_id") REFERENCES "ur_ingest_session_fs_path"("ur_ingest_session_fs_path_id"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_task" (
    "ur_ingest_session_task_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "uniform_resource_id" VARCHAR,
    "captured_executable" TEXT CHECK(json_valid(captured_executable)) NOT NULL,
    "ur_status" TEXT,
    "ur_diagnostics" TEXT CHECK(json_valid(ur_diagnostics) OR ur_diagnostics IS NULL),
    "ur_transformations" TEXT CHECK(json_valid(ur_transformations) OR ur_transformations IS NULL),
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_imap_account" (
    "ur_ingest_session_imap_account_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "email" TEXT,
    "password" TEXT,
    "host" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    UNIQUE("ingest_session_id", "email")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_imap_acct_folder" (
    "ur_ingest_session_imap_acct_folder_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_account_id" VARCHAR NOT NULL,
    "folder_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_account_id") REFERENCES "ur_ingest_session_imap_account"("ur_ingest_session_imap_account_id"),
    UNIQUE("ingest_account_id", "folder_name")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_imap_acct_folder_message" (
    "ur_ingest_session_imap_acct_folder_message_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_imap_acct_folder_id" VARCHAR NOT NULL,
    "message" TEXT NOT NULL,
    "message_id" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "from" TEXT NOT NULL,
    "cc" TEXT CHECK(json_valid(cc)) NOT NULL,
    "bcc" TEXT CHECK(json_valid(bcc)) NOT NULL,
    "status" TEXT[] NOT NULL,
    "date" DATE,
    "email_references" TEXT CHECK(json_valid(email_references)) NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_imap_acct_folder_id") REFERENCES "ur_ingest_session_imap_acct_folder"("ur_ingest_session_imap_acct_folder_id"),
    UNIQUE("message", "message_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_account" (
    "ur_ingest_session_plm_account_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "provider" TEXT NOT NULL,
    "org_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    UNIQUE("provider", "org_name")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_acct_project" (
    "ur_ingest_session_plm_acct_project_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ingest_account_id" VARCHAR NOT NULL,
    "parent_project_id" TEXT,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "id" TEXT,
    "key" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ingest_account_id") REFERENCES "ur_ingest_session_plm_account"("ur_ingest_session_plm_account_id"),
    UNIQUE("name", "description")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_acct_project_issue" (
    "ur_ingest_session_plm_acct_project_issue_id" VARCHAR PRIMARY KEY NOT NULL,
    "ingest_session_id" VARCHAR NOT NULL,
    "ur_ingest_session_plm_acct_project_id" VARCHAR NOT NULL,
    "uniform_resource_id" VARCHAR,
    "issue_id" TEXT NOT NULL,
    "issue_number" INTEGER,
    "parent_issue_id" TEXT,
    "title" TEXT NOT NULL,
    "body" TEXT,
    "body_text" TEXT,
    "body_html" TEXT,
    "state" TEXT NOT NULL,
    "assigned_to" TEXT,
    "user" VARCHAR NOT NULL,
    "url" TEXT NOT NULL,
    "closed_at" TEXT,
    "issue_type_id" VARCHAR,
    "time_estimate" INTEGER,
    "aggregate_time_estimate" INTEGER,
    "time_original_estimate" INTEGER,
    "time_spent" INTEGER,
    "aggregate_time_spent" INTEGER,
    "aggregate_time_original_estimate" INTEGER,
    "workratio" INTEGER,
    "current_progress" INTEGER,
    "total_progress" INTEGER,
    "resolution_name" TEXT,
    "resolution_date" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    FOREIGN KEY("ur_ingest_session_plm_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    FOREIGN KEY("user") REFERENCES "ur_ingest_session_plm_user"("ur_ingest_session_plm_user_id"),
    FOREIGN KEY("issue_type_id") REFERENCES "ur_ingest_session_plm_issue_type"("ur_ingest_session_plm_issue_type_id"),
    UNIQUE("title", "issue_id", "state", "assigned_to")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_acct_label" (
    "ur_ingest_session_plm_acct_label_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_id" VARCHAR NOT NULL,
    "ur_ingest_session_plm_acct_project_issue_id" VARCHAR NOT NULL,
    "label" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id"),
    FOREIGN KEY("ur_ingest_session_plm_acct_project_issue_id") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_milestone" (
    "ur_ingest_session_plm_milestone_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_id" VARCHAR NOT NULL,
    "title" TEXT NOT NULL,
    "milestone_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "html_url" TEXT NOT NULL,
    "open_issues" INTEGER,
    "closed_issues" INTEGER,
    "due_on" TIMESTAMPTZ,
    "closed_at" TIMESTAMPTZ,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_id") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_acct_relationship" (
    "ur_ingest_session_plm_acct_relationship_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_id_prime" VARCHAR NOT NULL,
    "ur_ingest_session_plm_acct_project_id_related" TEXT NOT NULL,
    "ur_ingest_session_plm_acct_project_issue_id_prime" VARCHAR NOT NULL,
    "ur_ingest_session_plm_acct_project_issue_id_related" TEXT NOT NULL,
    "relationship" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_id_prime") REFERENCES "ur_ingest_session_plm_acct_project"("ur_ingest_session_plm_acct_project_id"),
    FOREIGN KEY("ur_ingest_session_plm_acct_project_issue_id_prime") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_user" (
    "ur_ingest_session_plm_user_id" VARCHAR PRIMARY KEY NOT NULL,
    "user_id" TEXT NOT NULL,
    "login" TEXT NOT NULL,
    "email" TEXT,
    "name" TEXT,
    "url" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("user_id", "login")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_comment" (
    "ur_ingest_session_plm_comment_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_session_plm_acct_project_issue_id" VARCHAR NOT NULL,
    "comment_id" TEXT NOT NULL,
    "node_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "body" TEXT,
    "body_text" TEXT,
    "body_html" TEXT,
    "user" VARCHAR NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_session_plm_acct_project_issue_id") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id"),
    FOREIGN KEY("user") REFERENCES "ur_ingest_session_plm_user"("ur_ingest_session_plm_user_id"),
    UNIQUE("comment_id", "url", "body")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_reaction" (
    "ur_ingest_session_plm_reaction_id" VARCHAR PRIMARY KEY NOT NULL,
    "reaction_id" TEXT NOT NULL,
    "reaction_type" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("reaction_type")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_issue_reaction" (
    "ur_ingest_session_plm_issue_reaction_id" VARCHAR PRIMARY KEY NOT NULL,
    "ur_ingest_plm_reaction_id" VARCHAR NOT NULL,
    "ur_ingest_plm_issue_id" VARCHAR NOT NULL,
    "count" INTEGER NOT NULL DEFAULT 1,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("ur_ingest_plm_reaction_id") REFERENCES "ur_ingest_session_plm_reaction"("ur_ingest_session_plm_reaction_id"),
    FOREIGN KEY("ur_ingest_plm_issue_id") REFERENCES "ur_ingest_session_plm_acct_project_issue"("ur_ingest_session_plm_acct_project_issue_id"),
    UNIQUE("ur_ingest_plm_issue_id", "ur_ingest_plm_reaction_id")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_plm_issue_type" (
    "ur_ingest_session_plm_issue_type_id" VARCHAR PRIMARY KEY NOT NULL,
    "avatar_id" TEXT,
    "description" TEXT NOT NULL,
    "icon_url" TEXT NOT NULL,
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "subtask" BOOLEAN NOT NULL,
    "url" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("id", "name")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_attachment" (
    "ur_ingest_session_attachment_id" VARCHAR PRIMARY KEY NOT NULL,
    "uniform_resource_id" VARCHAR,
    "name" TEXT,
    "uri" TEXT NOT NULL,
    "content" BLOB,
    "nature" TEXT,
    "size" INTEGER,
    "checksum" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    UNIQUE("uniform_resource_id", "checksum", "nature", "size")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_udi_pgp_sql" (
    "ur_ingest_session_udi_pgp_sql_id" VARCHAR PRIMARY KEY NOT NULL,
    "sql" TEXT NOT NULL,
    "nature" TEXT NOT NULL,
    "content" BLOB,
    "behaviour" TEXT CHECK(json_valid(behaviour) OR behaviour IS NULL),
    "query_error" TEXT,
    "uniform_resource_id" VARCHAR,
    "ingest_session_id" VARCHAR,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    FOREIGN KEY("ingest_session_id") REFERENCES "ur_ingest_session"("ur_ingest_session_id"),
    UNIQUE("sql", "ingest_session_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_nature" (
    "orchestration_nature_id" TEXT PRIMARY KEY NOT NULL,
    "nature" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("orchestration_nature_id", "nature")
);
CREATE TABLE IF NOT EXISTS "orchestration_session" (
    "orchestration_session_id" VARCHAR PRIMARY KEY NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "orchestration_nature_id" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "orch_started_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "orch_finished_at" TIMESTAMPTZ,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "args_json" TEXT CHECK(json_valid(args_json) OR args_json IS NULL),
    "diagnostics_json" TEXT CHECK(json_valid(diagnostics_json) OR diagnostics_json IS NULL),
    "diagnostics_md" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("orchestration_nature_id") REFERENCES "orchestration_nature"("orchestration_nature_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_entry" (
    "orchestration_session_entry_id" VARCHAR PRIMARY KEY NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "ingest_src" TEXT NOT NULL,
    "ingest_table_name" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_state" (
    "orchestration_session_state_id" VARCHAR PRIMARY KEY NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "session_entry_id" VARCHAR,
    "from_state" TEXT NOT NULL,
    "to_state" TEXT NOT NULL,
    "transition_result" TEXT CHECK(json_valid(transition_result) OR transition_result IS NULL),
    "transition_reason" TEXT,
    "transitioned_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id"),
    FOREIGN KEY("session_entry_id") REFERENCES "orchestration_session_entry"("orchestration_session_entry_id"),
    UNIQUE("orchestration_session_state_id", "from_state", "to_state")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_exec" (
    "orchestration_session_exec_id" VARCHAR PRIMARY KEY NOT NULL,
    "exec_nature" TEXT NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "session_entry_id" VARCHAR,
    "parent_exec_id" VARCHAR,
    "namespace" TEXT,
    "exec_identity" TEXT,
    "exec_code" TEXT NOT NULL,
    "exec_status" INTEGER NOT NULL,
    "input_text" TEXT,
    "exec_error_text" TEXT,
    "output_text" TEXT,
    "output_nature" TEXT CHECK(json_valid(output_nature) OR output_nature IS NULL),
    "narrative_md" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id"),
    FOREIGN KEY("session_entry_id") REFERENCES "orchestration_session_entry"("orchestration_session_entry_id"),
    FOREIGN KEY("parent_exec_id") REFERENCES "orchestration_session_exec"("orchestration_session_exec_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_issue" (
    "orchestration_session_issue_id" UUID PRIMARY KEY NOT NULL,
    "session_id" VARCHAR NOT NULL,
    "session_entry_id" VARCHAR,
    "issue_type" TEXT NOT NULL,
    "issue_message" TEXT NOT NULL,
    "issue_row" INTEGER,
    "issue_column" TEXT,
    "invalid_value" TEXT,
    "remediation" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("session_id") REFERENCES "orchestration_session"("orchestration_session_id"),
    FOREIGN KEY("session_entry_id") REFERENCES "orchestration_session_entry"("orchestration_session_entry_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_issue_relation" (
    "orchestration_session_issue_relation_id" UUID PRIMARY KEY NOT NULL,
    "issue_id_prime" UUID NOT NULL,
    "issue_id_rel" TEXT NOT NULL,
    "relationship_nature" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("issue_id_prime") REFERENCES "orchestration_session_issue"("orchestration_session_issue_id")
);
CREATE TABLE IF NOT EXISTS "orchestration_session_log" (
    "orchestration_session_log_id" UUID PRIMARY KEY NOT NULL,
    "category" TEXT,
    "parent_exec_id" UUID,
    "content" TEXT NOT NULL,
    "sibling_order" INTEGER,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("parent_exec_id") REFERENCES "orchestration_session_log"("orchestration_session_log_id")
);
CREATE TABLE IF NOT EXISTS "uniform_resource_graph" (
    "name" VARCHAR PRIMARY KEY NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL)
);
CREATE TABLE IF NOT EXISTS "uniform_resource_edge" (
    "graph_name" VARCHAR NOT NULL,
    "nature" TEXT NOT NULL,
    "node_id" TEXT NOT NULL,
    "uniform_resource_id" VARCHAR NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("graph_name") REFERENCES "uniform_resource_graph"("name"),
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
    UNIQUE("graph_name", "nature", "node_id", "uniform_resource_id")
);
CREATE TABLE IF NOT EXISTS "surveilr_osquery_ms_node" (
    "surveilr_osquery_ms_node_id" VARCHAR PRIMARY KEY NOT NULL,
    "node_key" TEXT NOT NULL,
    "host_identifier" TEXT NOT NULL,
    "tls_cert_subject" TEXT,
    "os_version" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "last_seen" TIMESTAMP NOT NULL,
    "status" TEXT NOT NULL DEFAULT ''active'',
    "osquery_version" TEXT,
    "osquery_build_platform" TEXT NOT NULL,
    "device_id" VARCHAR NOT NULL,
    "behavior_id" VARCHAR,
    "accelerate" INTEGER NOT NULL DEFAULT 60,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("device_id") REFERENCES "device"("device_id"),
    FOREIGN KEY("behavior_id") REFERENCES "behavior"("behavior_id"),
    UNIQUE("host_identifier", "os_version"),
    UNIQUE("node_key")
);
CREATE TABLE IF NOT EXISTS "ur_ingest_session_osquery_ms_log" (
    "ur_ingest_session_osquery_ms_log_id" VARCHAR PRIMARY KEY NOT NULL,
    "node_key" TEXT NOT NULL,
    "log_type" TEXT NOT NULL,
    "log_data" TEXT CHECK(json_valid(log_data)) NOT NULL,
    "applied_jq_filters" TEXT CHECK(json_valid(applied_jq_filters) OR applied_jq_filters IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("node_key") REFERENCES "surveilr_osquery_ms_node"("node_key"),
    UNIQUE("node_key", "log_type", "log_data")
);
CREATE TABLE IF NOT EXISTS "osquery_policy" (
    "osquery_policy_id" VARCHAR PRIMARY KEY NOT NULL,
    "policy_group" TEXT,
    "policy_name" TEXT NOT NULL,
    "osquery_code" TEXT NOT NULL,
    "policy_description" TEXT NOT NULL,
    "policy_pass_label" TEXT NOT NULL DEFAULT ''Pass'',
    "policy_fail_label" TEXT NOT NULL DEFAULT ''Fail'',
    "policy_pass_remarks" TEXT,
    "policy_fail_remarks" TEXT,
    "osquery_platforms" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("policy_name", "osquery_code")
);
CREATE TABLE IF NOT EXISTS "surveilr_table_size" (
    "table_name" VARCHAR PRIMARY KEY NOT NULL,
    "table_size_mb" INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS "surveilr_osquery_ms_distributed_query" (
    "query_id" VARCHAR PRIMARY KEY NOT NULL,
    "node_key" TEXT NOT NULL,
    "query_name" TEXT NOT NULL,
    "query_sql" TEXT NOT NULL,
    "discovery_query" TEXT,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("node_key") REFERENCES "surveilr_osquery_ms_node"("node_key")
);
CREATE TABLE IF NOT EXISTS "surveilr_osquery_ms_distributed_result" (
    "surveilr_osquery_ms_distributed_result_id" VARCHAR PRIMARY KEY NOT NULL,
    "query_id" VARCHAR NOT NULL,
    "node_key" TEXT NOT NULL,
    "results" TEXT CHECK(json_valid(results)) NOT NULL,
    "status_code" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("query_id") REFERENCES "surveilr_osquery_ms_distributed_query"("query_id"),
    FOREIGN KEY("node_key") REFERENCES "surveilr_osquery_ms_node"("node_key")
);
CREATE TABLE IF NOT EXISTS "surveilr_osquery_ms_carve" (
    "surveilr_osquery_ms_carve_id" VARCHAR PRIMARY KEY NOT NULL,
    "node_key" TEXT NOT NULL,
    "session_id" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "carve_guid" TEXT NOT NULL,
    "carve_size" INTEGER NOT NULL,
    "block_count" INTEGER NOT NULL,
    "block_size" INTEGER NOT NULL,
    "received_blocks" INTEGER NOT NULL DEFAULT 0,
    "carve_path" TEXT,
    "status" TEXT NOT NULL,
    "start_time" TIMESTAMPTZ NOT NULL,
    "completion_time" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("node_key") REFERENCES "surveilr_osquery_ms_node"("node_key"),
    UNIQUE("session_id")
);

CREATE INDEX IF NOT EXISTS "idx_party__party_type_id__party_name" ON "party"("party_type_id", "party_name");
CREATE INDEX IF NOT EXISTS "idx_party_relation__party_id__related_party_id__relation_type_id" ON "party_relation"("party_id", "related_party_id", "relation_type_id");
CREATE INDEX IF NOT EXISTS "idx_organization_role__person_id__organization_id__organization_role_type_id" ON "organization_role"("person_id", "organization_id", "organization_role_type_id");
CREATE INDEX IF NOT EXISTS "idx_device__name__state" ON "device"("name", "state");
CREATE INDEX IF NOT EXISTS "idx_device_party_relationship__device_id__party_id" ON "device_party_relationship"("device_id", "party_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_fs_path__ingest_session_id__root_path" ON "ur_ingest_session_fs_path"("ingest_session_id", "root_path");
CREATE INDEX IF NOT EXISTS "idx_uniform_resource__device_id__uri" ON "uniform_resource"("device_id", "uri");
CREATE INDEX IF NOT EXISTS "idx_uniform_resource_transform__uniform_resource_id__content_digest" ON "uniform_resource_transform"("uniform_resource_id", "content_digest");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_fs_path_entry__ingest_session_id__file_path_abs" ON "ur_ingest_session_fs_path_entry"("ingest_session_id", "file_path_abs");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_task__ingest_session_id" ON "ur_ingest_session_task"("ingest_session_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_imap_acct_folder__ingest_session_id__folder_name" ON "ur_ingest_session_imap_acct_folder"("ingest_session_id", "folder_name");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_imap_acct_folder_message__ingest_session_id" ON "ur_ingest_session_imap_acct_folder_message"("ingest_session_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_imap_account__ingest_session_id__email" ON "ur_ingest_session_imap_account"("ingest_session_id", "email");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_account__provider__org_name" ON "ur_ingest_session_plm_account"("provider", "org_name");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_acct_project__name__description" ON "ur_ingest_session_plm_acct_project"("name", "description");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_acct_project_issue__title__issue_id__state__assigned_to" ON "ur_ingest_session_plm_acct_project_issue"("title", "issue_id", "state", "assigned_to");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_acct_label__ur_ingest_session_plm_acct_project_issue_id" ON "ur_ingest_session_plm_acct_label"("ur_ingest_session_plm_acct_project_issue_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_milestone__ur_ingest_session_plm_acct_project_id" ON "ur_ingest_session_plm_milestone"("ur_ingest_session_plm_acct_project_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_acct_relationship__ur_ingest_session_plm_acct_project_id_prime" ON "ur_ingest_session_plm_acct_relationship"("ur_ingest_session_plm_acct_project_id_prime");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_user__user_id__login" ON "ur_ingest_session_plm_user"("user_id", "login");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_comment__ur_ingest_session_plm_acct_project_issue_id" ON "ur_ingest_session_plm_comment"("ur_ingest_session_plm_acct_project_issue_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_reaction__ur_ingest_session_plm_reaction_id" ON "ur_ingest_session_plm_reaction"("ur_ingest_session_plm_reaction_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_issue_reaction__ur_ingest_session_plm_issue_reaction_id" ON "ur_ingest_session_plm_issue_reaction"("ur_ingest_session_plm_issue_reaction_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_issue_type__id" ON "ur_ingest_session_plm_issue_type"("id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_attachment__uniform_resource_id__content" ON "ur_ingest_session_attachment"("uniform_resource_id", "content");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_udi_pgp_sql__ingest_session_id" ON "ur_ingest_session_udi_pgp_sql"("ingest_session_id");
CREATE INDEX IF NOT EXISTS "idx_orchestration_nature__orchestration_nature_id__nature" ON "orchestration_nature"("orchestration_nature_id", "nature");
CREATE INDEX IF NOT EXISTS "idx_uniform_resource_edge__uniform_resource_id" ON "uniform_resource_edge"("uniform_resource_id");
CREATE INDEX IF NOT EXISTS "idx_surveilr_osquery_ms_node__node_key" ON "surveilr_osquery_ms_node"("node_key");,CREATE TEMP TABLE IF NOT EXISTS "session_state_ephemeral" (
    "key" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL
);,CREATE TABLE IF NOT EXISTS surveilr_table_size (
    table_name TEXT PRIMARY KEY,
    table_size_mb REAL
);

DELETE FROM surveilr_table_size;
INSERT INTO surveilr_table_size (table_name, table_size_mb)
SELECT name, 
      ROUND(SUM(pgsize) / (1024.0 * 1024), 2)
FROM dbstat
GROUP BY name;,INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''ignore .git and node_modules paths'', ''default'', ''/(\.git|node_modules)/'', ''IGNORE_RESOURCE'', NULL, NULL, ''Ignore any entry with `/.git/` or `/node_modules/` in the path.'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''typical ingestion extensions'', ''default'', ''\.(?P<nature>md|mdx|html|json|jsonc|puml|txt|toml|yml|xml|tap|csv|tsv|ssv|psv|tm7|pdf|docx|doc|pptx|ppt|xlsx|xls)$'', ''CONTENT_ACQUIRABLE'', ''?P<nature>'', NULL, ''Ingest the content for md, mdx, html, json, jsonc, puml, txt, toml, and yml extensions. Assume the nature is the same as the extension.'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-[NATURE] style capturable executable'', ''default'', ''surveilr\[(?P<nature>[^\]]*)\]'', ''CAPTURABLE_EXECUTABLE'', ''?P<nature>'', NULL, ''Any entry with `surveilr-[XYZ]` in the path will be treated as a capturable executable extracting `XYZ` as the nature'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-SQL capturable executable'', ''default'', ''surveilr-SQL'', ''CAPTURABLE_EXECUTABLE | CAPTURABLE_SQL'', NULL, NULL, ''Any entry with surveilr-SQL in the path will be treated as a capturable SQL executable and allow execution of the SQL'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');

INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.plantuml -> .puml'', ''default'', ''(\.plantuml)$'', ''.puml'', NULL, ''Treat .plantuml as .puml files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.text -> .txt'', ''default'', ''(\.text)$'', ''.txt'', NULL, ''Treat .text as .txt files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.yaml -> .yml'', ''default'', ''(\.yaml)$'', ''.yml'', NULL, ''Treat .yaml as .yml files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

INSERT INTO "party_type" ("party_type_id", "code", "value", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), ''ORGANIZATION'', ''Organization'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "party_type" ("party_type_id", "code", "value", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), ''PERSON'', ''Person'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-csv'', ''Transform CSV'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-xml'', ''Transform XML'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-html'', ''Transform HTML'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

INSERT INTO "uniform_resource_graph" ("name", "elaboration") VALUES (''filesystem'', ''{}'') ON CONFLICT DO NOTHING;
INSERT INTO "uniform_resource_graph" ("name", "elaboration") VALUES (''imap'', ''{}'') ON CONFLICT DO NOTHING;
INSERT INTO "uniform_resource_graph" ("name", "elaboration") VALUES (''plm'', ''{}'') ON CONFLICT DO NOTHING;
INSERT INTO "uniform_resource_graph" ("name", "elaboration") VALUES (''osquery-ms'', ''{}'') ON CONFLICT DO NOTHING;

DROP VIEW IF EXISTS "plm_graph";
CREATE VIEW IF NOT EXISTS "plm_graph" AS
    SELECT
        ure.graph_name,
        ure.nature,
        ur.uniform_resource_id,
        ur.uri,
        ur_ingest_plm.ur_ingest_session_plm_acct_project_issue_id,
        ur_ingest_plm.issue_id,
        ur_ingest_plm.ur_ingest_session_plm_acct_project_id as project_id,
        ur_ingest_plm.title,
        ur_ingest_plm.body
    FROM
        uniform_resource_edge ure
    JOIN
        uniform_resource ur ON ure.uniform_resource_id = ur.uniform_resource_id
    JOIN
        ur_ingest_session_plm_acct_project_issue ur_ingest_plm ON ure.node_id = ur_ingest_plm.ur_ingest_session_plm_acct_project_issue_id
    WHERE
        ure.graph_name = ''plm'';
          ;
DROP VIEW IF EXISTS "imap_graph";
CREATE VIEW IF NOT EXISTS "imap_graph" AS
      SELECT
        ure.graph_name,
        ur.uniform_resource_id,
        ur.nature,
        ur.uri,
        ur.content,
        ur_ingest_imap.ur_ingest_session_imap_acct_folder_message_id,
        ur_ingest_imap.ingest_imap_acct_folder_id,
        ur_ingest_imap.message_id
    FROM
        uniform_resource_edge ure
    JOIN
        uniform_resource ur ON ure.uniform_resource_id = ur.uniform_resource_id
    JOIN
        ur_ingest_session_imap_acct_folder_message ur_ingest_imap ON ure.node_id = ur_ingest_imap.ur_ingest_session_imap_acct_folder_message_id
    WHERE
        ure.graph_name = ''imap'';
    ;
DROP VIEW IF EXISTS "filesystem_graph";
CREATE VIEW IF NOT EXISTS "filesystem_graph" AS
    SELECT
        ure.graph_name,
        ur.uniform_resource_id,
        ur.nature,
        ur.uri,
        ur_ingest_fs_path.ur_ingest_session_fs_path_id,
        ur_ingest_fs_path.root_path
    FROM
        uniform_resource_edge ure
    JOIN
        uniform_resource ur ON ure.uniform_resource_id = ur.uniform_resource_id
    JOIN
        ur_ingest_session_fs_path ur_ingest_fs_path ON ure.node_id = ur_ingest_fs_path.ur_ingest_session_fs_path_id
    WHERE
        ure.graph_name = ''filesystem'';
          ;

INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Ad tracking is limited (macOS)'', ''SELECT CASE WHEN EXISTS (SELECT 1 FROM managed_policies WHERE domain=''''com.apple.AdLib'''' AND name=''''forceLimitAdTracking'''' AND value=''''1'''' LIMIT 1) THEN ''''true'''' ELSE ''''false'''' END AS policy_result;'', ''Checks that a mobile device management (MDM) solution configures the Mac to limit advertisement tracking.'', ''Pass'', ''Fail'', NULL, ''Contact your IT administrator to ensure your Mac is receiving a profile that disables advertisement tracking.'', ''["macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Antivirus healthy (Linux)'', ''SELECT score FROM (SELECT CASE WHEN COUNT(*) = 2 THEN ''''true'''' ELSE ''''false'''' END AS score FROM processes WHERE (name = ''''clamd'''') OR (name = ''''freshclam'''')) WHERE score = ''''true'''';'', ''Checks that both ClamAV''''s daemon and its updater service (freshclam) are running.'', ''Pass'', ''Fail'', NULL, ''Ensure ClamAV and Freshclam are installed and running.'', ''["linux","windows","macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Antivirus healthy (macOS)'', ''SELECT score FROM (SELECT case when COUNT(*) = 2 then 1 ELSE 0 END AS score FROM plist WHERE (key = ''''CFBundleShortVersionString'''' AND path = ''''/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Info.plist'''' AND value>=2162) OR (key = ''''CFBundleShortVersionString'''' AND path = ''''/Library/Apple/System/Library/CoreServices/MRT.app/Contents/Info.plist'''' and value>=1.93)) WHERE score == 1;'', ''Checks the version of Malware Removal Tool (MRT) and the built-in macOS AV (Xprotect). Replace version numbers with the latest version regularly.'', ''Pass'', ''Fail'', NULL, ''To enable automatic security definition updates, on the failing device, select System Preferences > Software Update > Advanced > Turn on Install system data files and security updates.'', ''["macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Antivirus healthy (Windows)'', ''SELECT 1 from windows_security_center wsc CROSS JOIN windows_security_products wsp WHERE antivirus = ''''Good'''' AND type = ''''Antivirus'''' AND signatures_up_to_date=1;'', ''Checks the status of antivirus and signature updates from the Windows Security Center.'', ''Pass'', ''Fail'', NULL, ''Ensure Windows Defender or your third-party antivirus is running, up to date, and visible in the Windows Security Center.'', ''["windows"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Automatic installation of application updates is enabled (macOS)'', ''SELECT 1 FROM managed_policies WHERE domain=''''com.apple.SoftwareUpdate'''' AND name=''''AutomaticallyInstallAppUpdates'''' AND value=1 LIMIT 1;'', ''Checks that a mobile device management (MDM) solution configures the Mac to automatically install updates to App Store applications.'', ''Pass'', ''Fail'', NULL, ''Contact your IT administrator to ensure your Mac is receiving a profile that enables automatic installation of application updates.'', ''["macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Automatic installation of operating system updates is enabled (macOS)'', ''SELECT 1 FROM managed_policies WHERE domain=''''com.apple.SoftwareUpdate'''' AND name=''''AutomaticallyInstallMacOSUpdates'''' AND value=1 LIMIT 1;'', ''Checks that a mobile device management (MDM) solution configures the Mac to automatically install operating system updates.'', ''Pass'', ''Fail'', NULL, ''Contact your IT administrator to ensure your Mac is receiving a profile that enables automatic installation of operating system updates.'', ''["macos"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "osquery_policy" ("osquery_policy_id", "policy_group", "policy_name", "osquery_code", "policy_description", "policy_pass_label", "policy_fail_label", "policy_pass_remarks", "policy_fail_remarks", "osquery_platforms", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ((ulid()), NULL, ''Ensure ''''Minimum password length'''' is set to ''''14 or more characters'''''', ''SELECT 1 FROM security_profile_info WHERE minimum_password_length >= 14;'', ''This policy setting determines the least number of characters that make up a password for a user account.'', ''Pass'', ''Fail'', NULL, ''Automatic method:
Ask your system administrator to establish the recommended configuration via GP, set the following UI path to 14 or more characters
''''Computer ConfigurationPoliciesWindows SettingsSecurity SettingsAccount PoliciesPassword PolicyMinimum password length'''''', ''["windows"]'', NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;,SELECT * FROM system_info,SELECT DISTINCT value, key FROM process_envs WHERE key=''SURVEILR_OSQUERY_BOUNDARY'';,SELECT DISTINCT value, variable FROM default_environment WHERE variable=''SURVEILR_OSQUERY_BOUNDARY'';,SELECT
    os.name,
    os.major,
    os.minor,
    os.patch,
    os.extra,
    os.build,
    os.arch,
    os.platform,
    os.version AS version,
    k.version AS kernel_version
  FROM
    os_version os,
    kernel_info k;
,
    WITH display_version_table AS (
      SELECT data as display_version
      FROM registry
      WHERE path = ''HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DisplayVersion''
    ),
    ubr_table AS (
      SELECT data AS ubr
      FROM registry
      WHERE path =''HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UBR''
    )
    SELECT
      os.name,
      COALESCE(d.display_version, '''') AS display_version,
      COALESCE(CONCAT((SELECT version FROM os_version), ''.'', u.ubr), k.version) AS version
    FROM
      os_version os,
      kernel_info k
    LEFT JOIN
      display_version_table d
    LEFT JOIN
      ubr_table u;
,SELECT * FROM users,
      SELECT
          ia.address,
          id.mac
      FROM
          interface_addresses ia
          JOIN interface_details id ON id.interface = ia.interface
          JOIN routes r ON r.interface = ia.address
      WHERE
          (r.destination = ''0.0.0.0'' OR r.destination = ''::'') AND r.netmask = 0
          AND r.type = ''remote''
          AND (
          inet_aton(ia.address) IS NOT NULL AND (
            split(ia.address, ''.'', 0) = ''10''
            OR (split(ia.address, ''.'', 0) = ''172'' AND (CAST(split(ia.address, ''.'', 1) AS INTEGER) & 0xf0) = 16)
            OR (split(ia.address, ''.'', 0) = ''192'' AND split(ia.address, ''.'', 1) = ''168'')
          )
          OR (inet_aton(ia.address) IS NULL AND regex_match(lower(ia.address), ''^f[cd][0-9a-f][0-9a-f]:[0-9a-f:]+'', 0) IS NOT NULL)
        )
      ORDER BY
          r.metric ASC,
        inet_aton(ia.address) IS NOT NULL DESC
      LIMIT 1;
    ,
      SELECT
          ia.address,
          id.mac
      FROM
          interface_addresses ia
          JOIN interface_details id ON id.interface = ia.interface
          JOIN routes r ON r.interface = ia.interface
      WHERE
          (r.destination = ''0.0.0.0'' OR r.destination = ''::'') AND r.netmask = 0
          AND r.type = ''gateway''
          AND (
          inet_aton(ia.address) IS NOT NULL AND (
            split(ia.address, ''.'', 0) = ''10''
            OR (split(ia.address, ''.'', 0) = ''172'' AND (CAST(split(ia.address, ''.'', 1) AS INTEGER) & 0xf0) = 16)
            OR (split(ia.address, ''.'', 0) = ''192'' AND split(ia.address, ''.'', 1) = ''168'')
          )
          OR (inet_aton(ia.address) IS NULL AND regex_match(lower(ia.address), ''^f[cd][0-9a-f][0-9a-f]:[0-9a-f:]+'', 0) IS NOT NULL)
        )
      ORDER BY
          r.metric ASC,
        inet_aton(ia.address) IS NOT NULL DESC
      LIMIT 1;
    ,SELECT p.name, p.path FROM listening_ports l JOIN processes p USING (pid);,SELECT * FROM uptime LIMIT 1;,
    SELECT 
      ROUND((sum(free_space) * 100 * 10e-10) / (sum(size) * 10e-10)) AS percent_disk_space_available,
      ROUND(sum(free_space) * 10e-10) AS gigs_disk_space_available,
      ROUND(sum(size)       * 10e-10) AS gigs_total_disk_space
    FROM logical_drives
    WHERE file_system = ''NTFS'' LIMIT 1;
,
    SELECT 
      (blocks_available * 100 / blocks) AS percent_disk_space_available,
      round((blocks_available * blocks_size * 10e-10),2) AS gigs_disk_space_available,
      round((blocks           * blocks_size * 10e-10),2) AS gigs_total_disk_space
    FROM mounts
    WHERE path = ''/'' LIMIT 1;
,SELECT name AS name, version AS version, ''Package (APT)'' AS type, ''apt_sources'' AS source FROM apt_sources UNION SELECT name AS name, version AS version, ''Package (deb)'' AS type, ''deb_packages'' AS source FROM deb_packages UNION SELECT package AS name, version AS version, ''Package (Portage)'' AS type, ''portage_packages'' AS source FROM portage_packages UNION SELECT name AS name, version AS version, ''Package (RPM)'' AS type, ''rpm_packages'' AS source FROM rpm_packages UNION SELECT name AS name, '''' AS version, ''Package (YUM)'' AS type, ''yum_sources'' AS source FROM yum_sources UNION SELECT name AS name, version AS version, ''Package (NPM)'' AS type, ''npm_packages'' AS source FROM npm_packages UNION SELECT name AS name, version AS version, ''Package (Python)'' AS type, ''python_packages'' AS source FROM python_packages;,SELECT name AS name, version AS version, ''Program (Windows)'' AS type, ''programs'' AS source FROM programs UNION SELECT name AS name, version AS version, ''Package (Python)'' AS type, ''python_packages'' AS source FROM python_packages UNION SELECT name AS name, version AS version, ''Browser plugin (IE)'' AS type, ''ie_extensions'' AS source FROM ie_extensions UNION SELECT name AS name, version AS version, ''Browser plugin (Chrome)'' AS type, ''chrome_extensions'' AS source FROM chrome_extensions UNION SELECT name AS name, version AS version, ''Browser plugin (Firefox)'' AS type, ''firefox_addons'' AS source FROM firefox_addons UNION SELECT name AS name, version AS version, ''Package (Chocolatey)'' AS type, ''chocolatey_packages'' AS source FROM chocolatey_packages;,SELECT name AS name, bundle_short_version AS version, ''Application (macOS)'' AS type, ''apps'' AS source FROM apps UNION SELECT name AS name, version AS version, ''Package (Python)'' AS type, ''python_packages'' AS source FROM python_packages UNION SELECT name AS name, version AS version, ''Browser plugin (Chrome)'' AS type, ''chrome_extensions'' AS source FROM chrome_extensions UNION SELECT name AS name, version AS version, ''Browser plugin (Firefox)'' AS type, ''firefox_addons'' AS source FROM firefox_addons UNION SELECT name As name, version AS version, ''Browser plugin (Safari)'' AS type, ''safari_extensions'' AS source FROM safari_extensions UNION SELECT name AS name, version AS version, ''Package (Homebrew)'' AS type, ''homebrew_packages'' AS source FROM homebrew_packages;,SELECT 
  CASE 
    WHEN NOT EXISTS (
      SELECT 1
      FROM users
      CROSS JOIN user_ssh_keys USING (uid)
      WHERE encrypted = ''0''
    ) THEN ''true'' 
    ELSE ''false'' 
  END AS policy_result;
,SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM mounts m
      JOIN disk_encryption d ON m.device_alias = d.name
      WHERE d.encrypted = 1 AND m.path = ''/''
    ) THEN ''true''
    ELSE ''false''
  END AS policy_result;
,SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM bitlocker_info 
      WHERE drive_letter = ''C:'' AND protection_status = 1
    ) THEN ''true''
    ELSE ''false''
  END AS policy_result;
,SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM disk_encryption 
      WHERE user_uuid IS NOT '''' AND filevault_status = ''on''
      LIMIT 1
    ) THEN ''true''
    ELSE ''false''
  END AS policy_result;
,
/* ''osQuery Result Filters'' in ''RssdInitSqlNotebook'' returned type object instead of string | string[] | SQLa.SqlTextSupplier */
      ', 'cedf954a47b0f77f01a44dabe22ab2ee029c8050', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3WB7Z7M7K59R6TH1Q2G', 'Text Asset (.puml)', 'rssd-init', 'surveilr-code-notebooks-erd.auto.puml', NULL, '@startuml surveilr-code-notebooks
  hide circle
  skinparam linetype ortho
  skinparam roundcorner 20
  skinparam class {
    BackgroundColor White
    ArrowColor Silver
    BorderColor Silver
    FontColor Black
    FontSize 12
  }

  entity "assurance_schema" as assurance_schema {
    * **assurance_schema_id**: VARCHAR
    --
    * assurance_type: TEXT
    * code: TEXT
      code_json: TEXT
      governance: TEXT
  }

  entity "code_notebook_kernel" as code_notebook_kernel {
    * **code_notebook_kernel_id**: VARCHAR
    --
    * kernel_name: TEXT
      description: TEXT
      mime_type: TEXT
      file_extn: TEXT
      elaboration: TEXT
      governance: TEXT
    --
    codeNotebookCells: CodeNotebookCell[]
  }

  entity "code_notebook_cell" as code_notebook_cell {
    * **code_notebook_cell_id**: VARCHAR
    --
    * notebook_kernel_id: VARCHAR
    * notebook_name: TEXT
    * cell_name: TEXT
      cell_governance: TEXT
    * interpretable_code: TEXT
    * interpretable_code_hash: TEXT
      description: TEXT
      arguments: TEXT
  }

  entity "code_notebook_state" as code_notebook_state {
    * **code_notebook_state_id**: VARCHAR
    --
    * code_notebook_cell_id: VARCHAR
    * from_state: TEXT
    * to_state: TEXT
      transition_result: TEXT
      transition_reason: TEXT
      transitioned_at: TIMESTAMPTZ
      elaboration: TEXT
  }

  code_notebook_kernel |o..o{ code_notebook_cell
  code_notebook_cell |o..o{ code_notebook_state
@enduml', '84e0fc3aa026060b7e071785c89d02eaf87e6cbf', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3WHMM91KBXQE03RA999', 'Text Asset (.puml)', 'rssd-init', 'surveilr-service-erd.auto.puml', NULL, '@startuml surveilr-state
  hide circle
  skinparam linetype ortho
  skinparam roundcorner 20
  skinparam class {
    BackgroundColor White
    ArrowColor Silver
    BorderColor Silver
    FontColor Black
    FontSize 12
  }

  entity "party_type" as party_type {
    * **party_type_id**: ULID
    --
    * code: TEXT
    * value: TEXT
  }

  entity "party" as party {
    * **party_id**: VARCHAR
    --
    * party_type_id: ULID
    * party_name: TEXT
      elaboration: TEXT
  }

  entity "party_relation_type" as party_relation_type {
    * **party_relation_type_id**: ULID
    --
    * code: TEXT
    * value: TEXT
  }

  entity "party_relation" as party_relation {
    * **party_relation_id**: VARCHAR
    --
    * party_id: VARCHAR
    * related_party_id: VARCHAR
    * relation_type_id: ULID
      elaboration: TEXT
  }

  entity "gender_type" as gender_type {
    * **gender_type_id**: ULID
    --
    * code: TEXT
    * value: TEXT
  }

  entity "sex_type" as sex_type {
    * **sex_type_id**: ULID
    --
    * code: TEXT
    * value: TEXT
  }

  entity "person_type" as person_type {
    * **person_type_id**: ULID
    --
    * code: TEXT
    * value: TEXT
  }

  entity "person" as person {
    * **person_id**: ULID
    --
    * party_id: VARCHAR
    * person_type_id: ULID
    * person_first_name: TEXT
      person_middle_name: TEXT
    * person_last_name: TEXT
      previous_name: TEXT
      honorific_prefix: TEXT
      honorific_suffix: TEXT
    * gender_id: ULID
    * sex_id: ULID
      elaboration: TEXT
  }

  entity "organization" as organization {
    * **organization_id**: ULID
    --
    * party_id: VARCHAR
    * name: TEXT
      alias: TEXT
      description: TEXT
    * license: TEXT
      federal_tax_id_num: TEXT
    * registration_date: DATE
      elaboration: TEXT
  }

  entity "organization_role_type" as organization_role_type {
    * **organization_role_type_id**: ULID
    --
    * code: TEXT
    * value: TEXT
  }

  entity "organization_role" as organization_role {
    * **organization_role_id**: VARCHAR
    --
    * person_id: VARCHAR
    * organization_id: VARCHAR
    * organization_role_type_id: ULID
      elaboration: TEXT
  }

  entity "device" as device {
    * **device_id**: VARCHAR
    --
    * name: TEXT
    * state: TEXT
    * boundary: TEXT
      segmentation: TEXT
      state_sysinfo: TEXT
      elaboration: TEXT
    --
    behaviors: Behavior[]
    urIngestSessions: UrIngestSession[]
    uniformResources: UniformResource[]
    orchestrationSessions: OrchestrationSession[]
    surveilrOsqueryMsNodes: SurveilrOsqueryMsNode[]
  }

  entity "device_party_relationship" as device_party_relationship {
    * **device_party_relationship_id**: VARCHAR
    --
    * device_id: VARCHAR
    * party_id: VARCHAR
      elaboration: TEXT
  }

  entity "behavior" as behavior {
    * **behavior_id**: VARCHAR
    --
    * device_id: VARCHAR
    * behavior_name: TEXT
    * behavior_conf_json: TEXT
      assurance_schema_id: VARCHAR
      governance: TEXT
    --
    urIngestSessions: UrIngestSession[]
    surveilrOsqueryMsNodes: SurveilrOsqueryMsNode[]
  }

  entity "ur_ingest_resource_path_match_rule" as ur_ingest_resource_path_match_rule {
    * **ur_ingest_resource_path_match_rule_id**: VARCHAR
    --
    * namespace: TEXT
    * regex: TEXT
    * flags: TEXT
      nature: TEXT
      priority: TEXT
      description: TEXT
      elaboration: TEXT
  }

  entity "ur_ingest_resource_path_rewrite_rule" as ur_ingest_resource_path_rewrite_rule {
    * **ur_ingest_resource_path_rewrite_rule_id**: VARCHAR
    --
    * namespace: TEXT
    * regex: TEXT
    * replace: TEXT
      priority: TEXT
      description: TEXT
      elaboration: TEXT
  }

  entity "ur_ingest_session" as ur_ingest_session {
    * **ur_ingest_session_id**: VARCHAR
    --
    * device_id: VARCHAR
      behavior_id: VARCHAR
      behavior_json: TEXT
    * ingest_started_at: TIMESTAMPTZ
      ingest_finished_at: TIMESTAMPTZ
    * session_agent: TEXT
      elaboration: TEXT
    --
    urIngestSessionFsPaths: UrIngestSessionFsPath[]
    uniformResources: UniformResource[]
    urIngestSessionFsPathEntrys: UrIngestSessionFsPathEntry[]
    urIngestSessionImapAccounts: UrIngestSessionImapAccount[]
    urIngestSessionImapAcctFolders: UrIngestSessionImapAcctFolder[]
    urIngestSessionImapAcctFolderMessages: UrIngestSessionImapAcctFolderMessage[]
    urIngestSessionPlmAccounts: UrIngestSessionPlmAccount[]
    urIngestSessionPlmAcctProjects: UrIngestSessionPlmAcctProject[]
    urIngestSessionPlmAcctProjectIssues: UrIngestSessionPlmAcctProjectIssue[]
    urIngestSessionUdiPgpSqls: UrIngestSessionUdiPgpSql[]
  }

  entity "ur_ingest_session_fs_path" as ur_ingest_session_fs_path {
    * **ur_ingest_session_fs_path_id**: VARCHAR
    --
    * ingest_session_id: VARCHAR
    * root_path: TEXT
      elaboration: TEXT
    --
    urIngestSessionFsPathEntrys: UrIngestSessionFsPathEntry[]
  }

  entity "uniform_resource" as uniform_resource {
    * **uniform_resource_id**: VARCHAR
    --
    * device_id: VARCHAR
    * ingest_session_id: VARCHAR
      ingest_fs_path_id: VARCHAR
      ingest_session_imap_acct_folder_message: VARCHAR
      ingest_issue_acct_project_id: VARCHAR
    * uri: TEXT
    * content_digest: TEXT
      content: BLOB
      nature: TEXT
      size_bytes: INTEGER
      last_modified_at: TIMESTAMPTZ
      content_fm_body_attrs: TEXT
      frontmatter: TEXT
      elaboration: TEXT
    --
    uniformResourceTransforms: UniformResourceTransform[]
    urIngestSessionAttachments: UrIngestSessionAttachment[]
    uniformResourceEdges: UniformResourceEdge[]
  }

  entity "uniform_resource_transform" as uniform_resource_transform {
    * **uniform_resource_transform_id**: VARCHAR
    --
    * uniform_resource_id: VARCHAR
    * uri: TEXT
    * content_digest: TEXT
      content: BLOB
      nature: TEXT
      size_bytes: INTEGER
      elaboration: TEXT
  }

  entity "ur_ingest_session_fs_path_entry" as ur_ingest_session_fs_path_entry {
    * **ur_ingest_session_fs_path_entry_id**: VARCHAR
    --
    * ingest_session_id: VARCHAR
    * ingest_fs_path_id: VARCHAR
      uniform_resource_id: VARCHAR
    * file_path_abs: TEXT
    * file_path_rel_parent: TEXT
    * file_path_rel: TEXT
    * file_basename: TEXT
      file_extn: TEXT
      captured_executable: TEXT
      ur_status: TEXT
      ur_diagnostics: TEXT
      ur_transformations: TEXT
      elaboration: TEXT
  }

  entity "ur_ingest_session_task" as ur_ingest_session_task {
    * **ur_ingest_session_task_id**: VARCHAR
    --
    * ingest_session_id: VARCHAR
      uniform_resource_id: VARCHAR
    * captured_executable: TEXT
      ur_status: TEXT
      ur_diagnostics: TEXT
      ur_transformations: TEXT
      elaboration: TEXT
  }

  entity "ur_ingest_session_imap_account" as ur_ingest_session_imap_account {
    * **ur_ingest_session_imap_account_id**: VARCHAR
    --
    * ingest_session_id: VARCHAR
      email: TEXT
      password: TEXT
      host: TEXT
      elaboration: TEXT
    --
    urIngestSessionImapAcctFolders: UrIngestSessionImapAcctFolder[]
  }

  entity "ur_ingest_session_imap_acct_folder" as ur_ingest_session_imap_acct_folder {
    * **ur_ingest_session_imap_acct_folder_id**: VARCHAR
    --
    * ingest_session_id: VARCHAR
    * ingest_account_id: VARCHAR
    * folder_name: TEXT
      elaboration: TEXT
    --
    urIngestSessionImapAcctFolderMessages: UrIngestSessionImapAcctFolderMessage[]
  }

  entity "ur_ingest_session_imap_acct_folder_message" as ur_ingest_session_imap_acct_folder_message {
    * **ur_ingest_session_imap_acct_folder_message_id**: VARCHAR
    --
    * ingest_session_id: VARCHAR
    * ingest_imap_acct_folder_id: VARCHAR
    * message: TEXT
    * message_id: TEXT
    * subject: TEXT
    * from: TEXT
    * cc: TEXT
    * bcc: TEXT
    * status: TEXT[]
      date: DATE
    * email_references: TEXT
  }

  entity "ur_ingest_session_plm_account" as ur_ingest_session_plm_account {
    * **ur_ingest_session_plm_account_id**: VARCHAR
    --
    * ingest_session_id: VARCHAR
    * provider: TEXT
    * org_name: TEXT
      elaboration: TEXT
    --
    urIngestSessionPlmAcctProjects: UrIngestSessionPlmAcctProject[]
  }

  entity "ur_ingest_session_plm_acct_project" as ur_ingest_session_plm_acct_project {
    * **ur_ingest_session_plm_acct_project_id**: VARCHAR
    --
    * ingest_session_id: VARCHAR
    * ingest_account_id: VARCHAR
      parent_project_id: TEXT
    * name: TEXT
      description: TEXT
      id: TEXT
      key: TEXT
      elaboration: TEXT
    --
    urIngestSessionPlmAcctProjectIssues: UrIngestSessionPlmAcctProjectIssue[]
    urIngestSessionPlmAcctLabels: UrIngestSessionPlmAcctLabel[]
    urIngestSessionPlmMilestones: UrIngestSessionPlmMilestone[]
    urIngestSessionPlmAcctRelationships: UrIngestSessionPlmAcctRelationship[]
  }

  entity "ur_ingest_session_plm_acct_project_issue" as ur_ingest_session_plm_acct_project_issue {
    * **ur_ingest_session_plm_acct_project_issue_id**: VARCHAR
    --
    * ingest_session_id: VARCHAR
    * ur_ingest_session_plm_acct_project_id: VARCHAR
      uniform_resource_id: VARCHAR
    * issue_id: TEXT
      issue_number: INTEGER
      parent_issue_id: TEXT
    * title: TEXT
      body: TEXT
      body_text: TEXT
      body_html: TEXT
    * state: TEXT
      assigned_to: TEXT
    * user: VARCHAR
    * url: TEXT
      closed_at: TEXT
      issue_type_id: VARCHAR
      time_estimate: INTEGER
      aggregate_time_estimate: INTEGER
      time_original_estimate: INTEGER
      time_spent: INTEGER
      aggregate_time_spent: INTEGER
      aggregate_time_original_estimate: INTEGER
      workratio: INTEGER
      current_progress: INTEGER
      total_progress: INTEGER
      resolution_name: TEXT
      resolution_date: TEXT
      elaboration: TEXT
    --
    urIngestSessionPlmAcctLabels: UrIngestSessionPlmAcctLabel[]
    urIngestSessionPlmAcctRelationships: UrIngestSessionPlmAcctRelationship[]
    urIngestSessionPlmComments: UrIngestSessionPlmComment[]
    urIngestSessionPlmIssueReactions: UrIngestSessionPlmIssueReaction[]
  }

  entity "ur_ingest_session_plm_acct_label" as ur_ingest_session_plm_acct_label {
    * **ur_ingest_session_plm_acct_label_id**: VARCHAR
    --
    * ur_ingest_session_plm_acct_project_id: VARCHAR
    * ur_ingest_session_plm_acct_project_issue_id: VARCHAR
    * label: TEXT
      elaboration: TEXT
  }

  entity "ur_ingest_session_plm_milestone" as ur_ingest_session_plm_milestone {
    * **ur_ingest_session_plm_milestone_id**: VARCHAR
    --
    * ur_ingest_session_plm_acct_project_id: VARCHAR
    * title: TEXT
    * milestone_id: TEXT
    * url: TEXT
    * html_url: TEXT
      open_issues: INTEGER
      closed_issues: INTEGER
      due_on: TIMESTAMPTZ
      closed_at: TIMESTAMPTZ
      elaboration: TEXT
  }

  entity "ur_ingest_session_plm_acct_relationship" as ur_ingest_session_plm_acct_relationship {
    * **ur_ingest_session_plm_acct_relationship_id**: VARCHAR
    --
    * ur_ingest_session_plm_acct_project_id_prime: VARCHAR
    * ur_ingest_session_plm_acct_project_id_related: TEXT
    * ur_ingest_session_plm_acct_project_issue_id_prime: VARCHAR
    * ur_ingest_session_plm_acct_project_issue_id_related: TEXT
      relationship: TEXT
      elaboration: TEXT
  }

  entity "ur_ingest_session_plm_user" as ur_ingest_session_plm_user {
    * **ur_ingest_session_plm_user_id**: VARCHAR
    --
    * user_id: TEXT
    * login: TEXT
      email: TEXT
      name: TEXT
    * url: TEXT
      elaboration: TEXT
    --
    urIngestSessionPlmAcctProjectIssues: UrIngestSessionPlmAcctProjectIssue[]
    urIngestSessionPlmComments: UrIngestSessionPlmComment[]
  }

  entity "ur_ingest_session_plm_comment" as ur_ingest_session_plm_comment {
    * **ur_ingest_session_plm_comment_id**: VARCHAR
    --
    * ur_ingest_session_plm_acct_project_issue_id: VARCHAR
    * comment_id: TEXT
    * node_id: TEXT
    * url: TEXT
      body: TEXT
      body_text: TEXT
      body_html: TEXT
    * user: VARCHAR
      elaboration: TEXT
  }

  entity "ur_ingest_session_plm_reaction" as ur_ingest_session_plm_reaction {
    * **ur_ingest_session_plm_reaction_id**: VARCHAR
    --
    * reaction_id: TEXT
    * reaction_type: TEXT
      elaboration: TEXT
    --
    urIngestSessionPlmIssueReactions: UrIngestSessionPlmIssueReaction[]
  }

  entity "ur_ingest_session_plm_issue_reaction" as ur_ingest_session_plm_issue_reaction {
    * **ur_ingest_session_plm_issue_reaction_id**: VARCHAR
    --
    * ur_ingest_plm_reaction_id: VARCHAR
    * ur_ingest_plm_issue_id: VARCHAR
    * count: INTEGER
      elaboration: TEXT
  }

  entity "ur_ingest_session_plm_issue_type" as ur_ingest_session_plm_issue_type {
    * **ur_ingest_session_plm_issue_type_id**: VARCHAR
    --
      avatar_id: TEXT
    * description: TEXT
    * icon_url: TEXT
    * id: TEXT
    * name: TEXT
    * subtask: BOOLEAN
    * url: TEXT
      elaboration: TEXT
    --
    urIngestSessionPlmAcctProjectIssues: UrIngestSessionPlmAcctProjectIssue[]
  }

  entity "ur_ingest_session_attachment" as ur_ingest_session_attachment {
    * **ur_ingest_session_attachment_id**: VARCHAR
    --
      uniform_resource_id: VARCHAR
      name: TEXT
    * uri: TEXT
      content: BLOB
      nature: TEXT
      size: INTEGER
      checksum: TEXT
      elaboration: TEXT
  }

  entity "ur_ingest_session_udi_pgp_sql" as ur_ingest_session_udi_pgp_sql {
    * **ur_ingest_session_udi_pgp_sql_id**: VARCHAR
    --
    * sql: TEXT
    * nature: TEXT
      content: BLOB
      behaviour: TEXT
      query_error: TEXT
      uniform_resource_id: VARCHAR
      ingest_session_id: VARCHAR
  }

  entity "orchestration_nature" as orchestration_nature {
    * **orchestration_nature_id**: TEXT
    --
    * nature: TEXT
      elaboration: TEXT
    --
    orchestrationSessions: OrchestrationSession[]
  }

  entity "orchestration_session" as orchestration_session {
    * **orchestration_session_id**: VARCHAR
    --
    * device_id: VARCHAR
    * orchestration_nature_id: TEXT
    * version: TEXT
      orch_started_at: TIMESTAMPTZ
      orch_finished_at: TIMESTAMPTZ
      elaboration: TEXT
      args_json: TEXT
      diagnostics_json: TEXT
      diagnostics_md: TEXT
    --
    orchestrationSessionEntrys: OrchestrationSessionEntry[]
    orchestrationSessionStates: OrchestrationSessionState[]
    orchestrationSessionExecs: OrchestrationSessionExec[]
    orchestrationSessionIssues: OrchestrationSessionIssue[]
  }

  entity "orchestration_session_entry" as orchestration_session_entry {
    * **orchestration_session_entry_id**: VARCHAR
    --
    * session_id: VARCHAR
    * ingest_src: TEXT
      ingest_table_name: TEXT
      elaboration: TEXT
    --
    orchestrationSessionStates: OrchestrationSessionState[]
    orchestrationSessionExecs: OrchestrationSessionExec[]
    orchestrationSessionIssues: OrchestrationSessionIssue[]
  }

  entity "orchestration_session_state" as orchestration_session_state {
    * **orchestration_session_state_id**: VARCHAR
    --
    * session_id: VARCHAR
      session_entry_id: VARCHAR
    * from_state: TEXT
    * to_state: TEXT
      transition_result: TEXT
      transition_reason: TEXT
      transitioned_at: TIMESTAMPTZ
      elaboration: TEXT
  }

  entity "orchestration_session_exec" as orchestration_session_exec {
    * **orchestration_session_exec_id**: VARCHAR
    --
    * exec_nature: TEXT
    * session_id: VARCHAR
      session_entry_id: VARCHAR
      parent_exec_id: VARCHAR
      namespace: TEXT
      exec_identity: TEXT
    * exec_code: TEXT
    * exec_status: INTEGER
      input_text: TEXT
      exec_error_text: TEXT
      output_text: TEXT
      output_nature: TEXT
      narrative_md: TEXT
      elaboration: TEXT
  }

  entity "orchestration_session_issue" as orchestration_session_issue {
    * **orchestration_session_issue_id**: UUID
    --
    * session_id: VARCHAR
      session_entry_id: VARCHAR
    * issue_type: TEXT
    * issue_message: TEXT
      issue_row: INTEGER
      issue_column: TEXT
      invalid_value: TEXT
      remediation: TEXT
      elaboration: TEXT
    --
    orchestrationSessionIssueRelations: OrchestrationSessionIssueRelation[]
  }

  entity "orchestration_session_issue_relation" as orchestration_session_issue_relation {
    * **orchestration_session_issue_relation_id**: UUID
    --
    * issue_id_prime: UUID
    * issue_id_rel: TEXT
    * relationship_nature: TEXT
      elaboration: TEXT
  }

  entity "orchestration_session_log" as orchestration_session_log {
    * **orchestration_session_log_id**: UUID
    --
      category: TEXT
      parent_exec_id: UUID
    * content: TEXT
      sibling_order: INTEGER
      elaboration: TEXT
  }

  entity "uniform_resource_graph" as uniform_resource_graph {
    * **name**: VARCHAR
    --
      elaboration: TEXT
    --
    uniformResourceEdges: UniformResourceEdge[]
  }

  entity "uniform_resource_edge" as uniform_resource_edge {
    * graph_name: VARCHAR
    * nature: TEXT
    * node_id: TEXT
    * uniform_resource_id: VARCHAR
      elaboration: TEXT
  }

  entity "surveilr_osquery_ms_node" as surveilr_osquery_ms_node {
    * **surveilr_osquery_ms_node_id**: VARCHAR
    --
    * node_key: TEXT
    * host_identifier: TEXT
      tls_cert_subject: TEXT
    * os_version: TEXT
    * platform: TEXT
    * last_seen: TIMESTAMP
    * status: TEXT
      osquery_version: TEXT
    * osquery_build_platform: TEXT
    * device_id: VARCHAR
      behavior_id: VARCHAR
    * accelerate: INTEGER
    --
    urIngestSessionOsqueryMsLogs: UrIngestSessionOsqueryMsLog[]
    surveilrOsqueryMsDistributedQuerys: SurveilrOsqueryMsDistributedQuery[]
    surveilrOsqueryMsDistributedResults: SurveilrOsqueryMsDistributedResult[]
    surveilrOsqueryMsCarves: SurveilrOsqueryMsCarve[]
  }

  entity "ur_ingest_session_osquery_ms_log" as ur_ingest_session_osquery_ms_log {
    * **ur_ingest_session_osquery_ms_log_id**: VARCHAR
    --
    * node_key: TEXT
    * log_type: TEXT
    * log_data: TEXT
      applied_jq_filters: TEXT
  }

  entity "osquery_policy" as osquery_policy {
    * **osquery_policy_id**: VARCHAR
    --
      policy_group: TEXT
    * policy_name: TEXT
    * osquery_code: TEXT
    * policy_description: TEXT
    * policy_pass_label: TEXT
    * policy_fail_label: TEXT
      policy_pass_remarks: TEXT
      policy_fail_remarks: TEXT
      osquery_platforms: TEXT
  }

  entity "surveilr_table_size" as surveilr_table_size {
    * **table_name**: VARCHAR
    --
    * table_size_mb: INTEGER
  }

  entity "surveilr_osquery_ms_distributed_query" as surveilr_osquery_ms_distributed_query {
    * **query_id**: VARCHAR
    --
    * node_key: TEXT
    * query_name: TEXT
    * query_sql: TEXT
      discovery_query: TEXT
    * status: TEXT
    --
    surveilrOsqueryMsDistributedResults: SurveilrOsqueryMsDistributedResult[]
  }

  entity "surveilr_osquery_ms_distributed_result" as surveilr_osquery_ms_distributed_result {
    * **surveilr_osquery_ms_distributed_result_id**: VARCHAR
    --
    * query_id: VARCHAR
    * node_key: TEXT
    * results: TEXT
    * status_code: INTEGER
  }

  entity "surveilr_osquery_ms_carve" as surveilr_osquery_ms_carve {
    * **surveilr_osquery_ms_carve_id**: VARCHAR
    --
    * node_key: TEXT
    * session_id: TEXT
    * carve_guid: TEXT
    * carve_size: INTEGER
    * block_count: INTEGER
    * block_size: INTEGER
    * received_blocks: INTEGER
      carve_path: TEXT
    * status: TEXT
    * start_time: TIMESTAMPTZ
      completion_time: TIMESTAMPTZ
  }

  party_type |o..o{ party
  party |o..o{ party_relation
  party |o..o{ party_relation
  party_relation_type |o..o{ party_relation
  party |o..o{ person
  person_type |o..o{ person
  gender_type |o..o{ person
  sex_type |o..o{ person
  party |o..o{ organization
  party |o..o{ organization_role
  party |o..o{ organization_role
  organization_role_type |o..o{ organization_role
  device |o..o{ device_party_relationship
  party |o..o{ device_party_relationship
  device |o..o{ behavior
  device |o..o{ ur_ingest_session
  behavior |o..o{ ur_ingest_session
  ur_ingest_session |o..o{ ur_ingest_session_fs_path
  device |o..o{ uniform_resource
  ur_ingest_session |o..o{ uniform_resource
  ur_ingest_session_fs_path |o..o{ uniform_resource
  ur_ingest_session_imap_acct_folder_message |o..o{ uniform_resource
  ur_ingest_session_plm_acct_project |o..o{ uniform_resource
  uniform_resource |o..o{ uniform_resource_transform
  ur_ingest_session |o..o{ ur_ingest_session_fs_path_entry
  ur_ingest_session_fs_path |o..o{ ur_ingest_session_fs_path_entry
  uniform_resource |o..o{ ur_ingest_session_fs_path_entry
  ur_ingest_session |o..o{ ur_ingest_session_task
  uniform_resource |o..o{ ur_ingest_session_task
  ur_ingest_session |o..o{ ur_ingest_session_imap_account
  ur_ingest_session |o..o{ ur_ingest_session_imap_acct_folder
  ur_ingest_session_imap_account |o..o{ ur_ingest_session_imap_acct_folder
  ur_ingest_session |o..o{ ur_ingest_session_imap_acct_folder_message
  ur_ingest_session_imap_acct_folder |o..o{ ur_ingest_session_imap_acct_folder_message
  ur_ingest_session |o..o{ ur_ingest_session_plm_account
  ur_ingest_session |o..o{ ur_ingest_session_plm_acct_project
  ur_ingest_session_plm_account |o..o{ ur_ingest_session_plm_acct_project
  ur_ingest_session |o..o{ ur_ingest_session_plm_acct_project_issue
  ur_ingest_session_plm_acct_project |o..o{ ur_ingest_session_plm_acct_project_issue
  uniform_resource |o..o{ ur_ingest_session_plm_acct_project_issue
  ur_ingest_session_plm_user |o..o{ ur_ingest_session_plm_acct_project_issue
  ur_ingest_session_plm_issue_type |o..o{ ur_ingest_session_plm_acct_project_issue
  ur_ingest_session_plm_acct_project |o..o{ ur_ingest_session_plm_acct_label
  ur_ingest_session_plm_acct_project_issue |o..o{ ur_ingest_session_plm_acct_label
  ur_ingest_session_plm_acct_project |o..o{ ur_ingest_session_plm_milestone
  ur_ingest_session_plm_acct_project |o..o{ ur_ingest_session_plm_acct_relationship
  ur_ingest_session_plm_acct_project_issue |o..o{ ur_ingest_session_plm_acct_relationship
  ur_ingest_session_plm_acct_project_issue |o..o{ ur_ingest_session_plm_comment
  ur_ingest_session_plm_user |o..o{ ur_ingest_session_plm_comment
  ur_ingest_session_plm_reaction |o..o{ ur_ingest_session_plm_issue_reaction
  ur_ingest_session_plm_acct_project_issue |o..o{ ur_ingest_session_plm_issue_reaction
  uniform_resource |o..o{ ur_ingest_session_attachment
  uniform_resource |o..o{ ur_ingest_session_udi_pgp_sql
  ur_ingest_session |o..o{ ur_ingest_session_udi_pgp_sql
  device |o..o{ orchestration_session
  orchestration_nature |o..o{ orchestration_session
  orchestration_session |o..o{ orchestration_session_entry
  orchestration_session |o..o{ orchestration_session_state
  orchestration_session_entry |o..o{ orchestration_session_state
  orchestration_session |o..o{ orchestration_session_exec
  orchestration_session_entry |o..o{ orchestration_session_exec
  orchestration_session_exec |o..o{ orchestration_session_exec
  orchestration_session |o..o{ orchestration_session_issue
  orchestration_session_entry |o..o{ orchestration_session_issue
  orchestration_session_issue |o..o{ orchestration_session_issue_relation
  orchestration_session_log |o..o{ orchestration_session_log
  uniform_resource_graph |o..o{ uniform_resource_edge
  uniform_resource |o..o{ uniform_resource_edge
  device |o..o{ surveilr_osquery_ms_node
  behavior |o..o{ surveilr_osquery_ms_node
  surveilr_osquery_ms_node |o..o{ ur_ingest_session_osquery_ms_log
  surveilr_osquery_ms_node |o..o{ surveilr_osquery_ms_distributed_query
  surveilr_osquery_ms_distributed_query |o..o{ surveilr_osquery_ms_distributed_result
  surveilr_osquery_ms_node |o..o{ surveilr_osquery_ms_distributed_result
  surveilr_osquery_ms_node |o..o{ surveilr_osquery_ms_carve
@enduml', '7270f0af13edbaaf3759f4cbaf1374f73df32435', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3WPME3D6YACFADCCJS1', 'Text Asset (.rs)', 'rssd-init', 'models_polygenix.rs', NULL, '/*
const PARTY_TYPE: &str = "party_type";
const PARTY: &str = "party";
const PARTY_RELATION_TYPE: &str = "party_relation_type";
const PARTY_RELATION: &str = "party_relation";
const GENDER_TYPE: &str = "gender_type";
const SEX_TYPE: &str = "sex_type";
const PERSON_TYPE: &str = "person_type";
const PERSON: &str = "person";
const ORGANIZATION: &str = "organization";
const ORGANIZATION_ROLE_TYPE: &str = "organization_role_type";
const ORGANIZATION_ROLE: &str = "organization_role";
const DEVICE: &str = "device";
const DEVICE_PARTY_RELATIONSHIP: &str = "device_party_relationship";
const BEHAVIOR: &str = "behavior";
const UR_INGEST_RESOURCE_PATH_MATCH_RULE: &str = "ur_ingest_resource_path_match_rule";
const UR_INGEST_RESOURCE_PATH_REWRITE_RULE: &str = "ur_ingest_resource_path_rewrite_rule";
const UR_INGEST_SESSION: &str = "ur_ingest_session";
const UR_INGEST_SESSION_FS_PATH: &str = "ur_ingest_session_fs_path";
const UNIFORM_RESOURCE: &str = "uniform_resource";
const UNIFORM_RESOURCE_TRANSFORM: &str = "uniform_resource_transform";
const UR_INGEST_SESSION_FS_PATH_ENTRY: &str = "ur_ingest_session_fs_path_entry";
const UR_INGEST_SESSION_TASK: &str = "ur_ingest_session_task";
const UR_INGEST_SESSION_IMAP_ACCOUNT: &str = "ur_ingest_session_imap_account";
const UR_INGEST_SESSION_IMAP_ACCT_FOLDER: &str = "ur_ingest_session_imap_acct_folder";
const UR_INGEST_SESSION_IMAP_ACCT_FOLDER_MESSAGE: &str = "ur_ingest_session_imap_acct_folder_message";
const UR_INGEST_SESSION_PLM_ACCOUNT: &str = "ur_ingest_session_plm_account";
const UR_INGEST_SESSION_PLM_ACCT_PROJECT: &str = "ur_ingest_session_plm_acct_project";
const UR_INGEST_SESSION_PLM_ACCT_PROJECT_ISSUE: &str = "ur_ingest_session_plm_acct_project_issue";
const UR_INGEST_SESSION_PLM_ACCT_LABEL: &str = "ur_ingest_session_plm_acct_label";
const UR_INGEST_SESSION_PLM_MILESTONE: &str = "ur_ingest_session_plm_milestone";
const UR_INGEST_SESSION_PLM_ACCT_RELATIONSHIP: &str = "ur_ingest_session_plm_acct_relationship";
const UR_INGEST_SESSION_PLM_USER: &str = "ur_ingest_session_plm_user";
const UR_INGEST_SESSION_PLM_COMMENT: &str = "ur_ingest_session_plm_comment";
const UR_INGEST_SESSION_PLM_REACTION: &str = "ur_ingest_session_plm_reaction";
const UR_INGEST_SESSION_PLM_ISSUE_REACTION: &str = "ur_ingest_session_plm_issue_reaction";
const UR_INGEST_SESSION_PLM_ISSUE_TYPE: &str = "ur_ingest_session_plm_issue_type";
const UR_INGEST_SESSION_ATTACHMENT: &str = "ur_ingest_session_attachment";
const UR_INGEST_SESSION_UDI_PGP_SQL: &str = "ur_ingest_session_udi_pgp_sql";
const ORCHESTRATION_NATURE: &str = "orchestration_nature";
const ORCHESTRATION_SESSION: &str = "orchestration_session";
const ORCHESTRATION_SESSION_ENTRY: &str = "orchestration_session_entry";
const ORCHESTRATION_SESSION_STATE: &str = "orchestration_session_state";
const ORCHESTRATION_SESSION_EXEC: &str = "orchestration_session_exec";
const ORCHESTRATION_SESSION_ISSUE: &str = "orchestration_session_issue";
const ORCHESTRATION_SESSION_ISSUE_RELATION: &str = "orchestration_session_issue_relation";
const ORCHESTRATION_SESSION_LOG: &str = "orchestration_session_log";
const UNIFORM_RESOURCE_GRAPH: &str = "uniform_resource_graph";
const UNIFORM_RESOURCE_EDGE: &str = "uniform_resource_edge";
const SURVEILR_OSQUERY_MS_NODE: &str = "surveilr_osquery_ms_node";
const UR_INGEST_SESSION_OSQUERY_MS_LOG: &str = "ur_ingest_session_osquery_ms_log";
const OSQUERY_POLICY: &str = "osquery_policy";
const SURVEILR_TABLE_SIZE: &str = "surveilr_table_size";
const SURVEILR_OSQUERY_MS_DISTRIBUTED_QUERY: &str = "surveilr_osquery_ms_distributed_query";
const SURVEILR_OSQUERY_MS_DISTRIBUTED_RESULT: &str = "surveilr_osquery_ms_distributed_result";
const SURVEILR_OSQUERY_MS_CARVE: &str = "surveilr_osquery_ms_carve";
const ASSURANCE_SCHEMA: &str = "assurance_schema";
const CODE_NOTEBOOK_KERNEL: &str = "code_notebook_kernel";
const CODE_NOTEBOOK_CELL: &str = "code_notebook_cell";
const CODE_NOTEBOOK_STATE: &str = "code_notebook_state";
*/

// `party_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct PartyType {
    party_type_id: String, // PRIMARY KEY (uknown type ''string::ulid'', mapping to String by default)
    code: String, // ''string'' maps directly to Rust type
    value: String, // ''string'' maps directly to Rust type
}

// `party` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Party {
    party_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    party_type_id: String, // uknown type ''string::ulid'', mapping to String by default
    party_name: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `party_relation_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct PartyRelationType {
    party_relation_type_id: String, // PRIMARY KEY (uknown type ''string::ulid'', mapping to String by default)
    code: String, // ''string'' maps directly to Rust type
    value: String, // ''string'' maps directly to Rust type
}

// `party_relation` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct PartyRelation {
    party_relation_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    party_id: String, // ''string'' maps directly to Rust type
    related_party_id: String, // ''string'' maps directly to Rust type
    relation_type_id: String, // uknown type ''string::ulid'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `gender_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct GenderType {
    gender_type_id: String, // PRIMARY KEY (uknown type ''string::ulid'', mapping to String by default)
    code: String, // ''string'' maps directly to Rust type
    value: String, // ''string'' maps directly to Rust type
}

// `sex_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct SexType {
    sex_type_id: String, // PRIMARY KEY (uknown type ''string::ulid'', mapping to String by default)
    code: String, // ''string'' maps directly to Rust type
    value: String, // ''string'' maps directly to Rust type
}

// `person_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct PersonType {
    person_type_id: String, // PRIMARY KEY (uknown type ''string::ulid'', mapping to String by default)
    code: String, // ''string'' maps directly to Rust type
    value: String, // ''string'' maps directly to Rust type
}

// `person` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Person {
    person_id: String, // PRIMARY KEY (uknown type ''string::ulid'', mapping to String by default)
    party_id: String, // ''string'' maps directly to Rust type
    person_type_id: String, // uknown type ''string::ulid'', mapping to String by default
    person_first_name: String, // ''string'' maps directly to Rust type
    person_middle_name: Option<String>, // ''string'' maps directly to Rust type
    person_last_name: String, // ''string'' maps directly to Rust type
    previous_name: Option<String>, // ''string'' maps directly to Rust type
    honorific_prefix: Option<String>, // ''string'' maps directly to Rust type
    honorific_suffix: Option<String>, // ''string'' maps directly to Rust type
    gender_id: String, // uknown type ''string::ulid'', mapping to String by default
    sex_id: String, // uknown type ''string::ulid'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `organization` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Organization {
    organization_id: String, // PRIMARY KEY (uknown type ''string::ulid'', mapping to String by default)
    party_id: String, // ''string'' maps directly to Rust type
    name: String, // ''string'' maps directly to Rust type
    alias: Option<String>, // ''string'' maps directly to Rust type
    description: Option<String>, // ''string'' maps directly to Rust type
    license: String, // ''string'' maps directly to Rust type
    federal_tax_id_num: Option<String>, // ''string'' maps directly to Rust type
    registration_date: chrono::NaiveDate, // Using chrono crate for ''date''
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `organization_role_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrganizationRoleType {
    organization_role_type_id: String, // PRIMARY KEY (uknown type ''string::ulid'', mapping to String by default)
    code: String, // ''string'' maps directly to Rust type
    value: String, // ''string'' maps directly to Rust type
}

// `organization_role` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrganizationRole {
    organization_role_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    person_id: String, // ''string'' maps directly to Rust type
    organization_id: String, // ''string'' maps directly to Rust type
    organization_role_type_id: String, // uknown type ''string::ulid'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `device` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Device {
    device_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    name: String, // ''string'' maps directly to Rust type
    state: String, // uknown type ''string::json'', mapping to String by default
    boundary: String, // ''string'' maps directly to Rust type
    segmentation: Option<String>, // uknown type ''string::json'', mapping to String by default
    state_sysinfo: Option<String>, // uknown type ''string::json'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    behaviors: Vec<Behavior>, // `behavior` belongsTo collection
    ur_ingest_sessions: Vec<UrIngestSession>, // `ur_ingest_session` belongsTo collection
    uniform_resources: Vec<UniformResource>, // `uniform_resource` belongsTo collection
    orchestration_sessions: Vec<OrchestrationSession>, // `orchestration_session` belongsTo collection
    surveilr_osquery_ms_nodes: Vec<SurveilrOsqueryMsNode>, // `surveilr_osquery_ms_node` belongsTo collection
}

// `device_party_relationship` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct DevicePartyRelationship {
    device_party_relationship_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    device_id: String, // ''string'' maps directly to Rust type
    party_id: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `behavior` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Behavior {
    behavior_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    device_id: String, // ''string'' maps directly to Rust type
    behavior_name: String, // ''string'' maps directly to Rust type
    behavior_conf_json: String, // uknown type ''string::json'', mapping to String by default
    assurance_schema_id: Option<String>, // ''string'' maps directly to Rust type
    governance: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_sessions: Vec<UrIngestSession>, // `ur_ingest_session` belongsTo collection
    surveilr_osquery_ms_nodes: Vec<SurveilrOsqueryMsNode>, // `surveilr_osquery_ms_node` belongsTo collection
}

// `ur_ingest_resource_path_match_rule` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestResourcePathMatchRule {
    ur_ingest_resource_path_match_rule_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    namespace: String, // ''string'' maps directly to Rust type
    regex: String, // ''string'' maps directly to Rust type
    flags: String, // ''string'' maps directly to Rust type
    nature: Option<String>, // ''string'' maps directly to Rust type
    priority: Option<String>, // ''string'' maps directly to Rust type
    description: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_resource_path_rewrite_rule` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestResourcePathRewriteRule {
    ur_ingest_resource_path_rewrite_rule_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    namespace: String, // ''string'' maps directly to Rust type
    regex: String, // ''string'' maps directly to Rust type
    replace: String, // ''string'' maps directly to Rust type
    priority: Option<String>, // ''string'' maps directly to Rust type
    description: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSession {
    ur_ingest_session_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    device_id: String, // ''string'' maps directly to Rust type
    behavior_id: Option<String>, // ''string'' maps directly to Rust type
    behavior_json: Option<String>, // uknown type ''string::json'', mapping to String by default
    ingest_started_at: String, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    ingest_finished_at: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    session_agent: String, // uknown type ''string::json'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_fs_paths: Vec<UrIngestSessionFsPath>, // `ur_ingest_session_fs_path` belongsTo collection
    uniform_resources: Vec<UniformResource>, // `uniform_resource` belongsTo collection
    ur_ingest_session_fs_path_entrys: Vec<UrIngestSessionFsPathEntry>, // `ur_ingest_session_fs_path_entry` belongsTo collection
    ur_ingest_session_imap_accounts: Vec<UrIngestSessionImapAccount>, // `ur_ingest_session_imap_account` belongsTo collection
    ur_ingest_session_imap_acct_folders: Vec<UrIngestSessionImapAcctFolder>, // `ur_ingest_session_imap_acct_folder` belongsTo collection
    ur_ingest_session_imap_acct_folder_messages: Vec<UrIngestSessionImapAcctFolderMessage>, // `ur_ingest_session_imap_acct_folder_message` belongsTo collection
    ur_ingest_session_plm_accounts: Vec<UrIngestSessionPlmAccount>, // `ur_ingest_session_plm_account` belongsTo collection
    ur_ingest_session_plm_acct_projects: Vec<UrIngestSessionPlmAcctProject>, // `ur_ingest_session_plm_acct_project` belongsTo collection
    ur_ingest_session_plm_acct_project_issues: Vec<UrIngestSessionPlmAcctProjectIssue>, // `ur_ingest_session_plm_acct_project_issue` belongsTo collection
    ur_ingest_session_udi_pgp_sqls: Vec<UrIngestSessionUdiPgpSql>, // `ur_ingest_session_udi_pgp_sql` belongsTo collection
}

// `ur_ingest_session_fs_path` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionFsPath {
    ur_ingest_session_fs_path_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ingest_session_id: String, // ''string'' maps directly to Rust type
    root_path: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_fs_path_entrys: Vec<UrIngestSessionFsPathEntry>, // `ur_ingest_session_fs_path_entry` belongsTo collection
}

// `uniform_resource` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UniformResource {
    uniform_resource_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    device_id: String, // ''string'' maps directly to Rust type
    ingest_session_id: String, // ''string'' maps directly to Rust type
    ingest_fs_path_id: Option<String>, // ''string'' maps directly to Rust type
    ingest_session_imap_acct_folder_message: Option<String>, // ''string'' maps directly to Rust type
    ingest_issue_acct_project_id: Option<String>, // ''string'' maps directly to Rust type
    uri: String, // ''string'' maps directly to Rust type
    content_digest: String, // ''string'' maps directly to Rust type
    content: Option<Vec<u8>>, // ''blob'' maps directly to Rust type
    nature: Option<String>, // ''string'' maps directly to Rust type
    size_bytes: Option<i64>, // ''integer'' maps directly to Rust type
    last_modified_at: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    content_fm_body_attrs: Option<String>, // uknown type ''string::json'', mapping to String by default
    frontmatter: Option<String>, // uknown type ''string::json'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    uniform_resource_transforms: Vec<UniformResourceTransform>, // `uniform_resource_transform` belongsTo collection
    ur_ingest_session_attachments: Vec<UrIngestSessionAttachment>, // `ur_ingest_session_attachment` belongsTo collection
    uniform_resource_edges: Vec<UniformResourceEdge>, // `uniform_resource_edge` belongsTo collection
}

// `uniform_resource_transform` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UniformResourceTransform {
    uniform_resource_transform_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    uniform_resource_id: String, // ''string'' maps directly to Rust type
    uri: String, // ''string'' maps directly to Rust type
    content_digest: String, // ''string'' maps directly to Rust type
    content: Option<Vec<u8>>, // ''blob'' maps directly to Rust type
    nature: Option<String>, // ''string'' maps directly to Rust type
    size_bytes: Option<i64>, // ''integer'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_fs_path_entry` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionFsPathEntry {
    ur_ingest_session_fs_path_entry_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ingest_session_id: String, // ''string'' maps directly to Rust type
    ingest_fs_path_id: String, // ''string'' maps directly to Rust type
    uniform_resource_id: Option<String>, // ''string'' maps directly to Rust type
    file_path_abs: String, // ''string'' maps directly to Rust type
    file_path_rel_parent: String, // ''string'' maps directly to Rust type
    file_path_rel: String, // ''string'' maps directly to Rust type
    file_basename: String, // ''string'' maps directly to Rust type
    file_extn: Option<String>, // ''string'' maps directly to Rust type
    captured_executable: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_status: Option<String>, // ''string'' maps directly to Rust type
    ur_diagnostics: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_transformations: Option<String>, // uknown type ''string::json'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_task` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionTask {
    ur_ingest_session_task_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ingest_session_id: String, // ''string'' maps directly to Rust type
    uniform_resource_id: Option<String>, // ''string'' maps directly to Rust type
    captured_executable: String, // uknown type ''string::json'', mapping to String by default
    ur_status: Option<String>, // ''string'' maps directly to Rust type
    ur_diagnostics: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_transformations: Option<String>, // uknown type ''string::json'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_imap_account` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionImapAccount {
    ur_ingest_session_imap_account_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ingest_session_id: String, // ''string'' maps directly to Rust type
    email: Option<String>, // ''string'' maps directly to Rust type
    password: Option<String>, // ''string'' maps directly to Rust type
    host: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_imap_acct_folders: Vec<UrIngestSessionImapAcctFolder>, // `ur_ingest_session_imap_acct_folder` belongsTo collection
}

// `ur_ingest_session_imap_acct_folder` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionImapAcctFolder {
    ur_ingest_session_imap_acct_folder_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ingest_session_id: String, // ''string'' maps directly to Rust type
    ingest_account_id: String, // ''string'' maps directly to Rust type
    folder_name: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_imap_acct_folder_messages: Vec<UrIngestSessionImapAcctFolderMessage>, // `ur_ingest_session_imap_acct_folder_message` belongsTo collection
}

// `ur_ingest_session_imap_acct_folder_message` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionImapAcctFolderMessage {
    ur_ingest_session_imap_acct_folder_message_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ingest_session_id: String, // ''string'' maps directly to Rust type
    ingest_imap_acct_folder_id: String, // ''string'' maps directly to Rust type
    message: String, // ''string'' maps directly to Rust type
    message_id: String, // ''string'' maps directly to Rust type
    subject: String, // ''string'' maps directly to Rust type
    from: String, // ''string'' maps directly to Rust type
    cc: String, // uknown type ''string::json'', mapping to String by default
    bcc: String, // uknown type ''string::json'', mapping to String by default
    status: String, // uknown type ''array::string'', mapping to String by default
    date: Option<chrono::NaiveDate>, // Using chrono crate for ''date''
    email_references: String, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_plm_account` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmAccount {
    ur_ingest_session_plm_account_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ingest_session_id: String, // ''string'' maps directly to Rust type
    provider: String, // ''string'' maps directly to Rust type
    org_name: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_plm_acct_projects: Vec<UrIngestSessionPlmAcctProject>, // `ur_ingest_session_plm_acct_project` belongsTo collection
}

// `ur_ingest_session_plm_acct_project` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmAcctProject {
    ur_ingest_session_plm_acct_project_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ingest_session_id: String, // ''string'' maps directly to Rust type
    ingest_account_id: String, // ''string'' maps directly to Rust type
    parent_project_id: Option<String>, // ''string'' maps directly to Rust type
    name: String, // ''string'' maps directly to Rust type
    description: Option<String>, // ''string'' maps directly to Rust type
    id: Option<String>, // ''string'' maps directly to Rust type
    key: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_plm_acct_project_issues: Vec<UrIngestSessionPlmAcctProjectIssue>, // `ur_ingest_session_plm_acct_project_issue` belongsTo collection
    ur_ingest_session_plm_acct_labels: Vec<UrIngestSessionPlmAcctLabel>, // `ur_ingest_session_plm_acct_label` belongsTo collection
    ur_ingest_session_plm_milestones: Vec<UrIngestSessionPlmMilestone>, // `ur_ingest_session_plm_milestone` belongsTo collection
    ur_ingest_session_plm_acct_relationships: Vec<UrIngestSessionPlmAcctRelationship>, // `ur_ingest_session_plm_acct_relationship` belongsTo collection
}

// `ur_ingest_session_plm_acct_project_issue` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmAcctProjectIssue {
    ur_ingest_session_plm_acct_project_issue_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ingest_session_id: String, // ''string'' maps directly to Rust type
    ur_ingest_session_plm_acct_project_id: String, // ''string'' maps directly to Rust type
    uniform_resource_id: Option<String>, // ''string'' maps directly to Rust type
    issue_id: String, // ''string'' maps directly to Rust type
    issue_number: Option<i64>, // ''integer'' maps directly to Rust type
    parent_issue_id: Option<String>, // ''string'' maps directly to Rust type
    title: String, // ''string'' maps directly to Rust type
    body: Option<String>, // ''string'' maps directly to Rust type
    body_text: Option<String>, // ''string'' maps directly to Rust type
    body_html: Option<String>, // ''string'' maps directly to Rust type
    state: String, // ''string'' maps directly to Rust type
    assigned_to: Option<String>, // ''string'' maps directly to Rust type
    user: String, // ''string'' maps directly to Rust type
    url: String, // ''string'' maps directly to Rust type
    closed_at: Option<String>, // ''string'' maps directly to Rust type
    issue_type_id: Option<String>, // ''string'' maps directly to Rust type
    time_estimate: Option<i64>, // ''integer'' maps directly to Rust type
    aggregate_time_estimate: Option<i64>, // ''integer'' maps directly to Rust type
    time_original_estimate: Option<i64>, // ''integer'' maps directly to Rust type
    time_spent: Option<i64>, // ''integer'' maps directly to Rust type
    aggregate_time_spent: Option<i64>, // ''integer'' maps directly to Rust type
    aggregate_time_original_estimate: Option<i64>, // ''integer'' maps directly to Rust type
    workratio: Option<i64>, // ''integer'' maps directly to Rust type
    current_progress: Option<i64>, // ''integer'' maps directly to Rust type
    total_progress: Option<i64>, // ''integer'' maps directly to Rust type
    resolution_name: Option<String>, // ''string'' maps directly to Rust type
    resolution_date: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_plm_acct_labels: Vec<UrIngestSessionPlmAcctLabel>, // `ur_ingest_session_plm_acct_label` belongsTo collection
    ur_ingest_session_plm_acct_relationships: Vec<UrIngestSessionPlmAcctRelationship>, // `ur_ingest_session_plm_acct_relationship` belongsTo collection
    ur_ingest_session_plm_comments: Vec<UrIngestSessionPlmComment>, // `ur_ingest_session_plm_comment` belongsTo collection
    ur_ingest_session_plm_issue_reactions: Vec<UrIngestSessionPlmIssueReaction>, // `ur_ingest_session_plm_issue_reaction` belongsTo collection
}

// `ur_ingest_session_plm_acct_label` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmAcctLabel {
    ur_ingest_session_plm_acct_label_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ur_ingest_session_plm_acct_project_id: String, // ''string'' maps directly to Rust type
    ur_ingest_session_plm_acct_project_issue_id: String, // ''string'' maps directly to Rust type
    label: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_plm_milestone` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmMilestone {
    ur_ingest_session_plm_milestone_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ur_ingest_session_plm_acct_project_id: String, // ''string'' maps directly to Rust type
    title: String, // ''string'' maps directly to Rust type
    milestone_id: String, // ''string'' maps directly to Rust type
    url: String, // ''string'' maps directly to Rust type
    html_url: String, // ''string'' maps directly to Rust type
    open_issues: Option<i64>, // ''integer'' maps directly to Rust type
    closed_issues: Option<i64>, // ''integer'' maps directly to Rust type
    due_on: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    closed_at: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_plm_acct_relationship` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmAcctRelationship {
    ur_ingest_session_plm_acct_relationship_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ur_ingest_session_plm_acct_project_id_prime: String, // ''string'' maps directly to Rust type
    ur_ingest_session_plm_acct_project_id_related: String, // ''string'' maps directly to Rust type
    ur_ingest_session_plm_acct_project_issue_id_prime: String, // ''string'' maps directly to Rust type
    ur_ingest_session_plm_acct_project_issue_id_related: String, // ''string'' maps directly to Rust type
    relationship: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_plm_user` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmUser {
    ur_ingest_session_plm_user_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    user_id: String, // ''string'' maps directly to Rust type
    login: String, // ''string'' maps directly to Rust type
    email: Option<String>, // ''string'' maps directly to Rust type
    name: Option<String>, // ''string'' maps directly to Rust type
    url: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_plm_acct_project_issues: Vec<UrIngestSessionPlmAcctProjectIssue>, // `ur_ingest_session_plm_acct_project_issue` belongsTo collection
    ur_ingest_session_plm_comments: Vec<UrIngestSessionPlmComment>, // `ur_ingest_session_plm_comment` belongsTo collection
}

// `ur_ingest_session_plm_comment` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmComment {
    ur_ingest_session_plm_comment_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ur_ingest_session_plm_acct_project_issue_id: String, // ''string'' maps directly to Rust type
    comment_id: String, // ''string'' maps directly to Rust type
    node_id: String, // ''string'' maps directly to Rust type
    url: String, // ''string'' maps directly to Rust type
    body: Option<String>, // ''string'' maps directly to Rust type
    body_text: Option<String>, // ''string'' maps directly to Rust type
    body_html: Option<String>, // ''string'' maps directly to Rust type
    user: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_plm_reaction` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmReaction {
    ur_ingest_session_plm_reaction_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    reaction_id: String, // ''string'' maps directly to Rust type
    reaction_type: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_plm_issue_reactions: Vec<UrIngestSessionPlmIssueReaction>, // `ur_ingest_session_plm_issue_reaction` belongsTo collection
}

// `ur_ingest_session_plm_issue_reaction` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmIssueReaction {
    ur_ingest_session_plm_issue_reaction_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    ur_ingest_plm_reaction_id: String, // ''string'' maps directly to Rust type
    ur_ingest_plm_issue_id: String, // ''string'' maps directly to Rust type
    count: i64, // ''integer'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_plm_issue_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionPlmIssueType {
    ur_ingest_session_plm_issue_type_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    avatar_id: Option<String>, // ''string'' maps directly to Rust type
    description: String, // ''string'' maps directly to Rust type
    icon_url: String, // ''string'' maps directly to Rust type
    id: String, // ''string'' maps directly to Rust type
    name: String, // ''string'' maps directly to Rust type
    subtask: bool, // ''boolean'' maps directly to Rust type
    url: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    ur_ingest_session_plm_acct_project_issues: Vec<UrIngestSessionPlmAcctProjectIssue>, // `ur_ingest_session_plm_acct_project_issue` belongsTo collection
}

// `ur_ingest_session_attachment` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionAttachment {
    ur_ingest_session_attachment_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    uniform_resource_id: Option<String>, // ''string'' maps directly to Rust type
    name: Option<String>, // ''string'' maps directly to Rust type
    uri: String, // ''string'' maps directly to Rust type
    content: Option<Vec<u8>>, // ''blob'' maps directly to Rust type
    nature: Option<String>, // ''string'' maps directly to Rust type
    size: Option<i64>, // ''integer'' maps directly to Rust type
    checksum: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `ur_ingest_session_udi_pgp_sql` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionUdiPgpSql {
    ur_ingest_session_udi_pgp_sql_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    sql: String, // ''string'' maps directly to Rust type
    nature: String, // ''string'' maps directly to Rust type
    content: Option<Vec<u8>>, // ''blob'' maps directly to Rust type
    behaviour: Option<String>, // uknown type ''string::json'', mapping to String by default
    query_error: Option<String>, // ''string'' maps directly to Rust type
    uniform_resource_id: Option<String>, // ''string'' maps directly to Rust type
    ingest_session_id: Option<String>, // ''string'' maps directly to Rust type
}

// `orchestration_nature` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrchestrationNature {
    orchestration_nature_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    nature: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    orchestration_sessions: Vec<OrchestrationSession>, // `orchestration_session` belongsTo collection
}

// `orchestration_session` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrchestrationSession {
    orchestration_session_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    device_id: String, // ''string'' maps directly to Rust type
    orchestration_nature_id: String, // ''string'' maps directly to Rust type
    version: String, // ''string'' maps directly to Rust type
    orch_started_at: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    orch_finished_at: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    args_json: Option<String>, // uknown type ''string::json'', mapping to String by default
    diagnostics_json: Option<String>, // uknown type ''string::json'', mapping to String by default
    diagnostics_md: Option<String>, // ''string'' maps directly to Rust type
    orchestration_session_entrys: Vec<OrchestrationSessionEntry>, // `orchestration_session_entry` belongsTo collection
    orchestration_session_states: Vec<OrchestrationSessionState>, // `orchestration_session_state` belongsTo collection
    orchestration_session_execs: Vec<OrchestrationSessionExec>, // `orchestration_session_exec` belongsTo collection
    orchestration_session_issues: Vec<OrchestrationSessionIssue>, // `orchestration_session_issue` belongsTo collection
}

// `orchestration_session_entry` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrchestrationSessionEntry {
    orchestration_session_entry_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    session_id: String, // ''string'' maps directly to Rust type
    ingest_src: String, // ''string'' maps directly to Rust type
    ingest_table_name: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    orchestration_session_states: Vec<OrchestrationSessionState>, // `orchestration_session_state` belongsTo collection
    orchestration_session_execs: Vec<OrchestrationSessionExec>, // `orchestration_session_exec` belongsTo collection
    orchestration_session_issues: Vec<OrchestrationSessionIssue>, // `orchestration_session_issue` belongsTo collection
}

// `orchestration_session_state` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrchestrationSessionState {
    orchestration_session_state_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    session_id: String, // ''string'' maps directly to Rust type
    session_entry_id: Option<String>, // ''string'' maps directly to Rust type
    from_state: String, // ''string'' maps directly to Rust type
    to_state: String, // ''string'' maps directly to Rust type
    transition_result: Option<String>, // uknown type ''string::json'', mapping to String by default
    transition_reason: Option<String>, // ''string'' maps directly to Rust type
    transitioned_at: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `orchestration_session_exec` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrchestrationSessionExec {
    orchestration_session_exec_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    exec_nature: String, // ''string'' maps directly to Rust type
    session_id: String, // ''string'' maps directly to Rust type
    session_entry_id: Option<String>, // ''string'' maps directly to Rust type
    parent_exec_id: Option<String>, // ''string'' maps directly to Rust type
    namespace: Option<String>, // ''string'' maps directly to Rust type
    exec_identity: Option<String>, // ''string'' maps directly to Rust type
    exec_code: String, // ''string'' maps directly to Rust type
    exec_status: i64, // ''integer'' maps directly to Rust type
    input_text: Option<String>, // ''string'' maps directly to Rust type
    exec_error_text: Option<String>, // ''string'' maps directly to Rust type
    output_text: Option<String>, // ''string'' maps directly to Rust type
    output_nature: Option<String>, // uknown type ''string::json'', mapping to String by default
    narrative_md: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `orchestration_session_issue` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrchestrationSessionIssue {
    orchestration_session_issue_id: String, // PRIMARY KEY (uknown type ''string::uuid'', mapping to String by default)
    session_id: String, // ''string'' maps directly to Rust type
    session_entry_id: Option<String>, // ''string'' maps directly to Rust type
    issue_type: String, // ''string'' maps directly to Rust type
    issue_message: String, // ''string'' maps directly to Rust type
    issue_row: Option<i64>, // ''integer'' maps directly to Rust type
    issue_column: Option<String>, // ''string'' maps directly to Rust type
    invalid_value: Option<String>, // ''string'' maps directly to Rust type
    remediation: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    orchestration_session_issue_relations: Vec<OrchestrationSessionIssueRelation>, // `orchestration_session_issue_relation` belongsTo collection
}

// `orchestration_session_issue_relation` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrchestrationSessionIssueRelation {
    orchestration_session_issue_relation_id: String, // PRIMARY KEY (uknown type ''string::uuid'', mapping to String by default)
    issue_id_prime: String, // uknown type ''string::uuid'', mapping to String by default
    issue_id_rel: String, // ''string'' maps directly to Rust type
    relationship_nature: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `orchestration_session_log` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrchestrationSessionLog {
    orchestration_session_log_id: String, // PRIMARY KEY (uknown type ''string::uuid'', mapping to String by default)
    category: Option<String>, // ''string'' maps directly to Rust type
    parent_exec_id: Option<String>, // uknown type ''string::uuid'', mapping to String by default
    content: String, // ''string'' maps directly to Rust type
    sibling_order: Option<i64>, // ''integer'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `uniform_resource_graph` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UniformResourceGraph {
    name: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    uniform_resource_edges: Vec<UniformResourceEdge>, // `uniform_resource_edge` belongsTo collection
}

// `uniform_resource_edge` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UniformResourceEdge {
    graph_name: String, // ''string'' maps directly to Rust type
    nature: String, // ''string'' maps directly to Rust type
    node_id: String, // ''string'' maps directly to Rust type
    uniform_resource_id: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `surveilr_osquery_ms_node` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct SurveilrOsqueryMsNode {
    surveilr_osquery_ms_node_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    node_key: String, // ''string'' maps directly to Rust type
    host_identifier: String, // ''string'' maps directly to Rust type
    tls_cert_subject: Option<String>, // ''string'' maps directly to Rust type
    os_version: String, // ''string'' maps directly to Rust type
    platform: String, // ''string'' maps directly to Rust type
    last_seen: String, // uknown type ''TIMESTAMP'', mapping to String by default
    status: String, // ''string'' maps directly to Rust type
    osquery_version: Option<String>, // ''string'' maps directly to Rust type
    osquery_build_platform: String, // ''string'' maps directly to Rust type
    device_id: String, // ''string'' maps directly to Rust type
    behavior_id: Option<String>, // ''string'' maps directly to Rust type
    accelerate: i64, // ''integer'' maps directly to Rust type
    ur_ingest_session_osquery_ms_logs: Vec<UrIngestSessionOsqueryMsLog>, // `ur_ingest_session_osquery_ms_log` belongsTo collection
    surveilr_osquery_ms_distributed_querys: Vec<SurveilrOsqueryMsDistributedQuery>, // `surveilr_osquery_ms_distributed_query` belongsTo collection
    surveilr_osquery_ms_distributed_results: Vec<SurveilrOsqueryMsDistributedResult>, // `surveilr_osquery_ms_distributed_result` belongsTo collection
    surveilr_osquery_ms_carves: Vec<SurveilrOsqueryMsCarve>, // `surveilr_osquery_ms_carve` belongsTo collection
}

// `ur_ingest_session_osquery_ms_log` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct UrIngestSessionOsqueryMsLog {
    ur_ingest_session_osquery_ms_log_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    node_key: String, // ''string'' maps directly to Rust type
    log_type: String, // ''string'' maps directly to Rust type
    log_data: String, // uknown type ''string::json'', mapping to String by default
    applied_jq_filters: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `osquery_policy` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OsqueryPolicy {
    osquery_policy_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    policy_group: Option<String>, // ''string'' maps directly to Rust type
    policy_name: String, // ''string'' maps directly to Rust type
    osquery_code: String, // ''string'' maps directly to Rust type
    policy_description: String, // ''string'' maps directly to Rust type
    policy_pass_label: String, // ''string'' maps directly to Rust type
    policy_fail_label: String, // ''string'' maps directly to Rust type
    policy_pass_remarks: Option<String>, // ''string'' maps directly to Rust type
    policy_fail_remarks: Option<String>, // ''string'' maps directly to Rust type
    osquery_platforms: Option<String>, // ''string'' maps directly to Rust type
}

// `surveilr_table_size` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct SurveilrTableSize {
    table_name: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    table_size_mb: i64, // ''integer'' maps directly to Rust type
}

// `surveilr_osquery_ms_distributed_query` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct SurveilrOsqueryMsDistributedQuery {
    query_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    node_key: String, // ''string'' maps directly to Rust type
    query_name: String, // ''string'' maps directly to Rust type
    query_sql: String, // ''string'' maps directly to Rust type
    discovery_query: Option<String>, // ''string'' maps directly to Rust type
    status: String, // ''string'' maps directly to Rust type
    surveilr_osquery_ms_distributed_results: Vec<SurveilrOsqueryMsDistributedResult>, // `surveilr_osquery_ms_distributed_result` belongsTo collection
}

// `surveilr_osquery_ms_distributed_result` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct SurveilrOsqueryMsDistributedResult {
    surveilr_osquery_ms_distributed_result_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    query_id: String, // ''string'' maps directly to Rust type
    node_key: String, // ''string'' maps directly to Rust type
    results: String, // uknown type ''string::json'', mapping to String by default
    status_code: i64, // ''integer'' maps directly to Rust type
}

// `surveilr_osquery_ms_carve` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct SurveilrOsqueryMsCarve {
    surveilr_osquery_ms_carve_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    node_key: String, // ''string'' maps directly to Rust type
    session_id: String, // ''string'' maps directly to Rust type
    carve_guid: String, // ''string'' maps directly to Rust type
    carve_size: i64, // ''integer'' maps directly to Rust type
    block_count: i64, // ''integer'' maps directly to Rust type
    block_size: i64, // ''integer'' maps directly to Rust type
    received_blocks: i64, // ''integer'' maps directly to Rust type
    carve_path: Option<String>, // ''string'' maps directly to Rust type
    status: String, // ''string'' maps directly to Rust type
    start_time: String, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    completion_time: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
}

// `assurance_schema` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct AssuranceSchema {
    assurance_schema_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    assurance_type: String, // ''string'' maps directly to Rust type
    code: String, // ''string'' maps directly to Rust type
    code_json: Option<String>, // uknown type ''string::json'', mapping to String by default
    governance: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `code_notebook_kernel` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct CodeNotebookKernel {
    code_notebook_kernel_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    kernel_name: String, // ''string'' maps directly to Rust type
    description: Option<String>, // ''string'' maps directly to Rust type
    mime_type: Option<String>, // ''string'' maps directly to Rust type
    file_extn: Option<String>, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
    governance: Option<String>, // uknown type ''string::json'', mapping to String by default
    code_notebook_cells: Vec<CodeNotebookCell>, // `code_notebook_cell` belongsTo collection
}

// `code_notebook_cell` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct CodeNotebookCell {
    code_notebook_cell_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    notebook_kernel_id: String, // ''string'' maps directly to Rust type
    notebook_name: String, // ''string'' maps directly to Rust type
    cell_name: String, // ''string'' maps directly to Rust type
    cell_governance: Option<String>, // uknown type ''string::json'', mapping to String by default
    interpretable_code: String, // ''string'' maps directly to Rust type
    interpretable_code_hash: String, // ''string'' maps directly to Rust type
    description: Option<String>, // ''string'' maps directly to Rust type
    arguments: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `code_notebook_state` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct CodeNotebookState {
    code_notebook_state_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    code_notebook_cell_id: String, // ''string'' maps directly to Rust type
    from_state: String, // ''string'' maps directly to Rust type
    to_state: String, // ''string'' maps directly to Rust type
    transition_result: Option<String>, // uknown type ''string::json'', mapping to String by default
    transition_reason: Option<String>, // ''string'' maps directly to Rust type
    transitioned_at: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}
', 'b3583f3c6e8803bfe36697656cd1cfeb125195d1', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W5RGM2BD2XDXTRQ5AR', 'SQL', 'osQuery Management Server (Prime)', 'System Information', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["macos","windows","linux"],"singleton":false}', 'SELECT * FROM system_info', '16cc9b141b5e3a1b60906bd4cb62ac9398960134', 'System information for identification.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W5FFQRZ5FEKEHKSWGS', 'SQL', 'osQuery Management Server (Prime)', 'osquery-ms Boundary (Linux and Macos)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["linux","macos"],"singleton":true}', 'SELECT DISTINCT value, key FROM process_envs WHERE key=''SURVEILR_OSQUERY_BOUNDARY'';', '60b8b75382b3f448b8d7b12e74ed4dd598dde45e', 'Get the boundary for a node.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W5CEWF2J4WF9S58D0K', 'SQL', 'osQuery Management Server (Prime)', 'osquery-ms Boundary (Windows)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["windows"],"singleton":true}', 'SELECT DISTINCT value, variable FROM default_environment WHERE variable=''SURVEILR_OSQUERY_BOUNDARY'';', 'c00e47a212d24e153372d5e232d0044502deeee3', 'Get the boundary for a node.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6YGG8EHHE21ZRDF0P', 'SQL', 'osQuery Management Server (Prime)', 'OS Version (Linux and Macos)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["macos","linux"],"singleton":false}', 'SELECT
    os.name,
    os.major,
    os.minor,
    os.patch,
    os.extra,
    os.build,
    os.arch,
    os.platform,
    os.version AS version,
    k.version AS kernel_version
  FROM
    os_version os,
    kernel_info k;
', '6e0cb5aa60ef1b85e152db0d0d8ab291e6b26fef', 'A single row containing the operating system name and version.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W61NE3707EHGT019EB', 'SQL', 'osQuery Management Server (Prime)', 'OS Version (Windows)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["windows"],"singleton":false}', '
    WITH display_version_table AS (
      SELECT data as display_version
      FROM registry
      WHERE path = ''HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DisplayVersion''
    ),
    ubr_table AS (
      SELECT data AS ubr
      FROM registry
      WHERE path =''HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UBR''
    )
    SELECT
      os.name,
      COALESCE(d.display_version, '''') AS display_version,
      COALESCE(CONCAT((SELECT version FROM os_version), ''.'', u.ubr), k.version) AS version
    FROM
      os_version os,
      kernel_info k
    LEFT JOIN
      display_version_table d
    LEFT JOIN
      ubr_table u;
', 'f4e22e551b3b8a052e4d09bfe4dc9b326475cfa7', 'A single row containing the operating system name and version.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6TRDG16KQ80JWA5DV', 'SQL', 'osQuery Management Server (Prime)', 'Users', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["macos","windows","linux"],"singleton":false}', 'SELECT * FROM users', 'e9e19fac540eec4a59c5f12011f012b46295cbd7', 'Local user accounts (including domain accounts that have logged on locally (Windows)).', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6TJW4P3ZCF3M2M1JP', 'SQL', 'osQuery Management Server (Prime)', 'Network Interfaces (Windows)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["windows"],"singleton":false}', '
      SELECT
          ia.address,
          id.mac
      FROM
          interface_addresses ia
          JOIN interface_details id ON id.interface = ia.interface
          JOIN routes r ON r.interface = ia.address
      WHERE
          (r.destination = ''0.0.0.0'' OR r.destination = ''::'') AND r.netmask = 0
          AND r.type = ''remote''
          AND (
          inet_aton(ia.address) IS NOT NULL AND (
            split(ia.address, ''.'', 0) = ''10''
            OR (split(ia.address, ''.'', 0) = ''172'' AND (CAST(split(ia.address, ''.'', 1) AS INTEGER) & 0xf0) = 16)
            OR (split(ia.address, ''.'', 0) = ''192'' AND split(ia.address, ''.'', 1) = ''168'')
          )
          OR (inet_aton(ia.address) IS NULL AND regex_match(lower(ia.address), ''^f[cd][0-9a-f][0-9a-f]:[0-9a-f:]+'', 0) IS NOT NULL)
        )
      ORDER BY
          r.metric ASC,
        inet_aton(ia.address) IS NOT NULL DESC
      LIMIT 1;
    ', '52ec98e0821879a6a0a682198fdfa58944883117', 'Retrieves information about network interfaces on devices running windows.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6YYKFFZ554TPBQBAS', 'SQL', 'osQuery Management Server (Prime)', 'Network Interfaces (Linux and Macos)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["macos","linux"],"singleton":false}', '
      SELECT
          ia.address,
          id.mac
      FROM
          interface_addresses ia
          JOIN interface_details id ON id.interface = ia.interface
          JOIN routes r ON r.interface = ia.interface
      WHERE
          (r.destination = ''0.0.0.0'' OR r.destination = ''::'') AND r.netmask = 0
          AND r.type = ''gateway''
          AND (
          inet_aton(ia.address) IS NOT NULL AND (
            split(ia.address, ''.'', 0) = ''10''
            OR (split(ia.address, ''.'', 0) = ''172'' AND (CAST(split(ia.address, ''.'', 1) AS INTEGER) & 0xf0) = 16)
            OR (split(ia.address, ''.'', 0) = ''192'' AND split(ia.address, ''.'', 1) = ''168'')
          )
          OR (inet_aton(ia.address) IS NULL AND regex_match(lower(ia.address), ''^f[cd][0-9a-f][0-9a-f]:[0-9a-f:]+'', 0) IS NOT NULL)
        )
      ORDER BY
          r.metric ASC,
        inet_aton(ia.address) IS NOT NULL DESC
      LIMIT 1;
    ', '1cd5770b43255896ffe106b12cd34bb4ebcc2f94', 'Retrieves information about network interfaces on macOS and Linux devices.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6YNYWH6BATSSR5GXG', 'SQL', 'osQuery Management Server (Prime)', 'Listening Ports', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["macos","windows","linux"],"singleton":false}', 'SELECT p.name, p.path FROM listening_ports l JOIN processes p USING (pid);', 'e8bf48851505286fbe16ae3e60e090fa76d44e9a', 'Processes with listening (bound) network sockets/ports.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6XG6P44KRYXA4WJZW', 'SQL', 'osQuery Management Server (Prime)', 'Server Uptime', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["linux","macos","windows"],"singleton":true}', 'SELECT * FROM uptime LIMIT 1;', '5deb02948d93120fa7fc1493ebfcc1d8cb058cac', 'Track time passed since last boot. Some systems track this as calendar time, some as runtime.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6AK0JQXJX5ES9WYJR', 'SQL', 'osQuery Management Server (Prime)', 'Available Disk Space (Windows)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["windows"],"singleton":true}', '
    SELECT 
      ROUND((sum(free_space) * 100 * 10e-10) / (sum(size) * 10e-10)) AS percent_disk_space_available,
      ROUND(sum(free_space) * 10e-10) AS gigs_disk_space_available,
      ROUND(sum(size)       * 10e-10) AS gigs_total_disk_space
    FROM logical_drives
    WHERE file_system = ''NTFS'' LIMIT 1;
', '036aa64aaa0b78a846ae3914f9627833493a4de0', 'Retrieves total amount of free disk space on a Windows host.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W652NY8A4HGFR4Q4F9', 'SQL', 'osQuery Management Server (Prime)', 'Available Disk Space (Linux and Macos)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["macos","linux"],"singleton":true}', '
    SELECT 
      (blocks_available * 100 / blocks) AS percent_disk_space_available,
      round((blocks_available * blocks_size * 10e-10),2) AS gigs_disk_space_available,
      round((blocks           * blocks_size * 10e-10),2) AS gigs_total_disk_space
    FROM mounts
    WHERE path = ''/'' LIMIT 1;
', '2b5a8e3ea725a39ed1cbe191c55e3910756934a5', 'Retrieves total amount of free disk space on a host.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6MNXE0SMJQGAE1EGG', 'SQL', 'osQuery Management Server (Prime)', 'Installed Linux software', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["linux"],"singleton":false}', 'SELECT name AS name, version AS version, ''Package (APT)'' AS type, ''apt_sources'' AS source FROM apt_sources UNION SELECT name AS name, version AS version, ''Package (deb)'' AS type, ''deb_packages'' AS source FROM deb_packages UNION SELECT package AS name, version AS version, ''Package (Portage)'' AS type, ''portage_packages'' AS source FROM portage_packages UNION SELECT name AS name, version AS version, ''Package (RPM)'' AS type, ''rpm_packages'' AS source FROM rpm_packages UNION SELECT name AS name, '''' AS version, ''Package (YUM)'' AS type, ''yum_sources'' AS source FROM yum_sources UNION SELECT name AS name, version AS version, ''Package (NPM)'' AS type, ''npm_packages'' AS source FROM npm_packages UNION SELECT name AS name, version AS version, ''Package (Python)'' AS type, ''python_packages'' AS source FROM python_packages;', 'abda553be1ed4d34a8bd4e77363dd7f37fa539d3', 'Get all software installed on a Linux computer, including browser plugins and installed packages. Note that this does not include other running processes in the processes table.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6CVEBFBC939BC9RVP', 'SQL', 'osQuery Management Server (Prime)', 'Installed Windows software', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["windows"],"singleton":false}', 'SELECT name AS name, version AS version, ''Program (Windows)'' AS type, ''programs'' AS source FROM programs UNION SELECT name AS name, version AS version, ''Package (Python)'' AS type, ''python_packages'' AS source FROM python_packages UNION SELECT name AS name, version AS version, ''Browser plugin (IE)'' AS type, ''ie_extensions'' AS source FROM ie_extensions UNION SELECT name AS name, version AS version, ''Browser plugin (Chrome)'' AS type, ''chrome_extensions'' AS source FROM chrome_extensions UNION SELECT name AS name, version AS version, ''Browser plugin (Firefox)'' AS type, ''firefox_addons'' AS source FROM firefox_addons UNION SELECT name AS name, version AS version, ''Package (Chocolatey)'' AS type, ''chocolatey_packages'' AS source FROM chocolatey_packages;', '1e622648e651cf19427938c2b38b19799a5031fb', 'Get all software installed on a Windows computer, including browser plugins and installed packages. Note that this does not include other running processes in the processes table.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6NQ2S1QEWRANX4QJH', 'SQL', 'osQuery Management Server (Prime)', 'Installed Macos software', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["macos"],"singleton":false}', 'SELECT name AS name, bundle_short_version AS version, ''Application (macOS)'' AS type, ''apps'' AS source FROM apps UNION SELECT name AS name, version AS version, ''Package (Python)'' AS type, ''python_packages'' AS source FROM python_packages UNION SELECT name AS name, version AS version, ''Browser plugin (Chrome)'' AS type, ''chrome_extensions'' AS source FROM chrome_extensions UNION SELECT name AS name, version AS version, ''Browser plugin (Firefox)'' AS type, ''firefox_addons'' AS source FROM firefox_addons UNION SELECT name As name, version AS version, ''Browser plugin (Safari)'' AS type, ''safari_extensions'' AS source FROM safari_extensions UNION SELECT name AS name, version AS version, ''Package (Homebrew)'' AS type, ''homebrew_packages'' AS source FROM homebrew_packages;', 'a973cdb375729f51dd14db9ec483efa027a5605a', 'Get all software installed on a Macos computer, including browser plugins and installed packages. Note that this does not include other running processes in the processes table.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W61HW40D3C4NFJQ4AE', 'SQL', 'osQuery Management Server (Policy)', 'SSH keys encrypted', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["macos","windows","linux"],"singleton":false,"policy":{"required_note":"osQuery must have Full Disk Access.","resolution":"Use this command to encrypt existing SSH keys by providing the path to the file: ssh-keygen -o -p -f /path/to/file","critical":false}}', 'SELECT 
  CASE 
    WHEN NOT EXISTS (
      SELECT 1
      FROM users
      CROSS JOIN user_ssh_keys USING (uid)
      WHERE encrypted = ''0''
    ) THEN ''true'' 
    ELSE ''false'' 
  END AS policy_result;
', '29269559512160a40089a61a32aa745ae8315dc8', 'Policy passes if all keys are encrypted, including if no keys are present.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W676PXNXES8TZA8YJW', 'SQL', 'osQuery Management Server (Policy)', 'Full disk encryption enabled (Linux)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["linux"],"singleton":false,"policy":{"required_note":"Checks if the root drive is encrypted. There are many ways to encrypt Linux systems. This is the default on distributions such as Ubuntu.","resolution":"Ensure the image deployed to your Linux workstation includes full disk encryption.","critical":false}}', 'SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM mounts m
      JOIN disk_encryption d ON m.device_alias = d.name
      WHERE d.encrypted = 1 AND m.path = ''/''
    ) THEN ''true''
    ELSE ''false''
  END AS policy_result;
', '5ed53ba8be27d69b071b3d26f839c478b569ee10', 'Checks if the root drive is encrypted.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W66MA4F2R797H0F5DZ', 'SQL', 'osQuery Management Server (Policy)', 'Full disk encryption enabled (Windows)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["windows"],"singleton":false,"policy":{"required_note":"Checks to make sure that full disk encryption is enabled on Windows devices.","resolution":"To get additional information, run the following osquery query on the failing device: SELECT * FROM bitlocker_info. In the query results, if protection_status is 2, then the status cannot be determined. If it is 0, it is considered unprotected. Use the additional results (percent_encrypted, conversion_status, etc.) to help narrow down the specific reason why Windows considers the volume unprotected.","critical":false}}', 'SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM bitlocker_info 
      WHERE drive_letter = ''C:'' AND protection_status = 1
    ) THEN ''true''
    ELSE ''false''
  END AS policy_result;
', '72cd8802ce981e6577e12fff7b0b27b82e868322', 'Checks if the root drive is encrypted.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6QMQZ041KRYFEBADT', 'SQL', 'osQuery Management Server (Policy)', 'Full disk encryption enabled (Macos)', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":["macos"],"singleton":false,"policy":{"required_note":"Checks to make sure that full disk encryption (FileVault) is enabled on macOS devices.","resolution":"To enable full disk encryption, on the failing device, select System Preferences > Security & Privacy > FileVault > Turn On FileVault.","critical":false}}', 'SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM disk_encryption 
      WHERE user_uuid IS NOT '''' AND filevault_status = ''on''
      LIMIT 1
    ) THEN ''true''
    ELSE ''false''
  END AS policy_result;
', '858f800d3e08eda51d7b75f8d5b3f0c0b5c9a1d9', 'Checks if the root drive is encrypted.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01JS1BQ3W6KE9C7M8AWVQ1WWDX', 'SQL', 'osQuery Management Server Default Filters (Prime)', 'osQuery Result Filters', '{"osquery-ms-interval":60,"results-uniform-resource-store-jq-filters":["del(.calendarTime, .unixTime, .action, .counter)"],"results-uniform-resource-captured-jq-filters":["{calendarTime, unixTime}"],"targets":[],"singleton":false}', '
/* ''osQuery Result Filters'' in ''[object Object]'' returned type object instead of string | string[] | SQLa.SqlTextSupplier */', 'ddd50b8cb0ecadd87bf0b53b1d06a9d92de4e4bf', 'Default filters for post-processing the results from osQuery.', NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
-- code provenance: `ConsoleSqlPages.infoSchemaDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

-- console_information_schema_* are convenience views
-- to make it easier to work than pragma_table_info.
-- select 'test' into absolute_url;
DROP VIEW IF EXISTS console_information_schema_table;
CREATE VIEW console_information_schema_table AS

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
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with view-specific information
DROP VIEW IF EXISTS console_information_schema_view;
CREATE VIEW console_information_schema_view AS
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
WHERE vw.type = 'view' AND vw.name NOT LIKE 'sqlite_%';

DROP VIEW IF EXISTS console_content_tabular;
CREATE VIEW console_content_tabular AS
  SELECT 'table' as tabular_nature,
         table_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_table
  UNION ALL
  SELECT 'view' as tabular_nature,
         view_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_view;

-- Populate the table with table column foreign keys
DROP VIEW IF EXISTS console_information_schema_table_col_fkey;
CREATE VIEW console_information_schema_table_col_fkey AS
SELECT
    tbl.name AS table_name,
    f."from" AS column_name,
    f."from" || ' references ' || f."table" || '.' || f."to" AS foreign_key
FROM sqlite_master tbl
JOIN pragma_foreign_key_list(tbl.name) f
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with table column indexes
DROP VIEW IF EXISTS console_information_schema_table_col_index;
CREATE VIEW console_information_schema_table_col_index AS
SELECT
    tbl.name AS table_name,
    pi.name AS column_name,
    idx.name AS index_name
FROM sqlite_master tbl
JOIN pragma_index_list(tbl.name) idx
JOIN pragma_index_info(idx.name) pi
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

DROP VIEW IF EXISTS rssd_statistics_overview;
CREATE VIEW rssd_statistics_overview AS
SELECT 
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024), 2) FROM pragma_page_count(), pragma_page_size()) AS db_size_mb,
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024 * 1024), 4) FROM pragma_page_count(), pragma_page_size()) AS db_size_gb,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'table') AS total_tables,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'index') AS total_indexes,
    (SELECT SUM(tbl_rows) FROM (
        SELECT name, 
              (SELECT COUNT(*) FROM sqlite_master sm WHERE sm.type='table' AND sm.name=t.name) AS tbl_rows
        FROM sqlite_master t WHERE type='table'
    )) AS total_rows,
    (SELECT page_size FROM pragma_page_size()) AS page_size,
    (SELECT page_count FROM pragma_page_count()) AS total_pages;

CREATE TABLE IF NOT EXISTS surveilr_table_size (
    table_name TEXT PRIMARY KEY,
    table_size_mb REAL
);
DROP VIEW IF EXISTS rssd_table_statistic;
CREATE VIEW rssd_table_statistic AS
SELECT 
    m.name AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info(m.name)) AS total_columns,
    (SELECT COUNT(*) FROM pragma_index_list(m.name)) AS total_indexes,
    (SELECT COUNT(*) FROM pragma_foreign_key_list(m.name)) AS foreign_keys,
    (SELECT COUNT(*) FROM pragma_table_info(m.name) WHERE pk != 0) AS primary_keys,
    (SELECT table_size_mb FROM surveilr_table_size WHERE table_name = m.name) AS table_size_mb
FROM sqlite_master m
WHERE m.type = 'table';

-- Drop and create the table for storing navigation entries
-- for testing only: DROP TABLE IF EXISTS sqlpage_aide_navigation;
CREATE TABLE IF NOT EXISTS sqlpage_aide_navigation (
    path TEXT NOT NULL, -- the "primary key" within namespace
    caption TEXT NOT NULL, -- for human-friendly general-purpose name
    namespace TEXT NOT NULL, -- if more than one navigation tree is required
    parent_path TEXT, -- for defining hierarchy
    sibling_order INTEGER, -- orders children within their parent(s)
    url TEXT, -- for supplying links, if different from path
    title TEXT, -- for full titles when elaboration is required, default to caption if NULL
    abbreviated_caption TEXT, -- for breadcrumbs and other "short" form, default to caption if NULL
    description TEXT, -- for elaboration or explanation
    elaboration TEXT, -- optional attributes for e.g. { "target": "__blank" }
    -- TODO: figure out why Rusqlite does not allow this but sqlite3 does
    -- CONSTRAINT fk_parent_path FOREIGN KEY (namespace, parent_path) REFERENCES sqlpage_aide_navigation(namespace, path),
    CONSTRAINT unq_ns_path UNIQUE (namespace, parent_path, path)
);
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'console/%';
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'index.sql';

-- all @navigation decorated entries are automatically added to this.navigation
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', NULL, 1, 'index.sql', 'index.sql', 'Home', NULL, 'Resource Surveillance State Database (RSSD)', 'Welcome to Resource Surveillance State Database (RSSD)', NULL),
    ('prime', 'index.sql', 999, 'console/index.sql', 'console/index.sql', 'RSSD Console', 'Console', 'Resource Surveillance State Database (RSSD) Console', 'Explore RSSD information schema, code notebooks, and SQLPage files', NULL),
    ('prime', 'console/index.sql', 1, 'console/info-schema/index.sql', 'console/info-schema/index.sql', 'RSSD Information Schema', 'Info Schema', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/index.sql', 'console/sqlpage-files/index.sql', 'RSSD SQLPage Files', 'SQLPage Files', NULL, 'Explore RSSD SQLPage Files which govern the content of the web-UI', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/content.sql', 'console/sqlpage-files/content.sql', 'RSSD Data Tables Content SQLPage Files', 'Content SQLPage Files', NULL, 'Explore auto-generated RSSD SQLPage Files which display content within tables', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-nav/index.sql', 'console/sqlpage-nav/index.sql', 'RSSD SQLPage Navigation', 'SQLPage Navigation', NULL, 'See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table', NULL),
    ('prime', 'console/index.sql', 2, 'console/notebooks/index.sql', 'console/notebooks/index.sql', 'RSSD Code Notebooks', 'Code Notebooks', NULL, 'Explore RSSD Code Notebooks which contain reusable SQL and other code blocks', NULL),
    ('prime', 'console/index.sql', 2, 'console/migrations/index.sql', 'console/migrations/index.sql', 'RSSD Lifecycle (migrations)', 'Migrations', NULL, 'Explore RSSD Migrations to determine what was executed and not', NULL),
    ('prime', 'console/index.sql', 2, 'console/about.sql', 'console/about.sql', 'Resource Surveillance Details', 'About', NULL, 'Detailed information about the underlying surveilr binary', NULL),
    ('prime', 'console/index.sql', 1, 'console/statistics/index.sql', 'console/statistics/index.sql', 'RSSD Statistics', 'Statistics', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;

INSERT OR REPLACE INTO code_notebook_cell (notebook_kernel_id, code_notebook_cell_id, notebook_name, cell_name, interpretable_code, interpretable_code_hash, description) VALUES (
  'SQL',
  'web-ui.auto_generate_console_content_tabular_sqlpage_files',
  'Web UI',
  'auto_generate_console_content_tabular_sqlpage_files',
  '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows',
  'TODO',
  'A series of idempotent INSERT statements which will auto-generate "default" content for all tables and views'
);
      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in '*.auto.sql' with redirects
      DELETE FROM sqlpage_files WHERE path like 'console/content/table/%.auto.sql';
      DELETE FROM sqlpage_files WHERE path like 'console/content/view/%.auto.sql';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql',
            'SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;

              SELECT ''breadcrumb'' AS component;
              SELECT ''Home'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
              SELECT ''Console'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console'' AS link;
              SELECT ''Content'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content'' AS link;
              SELECT ''' || tabular_name  || ' ' || tabular_nature || ''' as title, ''#'' AS link;

              SELECT ''title'' AS component, ''' || tabular_name || ' (' || tabular_nature || ') Content'' as contents;

              SET total_rows = (SELECT COUNT(*) FROM ' || tabular_name || ');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''text'' AS component, ''' || info_schema_link_full_md || ''' AS contents_md
              SELECT ''text'' AS component,
                ''- Start Row: '' || $offset || ''
'' ||
                ''- Rows per Page: '' || $limit || ''
'' ||
                ''- Total Rows: '' || $total_rows || ''
'' ||
                ''- Current Page: '' || $current_page || ''
'' ||
                ''- Total Pages: '' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''table'' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM ' || tabular_name || '
            LIMIT $limit
            OFFSET $offset;

            SELECT ''text'' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
                ''(Page '' || $current_page || '' of '' || $total_pages || '') '' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
                AS contents_md;'
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.sql',
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;
' ||
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows
-- delete all /fhir-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like 'ur%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'ur/index.sql', 'ur/index.sql', 'Uniform Resource', NULL, NULL, 'Explore ingested resources', NULL),
    ('prime', 'ur/index.sql', 99, 'ur/info-schema.sql', 'ur/info-schema.sql', 'Uniform Resource Tables and Views', NULL, NULL, 'Information Schema documentation for ingested Uniform Resource database objects', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-files.sql', 'ur/uniform-resource-files.sql', 'Uniform Resources (Files)', NULL, NULL, 'Files ingested into the `uniform_resource` table', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-imap-account.sql', 'ur/uniform-resource-imap-account.sql', 'Uniform Resources (IMAP)', NULL, NULL, 'Easily access and view your emails with our Uniform Resource (IMAP) system. Ingested from various mail sources, this feature organizes and displays your messages directly in the Web UI, ensuring all your communications are available in one convenient place.', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
DROP VIEW IF EXISTS uniform_resource_file;
CREATE VIEW uniform_resource_file AS
  SELECT ur.uniform_resource_id,
         ur.nature,
         p.root_path AS source_path,
         pe.file_path_rel,
         ur.size_bytes
  FROM uniform_resource ur
  LEFT JOIN uniform_resource_edge ure ON ur.uniform_resource_id = ure.uniform_resource_id AND ure.nature = 'ingest_fs_path'
  LEFT JOIN ur_ingest_session_fs_path p ON ure.node_id = p.ur_ingest_session_fs_path_id
  LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id;

  DROP VIEW IF EXISTS uniform_resource_imap;
  CREATE VIEW uniform_resource_imap AS
  SELECT
      ur.uniform_resource_id,
      graph.name,
      iac.ur_ingest_session_imap_account_id,
      iac.email,
      iac.host,
      iacm.subject,
      iacm."from",
      iacm.message,
      iacm.date,
      iaf.ur_ingest_session_imap_acct_folder_id,
      iaf.ingest_account_id,
      iaf.folder_name,
      ur.size_bytes,
      ur.nature,
      ur.content
  FROM uniform_resource ur
  INNER JOIN uniform_resource_edge edge ON edge.uniform_resource_id=ur.uniform_resource_id
  INNER JOIN uniform_resource_graph graph ON graph.name=edge.graph_name
  INNER JOIN ur_ingest_session_imap_acct_folder_message iacm ON iacm.ur_ingest_session_imap_acct_folder_message_id = edge.node_id
  INNER JOIN ur_ingest_session_imap_acct_folder iaf ON iacm.ingest_imap_acct_folder_id = iaf.ur_ingest_session_imap_acct_folder_id
  LEFT JOIN ur_ingest_session_imap_account iac ON iac.ur_ingest_session_imap_account_id = iaf.ingest_account_id
  WHERE ur.nature = 'text' AND graph.name='imap' AND ur.ingest_session_imap_acct_folder_message IS NOT NULL;

  DROP VIEW IF EXISTS uniform_resource_imap_content;
  CREATE  VIEW uniform_resource_imap_content AS
  SELECT
      uri.uniform_resource_id,
      base_ur.uniform_resource_id baseID,
      ext_ur.uniform_resource_id extID,
      base_ur.uri as base_uri,
      ext_ur.uri as ext_uri,
      base_ur.nature as base_nature,
      ext_ur.nature as ext_nature,
      json_extract(part.value, '$.body.Html') AS html_content
  FROM
      uniform_resource_imap uri
  INNER JOIN uniform_resource base_ur ON base_ur.uniform_resource_id=uri.uniform_resource_id
  INNER JOIN uniform_resource ext_ur ON ext_ur.uri = base_ur.uri ||'/json' AND ext_ur.nature = 'json',
  json_each(ext_ur.content, '$.parts') AS part
  WHERE ext_ur.nature = 'json' AND html_content NOT NULL;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats" AS
    WITH Summary AS (
        SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_fs_path_entry.file_extn, '') AS file_extension,
            ur_ingest_session_fs_path.ur_ingest_session_fs_path_id as ingest_session_fs_path_id,
            ur_ingest_session_fs_path.root_path AS ingest_session_root_fs_path,
            COUNT(ur_ingest_session_fs_path_entry.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_fs_path ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_fs_path.ingest_session_id
        LEFT JOIN
            ur_ingest_session_fs_path_entry ON ur_ingest_session_fs_path.ur_ingest_session_fs_path_id = ur_ingest_session_fs_path_entry.ingest_fs_path_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_fs_path_entry.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_fs_path_entry.file_extn,
            ur_ingest_session_fs_path.root_path
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        file_extension,
        ingest_session_fs_path_id,
        ingest_session_root_fs_path,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        file_extension;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_files_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats" AS
      WITH Summary AS (
          SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_task.ur_status, 'Ok') AS ur_status,
            COALESCE(uniform_resource.nature, 'UNKNOWN') AS nature,
            COUNT(ur_ingest_session_task.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_task ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_task.ingest_session_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_task.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_task.captured_executable
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        ur_status,
        nature,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        ur_status;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_tasks_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_file_issue";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_file_issue" AS
      SELECT us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics
        FROM ur_ingest_session_fs_path_entry ufs
        JOIN ur_ingest_session_fs_path usp ON ufs.ingest_fs_path_id = usp.ur_ingest_session_fs_path_id
        JOIN ur_ingest_session us ON usp.ingest_session_id = us.ur_ingest_session_id
       WHERE ufs.ur_status IS NOT NULL
    GROUP BY us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics;
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'orchestration/index.sql', 'orchestration/index.sql', 'Orchestration', NULL, NULL, 'Explore details about all orchestration', NULL),
    ('prime', 'orchestration/index.sql', 99, 'orchestration/info-schema.sql', 'orchestration/info-schema.sql', 'Orchestration Tables and Views', NULL, NULL, 'Information Schema documentation for orchestrated objects', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
 DROP VIEW IF EXISTS orchestration_session_by_device;
 CREATE VIEW orchestration_session_by_device AS
 SELECT
     d.device_id,
     d.name AS device_name,
     COUNT(*) AS session_count
 FROM orchestration_session os
 JOIN device d ON os.device_id = d.device_id
 GROUP BY d.device_id, d.name;

 DROP VIEW IF EXISTS orchestration_session_duration;
 CREATE VIEW orchestration_session_duration AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     os.orch_started_at,
     os.orch_finished_at,
     (JULIANDAY(os.orch_finished_at) - JULIANDAY(os.orch_started_at)) * 24 * 60 * 60 AS duration_seconds
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 WHERE os.orch_finished_at IS NOT NULL;

 DROP VIEW IF EXISTS orchestration_success_rate;
 CREATE VIEW orchestration_success_rate AS
 SELECT
     onature.nature AS orchestration_nature,
     COUNT(*) AS total_sessions,
     SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS successful_sessions,
     (CAST(SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_state oss ON os.orchestration_session_id = oss.session_id
 WHERE oss.to_state IN ('surveilr_orch_completed', 'surveilr_orch_failed') -- Consider other terminal states if applicable
 GROUP BY onature.nature;

 DROP VIEW IF EXISTS orchestration_session_script;
 CREATE VIEW orchestration_session_script AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     COUNT(*) AS script_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_entry ose ON os.orchestration_session_id = ose.session_id
 GROUP BY os.orchestration_session_id, onature.nature;

 DROP VIEW IF EXISTS orchestration_executions_by_type;
 CREATE VIEW orchestration_executions_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS execution_count
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_execution_success_rate_by_type;
 CREATE VIEW orchestration_execution_success_rate_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS total_executions,
     SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS successful_executions,
     (CAST(SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_session_summary;
 CREATE VIEW orchestration_session_summary AS
 SELECT
     issue_type,
     COUNT(*) AS issue_count
 FROM orchestration_session_issue
 GROUP BY issue_type;

 DROP VIEW IF EXISTS orchestration_issue_remediation;
 CREATE VIEW orchestration_issue_remediation AS
 SELECT
     orchestration_session_issue_id,
     issue_type,
     issue_message,
     remediation
 FROM orchestration_session_issue
 WHERE remediation IS NOT NULL;

DROP VIEW IF EXISTS orchestration_logs_by_session;
 CREATE VIEW orchestration_logs_by_session AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     osl.category,
     COUNT(*) AS log_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_exec ose ON os.orchestration_session_id = ose.session_id
 JOIN orchestration_session_log osl ON ose.orchestration_session_exec_id = osl.parent_exec_id
 GROUP BY os.orchestration_session_id, onature.nature, osl.category;
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'docs/index.sql', 'docs/index.sql', 'Docs', NULL, NULL, 'Explore surveilr functions and release notes', NULL),
    ('prime', 'docs/index.sql', 99, 'docs/release-notes.sql', 'docs/release-notes.sql', 'Release Notes', NULL, NULL, 'surveilr releases details', NULL),
    ('prime', 'docs/index.sql', 2, 'docs/functions.sql', 'docs/functions.sql', 'SQL Functions', NULL, NULL, 'surveilr specific SQLite functions for extensibilty', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "shell",
  "title": "Resource Surveillance State Database (RSSD)",
  "icon": "",
  "favicon": "https://www.surveilr.com/assets/brand/favicon.ico",
  "image": "https://www.surveilr.com/assets/brand/surveilr-icon.png",
  "layout": "fluid",
  "fixed_top_menu": true,
  "link": "index.sql",
  "menu_item": [
    {
      "link": "index.sql",
      "title": "Home"
    }
  ],
  "javascript": [
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js"
  ],
  "footer": "Resource Surveillance Web UI"
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT ''shell'' AS component,
       ''Resource Surveillance State Database (RSSD)'' AS title,
       NULL AS icon,
       ''https://www.surveilr.com/assets/brand/favicon.ico'' AS favicon,
       ''https://www.surveilr.com/assets/brand/surveilr-icon.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''index.sql'' AS link,
       ''{"link":"index.sql","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''/docs/index.sql'',
              ''title'', ''Docs'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/docs/index.sql/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''ur'',
              ''title'', ''Uniform Resource'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''ur/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''console'',
              ''title'', ''Console'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''console/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''orchestration'',
              ''title'', ''Orchestration'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''orchestration/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       ''Surveilr ''|| (SELECT json_extract(session_agent, ''$.version'') AS version FROM ur_ingest_session LIMIT 1) || '' Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), LENGTH(sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'')) + 2 ) || '')'' as footer;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''list'' AS component;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH console_navigation_cte AS (
    SELECT title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''console''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM console_navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''console''||''/index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Tables'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || table_name || ''](table.sql?name='' || table_name || '')'' AS "Table",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
FROM console_information_schema_table
GROUP BY table_name;

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || view_name || ''](view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
FROM console_information_schema_view
GROUP BY view_name;

SELECT ''title'' AS component, ''Migrations'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT from_state, to_state, transition_reason, transitioned_at
FROM code_notebook_state
ORDER BY transitioned_at;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/table.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' Table'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type",
    is_primary_key AS "PK",
    is_not_null AS "Required",
    default_value AS "Default"
FROM console_information_schema_table
WHERE table_name = $name;

SELECT ''title'' AS component, ''Foreign Keys'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    foreign_key AS "Foreign Key"
FROM console_information_schema_table_col_fkey
WHERE table_name = $name;

SELECT ''title'' AS component, ''Indexes'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    index_name AS "Index Name"
FROM console_information_schema_table_col_index
WHERE table_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_table WHERE table_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/view.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' View'' AS title, ''#'' AS link;

SELECT ''title'' AS component,
$name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type"
FROM console_information_schema_view
WHERE view_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_view WHERE view_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage pages in sqlpage_files table'' AS contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
   SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
   LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/sqlpage-file.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $path || '' Path'' AS title, ''#'' AS link;

      SELECT ''title'' AS component, $path AS contents;
      SELECT ''text'' AS component,
             ''```sql
'' || (select contents FROM sqlpage_files where path = $path) || ''
```'' as contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/content.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/content.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage pages generated from tables and views'' AS contents;
SELECT ''text'' AS component, ''
  - `*.auto.sql` pages are auto-generated "default" content pages for each table and view defined in the database.
  - The `*.sql` companions may be auto-generated redirects to their `*.auto.sql` pair or an app/service might override the `*.sql` to not redirect and supply custom content for any table or view.
  - [View regenerate-auto.sql]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path=console/content/action/regenerate-auto.sql'' || '')
  '' AS contents_md;

SELECT ''button'' AS component, ''center'' AS justify;
SELECT sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/action/regenerate-auto.sql'' AS link, ''info'' AS color, ''Regenerate all "default" table/view content pages'' AS title;

SELECT ''title'' AS component, ''Redirected or overriden content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
      SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '')[📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",

  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%''
      AND NOT(path like ''console/content/%.auto.sql'')
      AND NOT(path like ''console/content/action%'')
ORDER BY path;

SELECT ''title'' AS component, ''Auto-generated "default" content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
    SELECT
      ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",

  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%.auto.sql''
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/content/action/regenerate-auto.sql',
      '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows

-- code provenance: `ConsoleSqlPages.console/content/action/regenerate-auto.sql` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/content.sql'' as link WHERE $redirect is NULL;
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || $redirect as link WHERE $redirect is NOT NULL;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-nav/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-nav/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage navigation in sqlpage_aide_navigation table'' AS contents;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT path, caption, description FROM sqlpage_aide_navigation ORDER BY namespace, parent_path, path, sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Code Notebooks'' AS contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT c.notebook_name,
    ''['' || c.cell_name || '']('' ||
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' ||
    replace(c.notebook_name, '' '', ''%20'') ||
    ''&cell='' ||
    replace(c.cell_name, '' '', ''%20'') ||
    '')'' AS "Cell",
     c.description,
       k.kernel_name as kernel
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/migrations/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
    ''foldable'' as component;
SELECT
    ''RSSD Lifecycle(Migration) Documentation'' as title,
    ''
This document provides an organized and comprehensive overview of ``surveilr``''''s RSSD migration process starting from ``v 1.0.0``, breaking down each component and the steps followed to ensure smooth and efficient migrations. It covers the creation of key tables and views, the handling of migration cells, and the sequence for executing migration scripts.

---

## Session and State Initialization

To manage temporary session data and track user state, we use the ``session_state_ephemeral`` table, which stores essential session information like the current user. This table is temporary, meaning it only persists data for the duration of the session, and it''''s especially useful for identifying the user responsible for specific actions during the migration.

Each time the migration process runs, we initialize session data in this table, ensuring all necessary information is available without affecting the core database tables. This initialization prepares the system for more advanced operations that rely on knowing the user executing each action.

---

## Assurance Schema Table

The ``assurance_schema`` table is designed to store various schema-related details, including the type of schema assurance, associated codes, and related governance data. This table is central to defining the structure of assurance records, which are useful for validating data, tracking governance requirements, and recording creation timestamps. All updates to the schema are logged to track when they were last modified and by whom.

---

## Code Notebook Kernel, Cell, and State Tables

``surveilr`` uses a structured system of code notebooks to store and execute SQL commands. These commands, or “cells,” are grouped into notebooks, and each notebook is associated with a kernel, which provides metadata about the notebook''''s language and structure. The main tables involved here are:

- **``code_notebook_kernel``**: Stores information about different kernels, each representing a unique execution environment or language.
- **``code_notebook_cell``**: Holds individual code cells within each notebook, along with their associated metadata and execution history.
- **``code_notebook_state``**: Tracks each cell''''s state changes, such as when it was last executed and any errors encountered.

By organizing migration scripts into cells and notebooks, ``surveilr`` can maintain detailed control over execution order and track the state of each cell individually. This tracking is essential for handling updates, as it allows us to execute migrations only when necessary.

---

## Views for Managing Cell Versions and Migrations

Several views are defined to simplify and organize the migration process by managing different versions of code cells and identifying migration candidates. These views help filter, sort, and retrieve the cells that need execution.

### Key Views

- **``code_notebook_cell_versions``**: Lists all available versions of each cell, allowing the migration tool to retrieve older versions if needed for rollback or auditing.
- **``code_notebook_cell_latest``**: Shows only the latest version of each cell, simplifying the migration by focusing on the most recent updates.
- **``code_notebook_sql_cell_migratable``**: Filters cells to include only those that are eligible for migration, ensuring that non-executable cells are ignored.

---

## Migration-Oriented Views and Dynamic Migration Scripts

To streamline the migration process, several migration-oriented views organize the data by listing cells that require execution or are ready for re-execution. By grouping these cells in specific views, ``surveilr`` dynamically generates a script that executes only the necessary cells.

### Key Views

- **``code_notebook_sql_cell_migratable_not_executed``**: Lists migratable cells that haven’t yet been executed.
- **``code_notebook_sql_cell_migratable_state``**: Shows the latest migratable cells, along with their current state transitions.

---

## How Migrations Are Executed

When it''''s time to apply changes to the database, this section explains the process in detail, focusing on how ``surveilr`` prepares the environment, identifies which cells to migrate, executes the appropriate SQL code, and ensures data integrity throughout.

---

### 1. Initialization

The first step in the migration process involves setting up the essential database tables and seeding initial values. This lays the foundation for the migration process, making sure that all tables, views, and temporary values needed are in place.

- **Check for Core Tables**: ``surveilr`` first verifies whether the required tables, such as ``code_notebook_cell``, ``code_notebook_state``, and others starting with ``code_notebook%``, are already set up in the database.
- **Setup**: If these tables do not yet exist, ``surveilr`` automatically initiates the setup by running the initial SQL script, known as ``bootstrap.sql``. This script contains SQL commands that create all the essential tables and views discussed in previous sections.
- **Seeding**: During the execution of ``bootstrap.sql``, essential data, such as temporary values in the ``session_state_ephemeral`` table (e.g., information about the current user), is also added to ensure that the migration session has the data it needs to proceed smoothly.

---

### 2. Migration Preparation and Identification of Cells to Execute

Once the environment is ready, ``surveilr`` examines which specific cells (code blocks in the migration notebook) need to be executed to bring the database up to the latest version.

- **Listing Eligible Cells**: ``surveilr`` begins by consulting views such as ``code_notebook_sql_cell_migratable_not_executed``. This view is a pre-filtered list of cells that are eligible for migration but haven’t yet been executed.
- **Idempotent vs. Non-Idempotent Cells**: ``surveilr`` then checks whether each cell is marked as “idempotent” or “non-idempotent.”
   - **Idempotent Cells** can be executed multiple times without adverse effects. If they have been run before, they can safely be run again without impacting data integrity.
   - **Non-Idempotent Cells**, identified by names containing ``_once_``, should only be executed once. If these cells have been executed previously, they are skipped in the migration process to prevent unintentional re-runs.

---

### 3. Dynamic Script Generation and Execution

``surveilr`` then assembles a custom SQL script that includes only the cells identified as eligible for execution. This script is crafted carefully to ensure each cell''''s SQL code is executed in the correct order and with the right contextual information.

- **Script Creation**: We start by generating a dynamic script in a single transaction block. Transactions are a way of grouping a series of commands so that they are either all applied or none are, which protects data integrity.
- **Inclusion of Cells Based on Eligibility**:
   - For each cell, ``surveilr`` checks its eligibility status. If it''''s non-idempotent and already executed, it''''s marked with a comment noting that it''''s excluded from the script due to previous execution.
   - If the cell is idempotent or eligible for re-execution, its SQL code is added to the script, along with additional details such as comments about the cell''''s last execution date.
- **State Transition Records**: After each cell''''s SQL code, additional commands are added to record the cell''''s transition state. This step inserts information into ``code_notebook_state``, logging details such as the cell ID, transition state (from “Pending” to “Executed”), and the reason for the transition (“Migration” or “Reapplication”). These logs are invaluable for auditing purposes.

---

### 4. Execution in a Transactional Block

With the script prepared, ``surveilr`` then executes the entire batch of SQL commands within a transactional block.

- **BEGIN TRANSACTION**: The script begins with a transaction, ensuring that all changes are applied as a single, atomic unit.
- **Running Cell Code**: Within this transaction, each cell''''s SQL code is executed in the order it appears in the script.
- **Error Handling**: If any step in the transaction fails, all changes are rolled back. This prevents partial updates from occurring, ensuring that the database remains in a consistent state.
- **COMMIT**: If the script executes successfully without errors, the transaction is committed, finalizing the changes. The ``COMMIT`` command signifies the end of the migration session, making all updates permanent.

---

### 5. Finalizing Migration and Recording Results

After a successful migration session, ``surveilr`` concludes by recording details about the migration process.

- **Final Updates to ``code_notebook_state``**: Any cells marked as “Executed” are updated in ``code_notebook_state`` with the latest timestamp, indicating their successful migration.
- **Logging Completion**: Activity logs are updated with relevant details, ensuring a clear record of the migration.
- **Cleanup of Temporary Data**: Finally, temporary data is cleared, such as entries in ``session_state_ephemeral``, since these values were only needed during the migration process.
    '' as description_md;


SELECT ''title'' AS component, ''Pending Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_not_executed lists all cells eligible for migration but not yet executed.
    If migrations have been completed successfully, this list will be empty,
    indicating that all migratable cells have been processed and marked as executed.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp
FROM
    code_notebook_sql_cell_migratable_not_executed AS c
ORDER BY
    c.cell_name;

-- State of Executed Migrations
SELECT ''title'' AS component, ''State of Executed Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_state displays all cells that have been successfully executed as part of the migration process,
    showing the latest version of each migratable cell.
    For each cell, it provides details on its transition states,
    the reason and result of the migration, and the timestamp of when the migration occurred.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp,
    c.from_state,
    c.to_state,
    c.transition_reason,
    c.transition_result,
    c.transitioned_at
FROM
    code_notebook_sql_cell_migratable_state AS c
ORDER BY
    c.cell_name;


-- Executable Migrations
SELECT ''title'' AS component, ''Executable Migrations'' AS contents;
SELECT ''text'' AS component, ''All cells that are candidates for migration (including duplicates)'' as contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
        c.code_notebook_cell_id,
        c.notebook_name,
        c.cell_name,
        ''['' || c.cell_name || ''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' || replace(c.notebook_name, '' '', ''%20'') || ''&cell='' || replace(c.cell_name, '' '', ''%20'') || '')'' as Cell,
        c.interpretable_code_hash,
        c.is_idempotent,
        c.version_timestamp
    FROM
        code_notebook_sql_cell_migratable_version AS c
    ORDER BY
        c.cell_name;

-- All Migrations
SELECT ''button'' as component;
SELECT
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks'' as link,
    ''See all notebook entries'' as title;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/migrations/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/about.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/about.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                 -- Title Component
    SELECT
    ''text'' AS component,
    (''Resource Surveillance v'' || replace(sqlpage.exec(''surveilr'', ''--version''), ''surveilr '', '''')) AS title;

    -- Description Component
      SELECT
          ''text'' AS component,
          ''A detailed description of what is incorporated into surveilr. It informs of critical dependencies like rusqlite, sqlpage, pgwire, e.t.c, ensuring they are present and meet version requirements. Additionally, it scans for and executes capturable executables in the PATH and evaluates surveilr_doctor_* database views for more insights.''
          AS contents_md;

      -- Section: Dependencies
      SELECT
          ''title'' AS component,
          ''Internal Dependencies'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          "Dependency",
          "Version"
      FROM (
          SELECT
              ''SQLPage'' AS "Dependency",
              json_extract(json_data, ''$.versions.sqlpage'') AS "Version"
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Pgwire'',
              json_extract(json_data, ''$.versions.pgwire'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Rusqlite'',
              json_extract(json_data, ''$.versions.rusqlite'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
      );

      -- Section: Static Extensions
      SELECT
          ''title'' AS component,
          ''Statically Linked Extensions'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          json_extract(value, ''$.name'') AS "Extension Name",
          json_extract(value, ''$.url'') AS "URL",
          json_extract(value, ''$.version'') AS "Version"
      FROM json_each(
          json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.static_extensions'')
      );

    -- Section: Dynamic Extensions
    SELECT
        ''title'' AS component,
        ''Dynamically Linked Extensions'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Extension Name",
        json_extract(value, ''$.path'') AS "Path"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.dynamic_extensions'')
    );

    -- Section: Environment Variables
    SELECT
        ''title'' AS component,
        ''Environment Variables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Variable",
        json_extract(value, ''$.value'') AS "Value"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.env_vars'')
    );

    -- Section: Capturable Executables
    SELECT
        ''title'' AS component,
        ''Capturable Executables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Executable Name",
        json_extract(value, ''$.output'') AS "Output"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.capturable_executables'')
    );

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;

SELECT
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md, ''$SITE_PREFIX_URL'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') AS "Content"
FROM console_information_schema_view
WHERE view_name LIKE ''surveilr_doctor%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/statistics/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/statistics/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''datagrid'' as component;
SELECT ''Size'' as title, "db_size_mb" || '' MB'' as description FROM rssd_statistics_overview;
SELECT ''Tables'' as title, "total_tables" as description FROM rssd_statistics_overview;
SELECT ''Indexes'' as title, "total_indexes" as description FROM rssd_statistics_overview;
SELECT ''Rows'' as title, "total_rows" as description FROM rssd_statistics_overview;
SELECT ''Page Size'' as title, "page_size" as description FROM rssd_statistics_overview;
SELECT ''Total Pages'' as title, "total_pages" as description FROM rssd_statistics_overview;
    
select ''text'' as component, ''Tables'' as title;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT * FROM rssd_table_statistic ORDER BY table_size_mb DESC;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
    SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''ur''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''ur''||''/index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, ''Uniform Resource Tables and Views'' as contents;
  SELECT ''table'' AS component,
  ''Name'' AS markdown,
    ''Column Count'' as align_right,
    TRUE as sort,
    TRUE as search;

SELECT
''Table'' as "Type",
  ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
  FROM console_information_schema_table
  WHERE table_name = ''uniform_resource'' OR table_name like ''ur_%''
  GROUP BY table_name

  UNION ALL

SELECT
''View'' as "Type",
  ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
  FROM console_information_schema_view
  WHERE view_name like ''ur_%''
  GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-files.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-files.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-files.sql/index.sql'') as contents;
    ;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_file );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small;
SELECT * FROM uniform_resource_file ORDER BY uniform_resource_id
   LIMIT $limit
  OFFSET $offset;

  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||     '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||     '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-account.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-imap-account.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-imap-account.sql/index.sql'') as contents;
    ;

select
  ''title''   as component,
  ''Mailbox'' as contents;
-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''email'' AS markdown;
SELECT    
''['' || email || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id || '')'' AS "email"
      FROM uniform_resource_imap
      GROUP BY ur_ingest_session_imap_account_id
      ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-folder.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''breadcrumb'' as component;
SELECT
   ''Home'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
SELECT
  ''Uniform Resource'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' as link;
SELECT
  ''Folder'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || $imap_account_id:: TEXT as link;
SELECT
  ''title'' as component,
  (SELECT email FROM uniform_resource_imap WHERE ur_ingest_session_imap_account_id = $imap_account_id::TEXT) as contents;

--Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''folder'' AS markdown;
  SELECT ''['' || folder_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id || '')'' AS "folder"
    FROM uniform_resource_imap
    WHERE ur_ingest_session_imap_account_id = $imap_account_id:: TEXT
    GROUP BY ur_ingest_session_imap_acct_folder_id
    ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
''breadcrumb'' AS component;
SELECT
''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''
SELECT
  ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
  ''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id=''|| ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id = $folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  ''title''   as component,
  (SELECT email || '' ('' || folder_name || '')''  FROM uniform_resource_imap WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT) as contents;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_imap );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''subject'' AS markdown;;
SELECT
''['' || subject || ''](uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id || '')'' AS "subject"
  , "from",
  CASE
      WHEN ROUND(julianday(''now'') - julianday(date)) = 0 THEN ''Today''
      WHEN ROUND(julianday(''now'') - julianday(date)) = 1 THEN ''1 day ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) BETWEEN 2 AND 6 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) < 30 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) < 365 THEN CAST(ROUND((julianday(''now'') - julianday(date)) / 30) AS INT) || '' months ago''
      ELSE CAST(ROUND((julianday(''now'') - julianday(date)) / 365) AS INT) || '' years ago''
  END AS "Relative Time",
  strftime(''%Y-%m-%d'', substr(date, 1, 19)) as date
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT
  ORDER BY uniform_resource_id
  LIMIT $limit
  OFFSET $offset;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) ||  ''&folder_id='' || $folder_id ||   '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) ||   ''&folder_id='' || $folder_id ||  '')'' ELSE '''' END)
    AS contents_md 
;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
''breadcrumb'' AS component;
SELECT
''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''AS link;
SELECT
 ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' AS link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id=$resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   subject AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Breadcrumb ends-- -

  --- back button-- -
    select ''button'' as component;
select
"<< Back" as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id as link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Display uniform_resource table with pagination
  SELECT
''datagrid'' as component;
SELECT
''From'' as title,
  "from" as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''To'' as title,
  email as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''Subject'' as title,
  subject as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;

  SELECT ''html'' AS component;
  SELECT html_content AS html FROM uniform_resource_imap_content WHERE uniform_resource_id=$resource_id::TEXT ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''orchestration/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''orchestration''||''/index.sql''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path =  ''orchestration''||''/index.sql''
ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''orchestration/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Orchestration Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
     ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''orchestration_session'' OR table_name like ''orchestration_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
     ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''orchestration_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''docs/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''docs''||''/index.sql''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path =  ''docs''||''/index.sql''
ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/release-notes.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''docs/release-notes.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Release Notes for surveilr Versions'' as contents;

                    SELECT ''foldable'' as component;
                    SELECT ''v1.8.0'' as title, ''# `surveilr` v1.8.0 Release Notes

---

## 🚀 What''''s New

### **1. SQLPage**
- Updated SQLPage to the latest version, `v0.34.0`, ensuring compatibility and access to the newest features and bug fixes.

### 2. Introduced `surveilr_notebook_cell_exec`
`surveilr_notebook_cell_exec` is a function designed to execute queries stored in `code_notebook_cell`s against the RSSD. This is the SQLite function equivalent of the `surveilr notebook cat` command which only outputs the content of the `code_notebook_cell`, this function on other hand, executes it. It takes two arguments, the `notebook_name` and the `cell_name` and it returns either `true` or `false` to denote if the execution was succesful.

## Bug Fixes
1. Fixed the SQL query issue when `--persist-raw-logs` is passed to the `surveilr osquery-ms` server.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.25'' as title, ''# `surveilr` v1.7.13 Release Notes

This release aims to improve the `surveilr osquery-ms` server; no new features or bug fixes were added.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.16'' as title, ''# `surveilr` v1.7.16 Release Notes

## Bug Fixes
1. Enhanced the CSV transform functionality to correctly include partyID for each ingested CSV table when provided.

2. Resolved an issue where ingesting multiple CSV files with the same name from different folders resulted in data loss. Now, all files are consolidated into a single table while preserving distinct data sources with the partyID field.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.13'' as title, ''# `surveilr` v1.7.13 Release Notes

This release aims to improve the `surveilr osquery-ms` server; no new features or bug fixes were added.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.12'' as title, ''# `surveilr` v1.7.12 Release Notes

## 🚀 What''''s New

### 1. `surveilr osquery-ms` Server
The server has been fully setup, configured with boundaries and the corresponding WebUI, fully configurable with `code_notebooks`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.11'' as title, ''# `surveilr` v1.7.11 Release Notes

## 🚀 What''''s New

### 1. Upgraded SQLPage
SQLPage has been updated to version 0.33.1, aligning with the latest releases.

## Bug Fixes
### 1. `surveilr admin merge`
- Added recent and new tables to the merge structure ensuring all tables in each RSSD are present in the final merged RSSD.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.10'' as title, ''# `surveilr` v1.7.10 Release Notes

## 🚀 What''''s New

### 1. Enhancing `surveilr`''''s osQuery Management Server
- Added support for boundaries to enable grouping of nodes for better viewing
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.9'' as title, ''# `surveilr` v1.7.9 Release Notes

## 🚀 What''''s New

### 1. Enhancing `surveilr`''''s osQuery Management Server
- Introduced a new flag `--keep-status-logs` to indicate whether the server should store status logs received from osQuery in the RSSD.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.8'' as title, ''# `surveilr` v1.7.8 Release Notes

This release focuses on enhancing the `surveilr osquery-ms` UI by adding new tables and optimizing data management. No bugs were fixed or new features introduced. Please review the Web UI for updates.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.7'' as title, ''# `surveilr` v1.7.7 Release Notes

This release aims to improve the `surveilr osquery-ms` server; no new features or bug fixes were added.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.6'' as title, ''# `surveilr` v1.7.6 Release Notes

---

## 🚀 Bug Fixes

### 1. `surveilr` Bootstrap SQL
This release fixes the "no such table: device" error introduced in the previous version by propagating any erroors during the SQL initialization of the RSSD with `surveilr`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.5'' as title, ''# `surveilr` v1.7.5 Release Notes

---


### 🆕 **New Features**
- **osQuery Management Server Integration**:  
  - `surveilr` now acts as a management layer for osQuery, enabling secure and efficient monitoring of infrastructure.
  - Supports remote configuration, logging, and query execution for osQuery nodes.

- **Behavior & Notebooks Support**:  
  - Introduced **Notebooks**, which store predefined queries in the `code_notebook_cell` table.
  - **Behaviors** allow defining and managing query execution for different node groups.

- **Secure Node Enrollment**:  
  - Nodes authenticate using an **enrollment secret key** (`SURVEILR_OSQUERY_MS_ENROLL_SECRET`).
  - Secure communication via **TLS certificates** (`cert.pem`, `key.pem`).

- **Automated Query Execution**:  
  - Default queries from **"osQuery Management Server (Prime)"** execute automatically.
  - Custom notebooks and queries can be added dynamically via SQL.

- **Centralized Logging & Config Fetching**:  
  - Osquery logs and configurations are fetched via TLS endpoints (`/logger`, `/config`).
  - All communication is secured using **server-side TLS certificates**.

- **Web UI for Query Results Visualization**:  
  - `surveilr web-ui` provides an intuitive dashboard to inspect query results across enrolled nodes.
  - Simply start with `surveilr web-ui -p 3050 --host <server-ip>`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.1'' as title, ''# `surveilr` v1.7.1 Release Notes

---

## 🚀 What''''s New

### 1. Enhancing `surveilr`''''s osQuery Management Server
- Introduced a new flag--behavior` or `-b` to specify behavior name to queries to run automatically enrolled nodes.
- a new SQLite function called `surveilr_osquery_ms_create_behaviour` to facilitate the creation of behaviors, making process smooth and easy.

### Example
When starting the `surveilr osquery-ms` server without passing a behavior, a default behavior with the following query configuration is created:
```json
{
  "surveilr-cli": {
    ...
    "osquery_ms": {
      "tls_proc": {
 "query": "select * from processes",
        "interval": 60
      }
    }
  }
}
```
To use a behavior with the `surveilr` osQuery management server first create a behavior using the new function: 
```bash
surveilr shell --cmd "select surveil_osquery_ms_create_behaviour(''''-behaviour'''', ''''{\"tls_proc\": {\"query\": \"select * from processes\", \"interval\": 60}, \"routes\": {\"query\": \"SELECT * FROM routes WHERE destination = ''''''''::1''''''''\", \"interval\": 60}}'''');"
```
Then, pass that behavior to the server by:

```bash
surveilr osquery-ms --cert ./cert.pem --key ./key.pem --enroll-secret "<secret>" -b "initial-behaviour"
```'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.7.0'' as title, ''# `surveilr` v1.7.0 Release Notes

---

## 🚀 What''''s New

### **1. `surveilr` OSQuery Management Server**
Introducing Osquery Management Server using `surveilr`, enabling secure and centralized monitoring of your infrastructure. The setup ensures secure node enrollment through TLS authentication and secret keys, allowing only authorized devices to connect. Users can easily configure and manage node behaviors dynamically via `surveilr`’s behavior tables.

### **2. OpenDAL Dropbox Integration**
The `surveilr_udi_dal_dropbox` SQLite function, is a powerful new virtual table module that enables seamless interaction with Dropbox files directly within your SQL queries. This module allows users to access and query comprehensive file metadata, including name, path, size, last modified timestamp, content, and more, within specified directories.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.6.0'' as title, ''# `surveilr` v1.6.0 Release Notes

---

## 🚀 What''''s New

### **1. SQLPage**
- Updated SQLPage to the latest version, ensuring compatibility and access to the newest features and bug fixes.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.11'' as title, ''# `surveilr` v1.5.11 Release Notes

---

### Overview
This release includes updates to dependencies, bug fixes, and performance improvements to enhance stability and functionality.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.10'' as title, ''# `surveilr` v1.5.9 Release Notes

---

## 🚀 Bug Fixes

### **1. WebUI Page for About**
- A dedicated About page has been added in the WebUI to visualize the response of `surveilr doctor`:
  - **Dependencies Table**:
    - The display of versions and their generation process has been fixed.
  - **Diagnostic Views**:
    - A new section has been added to display the contents and details of all views prefixed with `surveilr_doctor*`, facilitating the of details and logs for diagnostics.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.8'' as title, ''# `surveilr` v1.5.8 Release Notes 🎉

---

### **1. WebUI Page for About**
- Added a dedicated About page in the WebUI visiualizing the response of `surveilr doctor`:
  - **Dependencies Table**:
    - Displays the versions of `sqlpage`, `rusqlite`, and `pgwire` in a table.
  - **Extensions List**:
    - Lists all synamic and static extensions .
  - **Capturable executables**:
    - Lists all capturable executables that were found in the `PATH`.
  - **Env variables**
    - Captures all environment variables starting with `SURVEILR_` and `SQLPAGE_`.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.6'' as title, ''# `surveilr` v1.5.6 Release Notes 🎉

---

## 🚀 What''''s New
### **1. Enhanced Diagnostics Command**
- **`surveilr doctor` Command Improvements**:
  - **Dependencies Check**:
    - Verifies versions of critical dependencies: `Deno`, `Rustc`, and `SQLite`.
    - Ensures dependencies meet minimum version requirements for seamless functionality.
  - **Capturable Executables Detection**:
    - Searches for executables in the `PATH` matching `surveilr-doctor*.*`.
    - Executes these executables, assuming their output is in JSON format, and integrates their results into the diagnostics report.
  - **Database Views Analysis**:
    - Queries all views starting with the prefix `surveilr_doctor_` in the specified RSSD.
    - Displays their contents in tabular format for comprehensive insights.

---

### **2. JSON Mode**
- Added a `--json` flag to the `surveilr doctor` command.
  - Outputs the entire diagnostics report, including versions, extensions, and database views, in structured JSON format.

---

### **3. WebUI Page for Diagnostics**
- Added a dedicated page in the WebUI for the `surveilr doctor` diagnostics:
  - **Versions Table**:
    - Displays the versions of `Deno`, `Rustc`, and `SQLite` in a table.
  - **Extensions List**:
    - Lists all detected extensions.
  - **Database Views Content**:
    - Automatically identifies and displays the contents of views starting with `surveilr_doctor_` in individual tables.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.5'' as title, ''# `surveilr` v1.5.5 Release Notes 🎉

---

## 🚀 What''''s New

### Virtual Table: `surveilr_function_docs`

**Description**  
The `surveilr_function_docs` virtual table offers a structured method to query metadata about `surveilr` SQLite functions registered in the system.

**Columns**  
- `name` (`TEXT`): The function''''s name.
- `description` (`TEXT`): A concise description of the function''''s purpose.
- `parameters` (`JSON`): A JSON object detailing the function''''s parameters, including:
  - `name`: The name of the parameter.
  - `data_type`: The parameter''''s expected data type.
  - `description`: An explanation of the parameter''''s role.
- `return_type` (`TEXT`): The function''''s return type.
- `introduced_in_version` (`TEXT`): The version in which the function was first introduced.

**Use Cases**  
- Utilized in the Web UI for generating documentation on the functions.

---

### Virtual Table: `surveilr_udi_dal_fs`

**Description**  
The `surveilr_udi_dal_fs` virtual table acts as an abstraction layer for interacting with the file system. It enables users to list and examine file metadata in a structured, SQL-friendly manner. This table can list files and their metadata recursively from a specified path.

**Columns**  
- `name` (`TEXT`): The file''''s name.
- `path` (`TEXT`): The complete file path.
- `last_modified` (`TEXT`): The file''''s last modified timestamp, when available.
- `content` (`BLOB`): The content of the file (optional).
- `size` (`INTEGER`): The size of the file in bytes.
- `content_type` (`TEXT`): The MIME type of the file or an inferred content type (e.g., based on the extension).
- `digest` (`TEXT`): The MD5 digest of the file, if available.
- `arg_path` (`TEXT`, hidden): The base path for querying files, specified in the `filter` method.

**Key Features**  
- Lists files recursively from a specified directory.
- Facilitates metadata extraction, such as file size, last modified timestamp, and MDhash).

---

### Virtual Table: `surveilr_udi_dal_s3`

**Description**  
The `surveilr_udi_dal_s3` virtual table is an abstraction layer that interacts with the S3 bucket in a given region. It allows listing and inspecting file metadata in a structured, SQL-accessible way.

**Columns**  
- `name` (`TEXT`): The name of the file.
- `path` (`TEXT`): The full path to the file.
- `last_modified` (`TEXT`): The last modified timestamp of the file, if available.
- `content` (`BLOB`): The file''''s content (optional).
- `size` (`INTEGER`): The file size in bytes.
- `content_type` (`TEXT`): The file''''s MIME type or inferred content type (e.g., based on the extension).
- `digest` (`TEXT`): The file''''s MD5 digest, if available.
- `arg_path` (`TEXT`, hidden): The base path to query files from, specified in the `filter` method.

**Key Features**  
- Supports metadata extraction (e.g., file size, last modified timestamp, MD5 hash).

---

## Example Queries

### Querying Function Documentation
```sql
SELECT * FROM surveilr_function_docs WHERE introduced_in_version = ''''1.0.0'''';
```'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.3'' as title, ''# `surveilr` v1.5.3 Release Notes 🎉

---

## 🚀 What''''s New

### 1. **Open Project Data Extension**
`surveilr` now includes additional data from Open Project PLM ingestion. Details such as a work package''''s versions and relations are now encapsulated in JSON format in a new `elaboration` column within the `ur_ingest_session_plm_acct_project_issue` table. The JSON structure is as follows, with the possibility for extension:
```json
elaboration: {"issue_id": 78829, "relations": [...], "version": {...}}
```

### 2. **Functions for Extension Verification**
Two new functions have been introduced to verify and ensure the presence of certain intended functions and extensions before their use:
- The `select surveilr_ensure_function(''''func'''', ''''if not found msg'''', ''''func2'''', ''''if func2 not found msg'''')` function can be used to declaratively specify the required function(s), and will produce an error with guidance on how to obtain the function if it is not found.

- The `select surveilr_ensure_extension(''''extn.so'''', ''''../bin/extn2.so'''')` function allows for the declarative indication of necessary extensions, and will dynamically load them if they are not already available.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.5.2'' as title, ''# `surveilr` v1.5.2 Release Notes 🎉

---

## 🚀 What''''s New

### 1. **`surveilr` SQLite Extensions**
`surveilr` extensions are now statically linked, resolving all extensions and function usage issues. The following extensions are included by default in `surveilr`, with additional ones planned for future releases:
- [`sqlean`](https://github.com/nalgeon/sqlean)
- [`sqlite-url`](https://github.com/asg017/sqlite-url)
- [`sqlite-hashes`](https://github.com/nyurik/sqlite-hashes)
- [`sqlite-lines`](https://github.com/asg017/sqlite-lines)'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.4.3'' as title, ''# `surveilr` v1.4.2 Release Notes 🎉

---

## 🚀 What''''s New

### 1. Utilizing Custom Extensions with `surveilr`
In the previous release, we introduced the feature of automatically loading extensions from the default `sqlpkg` location. However, this posed a security risk, and we have since disabled that feature. To use extensions installed by `sqlpkg`, simply pass `--sqlpkg`, and the default location will be utilized. If you wish to change the directory from which extensions are loaded, use `--sqlpkg /path/to/extensions`, or specify the directory with the new `SURVEILR_SQLPKG` environment variable.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.4.2'' as title, ''# `surveilr` v1.4.2 Release Notes 🎉

---

## 🚀 What''''s New

### 1. Utilizing Custom Extensions with **`surveilr`**
Loading extensions is now straightforward with the `--sqlite-dyn-extn` flag. As long as your extensions are installed via [`sqlpkg`](https://sqlpkg.org/), `surveilr` will automatically detect the default location of `sqlpkg` and all installed extensions. Simply install the extension using `sqlpkg`. To specify a custom path for `sqlpkg`, use the `--sql-pkg-home` argument with a directory containing the extensions, regardless of depth, and `surveilr` will locate them. Additionally, the `SURVEILR_SQLITE_DYN_EXTNS` environment variable has been introduced to designate an extension path instead of using `--sqlite-dyn-extn`.
**Note**: Using `--sqlite-dyn-extn` won''''t prevent `surveilr` from loading extensions from `sqlpkg`''''s default directory. To disable loading from `sqlpkg`, use the `--no-sqlpkg` flag.

Here''''s a detailed example of using `surveilr shell` and `surveilr orchestrate` with dynamic extensions.
**Using `sqlpkg` defaults**
- Download the [`sqlpkg` CLI](https://github.com/nalgeon/sqlpkg-cli?tab=readme-ov-file#download-and-install-preferred-method).
- Download the [text extension](https://sqlpkg.org/?q=text), which offers various text manipulation functions: `sqlpkg install nalgeon/sqlean`
- Run the following command:
  ```bash
  surveilr shell --cmd "select text_substring(''''hello world'''', 7, 5) AS result" # surveilr loads all extensions from the .sqlpkg default directory
  ```

**Including an additional extension with `sqlpkg`**
Combine `--sqlite-dyn-extn` with `surveilr`''''s ability to load extensions from `sqlpkg`
- Add the `path` extension to `sqlpkg`''''s installed extensions: `sqlpkg install asg017/path`
- Execute:
  ```bash
  surveilr shell --cmd "SELECT
        text_substring(''''hello world'''', 7, 5) AS substring_result,
        math_sqrt(9) AS sqrt_result,
        path_parts.type,
        path_parts.part 
    FROM 
        (SELECT * FROM path_parts(''''/usr/bin/sqlite3'''')) AS path_parts;
    " --sqlite-dyn-extn .extensions/math.so
  ```

**Specify a Custom Directory to Load Extensions From**
A `--sqlpkg-home` flag has been introduced to specify a custom path for extensions. They do not need to be installed by `sqlpkg` to be used. `surveilr` will navigate the specified folder and load all compatible extensions for the operating system—`.so` for Linux, `.dll` for Windows, and `.dylib` for macOS. (If you installed with `sqlpkg`, you don''''t need to know the file type).
```bash
surveilr shell --cmd "SELECT text_substring(''''hello world'''', 7, 5) AS substring_result, math_sqrt(9) AS sqrt_result" --sqlpkg-home ./src/resource_serde/src/functions/extensions/
```

### 2. Upgraded SQLPage
SQLPage has been updated to version 0.31.0, aligning with the latest releases.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.4.1'' as title, ''# `surveilr` v1.4.1 Release Notes 🎉

---

## 🚀 Bug Fixes

### 1. **`surveilr` SQLite Extensions**
To temporarily mitigate the issue with `surveilr` intermittently working due to the dynamic loading of extensions, `surveilr` no longer supports dynamic loading by default. It is now supported only upon request by using the `--sqlite-dyn-extn` flag. This flag is a multiple option that specifies the path to an extension to be loaded into `surveilr`. To obtain the dynamic versions (`.dll`, `.so`, or `.dylib`), you can use [`sqlpkg`](https://sqlpkg.org/) to install the necessary extension.

For instance, to utilize the `text` functions:
- Install the extension with [`sqlpkg`](https://sqlpkg.org/?q=text): `sqlpkg install nalgeon/text`
- Then execute it:
  ```bash
  surveilr shell --cmd "select text_substring(''''hello world'''', 7, 5);" --sqlite-dyn-extn ./text.so
  ```'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.3.1'' as title, ''# `surveilr` v1.3.1 Release Notes 🎉

---

## 🚀 Bug Fixes

### 1. **`surveilr` SQLite Extensions**
This release fixes the `glibc` compatibility error that occured with `surveilr` while registering function extensions.'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.3.0'' as title, ''# `surveilr` Release Announcement: Now Fully Compatible Across All Distros 🎉

We are thrilled to announce that `surveilr` is now fully compatible with all major Linux distributions, resolving the longstanding issue related to OpenSSL compatibility! 🚀

## What''''s New?
- **Universal Compatibility**: `surveilr` now works seamlessly on **Ubuntu**, **Debian**, **Kali Linux**, and other Linux distributions, across various versions and architectures. Whether you''''re using Ubuntu 18.04, Debian 10, or the latest Kali Linux, `surveilr` is ready to perform without any hiccups.
- **Resolved OpenSSL Bug**: We’ve fixed the recurring OpenSSL-related issue that caused headaches for users on older and varied systems. With this update, you no longer need to worry about OpenSSL version mismatches or missing libraries.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.2.0'' as title, ''# `surveilr` v1.2.0 Release Notes 🎉

## What''''s New?
This update introduces two major additions that streamline file system integration and ingestion session management.

---

### New Features

#### 1. `surveilr_ingest_session_id` Scalar Function
The `surveilr_ingest_session_id` function is now available, offering robust management of ingestion sessions. This function ensures efficient session handling by:
- Reusing existing session IDs for devices with active sessions.
- Creating new ingestion sessions when none exist.
- Associating sessions with metadata for improved traceability.


#### 2. `surveilr_udi_dal_fs` Virtual Table Function
The `surveilr_udi_dal_fs` virtual table function provides seamless access to file system resources directly within your SQL queries. With this feature, you can:
- Query file metadata, such as names, paths, sizes, and timestamps.
- Retrieve file content and calculate digests for integrity checks.
- Traverse directories recursively to handle large and nested file systems effortlessly.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.1.0'' as title, ''# `surveilr` v1.1.0 Release Notes 🎉

## 🚀 New Features

### 1. **Integrated Documentation in Web UI**

This release introduces a comprehensive update to the RSSD Web UI, allowing users to access and view all `surveilr`-related SQLite functions, release notes, and internal documentation directly within the interface. This feature enhances user experience by providing integrated, easily navigable documentation without the need to leave the web environment, ensuring that all necessary information is readily available for efficient reference and usage.

### 2. **`uniform_resource` Graph Infrastructure**

The foundational framework for tracking `uniform_resource` content using graph representations has been laid out in this release. This infrastructure allows users to visualize `uniform_resource` data as connected graphs in addition to the traditional relational database structure. To facilitate this, three dedicated views—`imap_graph`, `plm_graph`, and `filesystem_graph`—have been created. These views provide a structured way to observe and interact with data from different ingestion sources:

- **`imap_graph`**: Represents the graphical relationships for content ingested through IMAP processes, allowing for a visual mapping of email and folder structures.
- **`plm_graph`**: Visualizes content from PLM (Product Lifecycle Management) ingestion, showcasing project and issue-based connections.
- **`filesystem_graph`**: Illustrates file ingestion paths and hierarchies, enabling users to track and manage file-based data more intuitively.

This release marks an important step towards enhancing data tracking capabilities, providing a dual approach of relational and graphical views for better data insights and management.
'' as description_md;
                

                    SELECT ''foldable'' as component;
                    SELECT ''v1.0.0'' as title, ''# `surveilr` v1.0.0 Release Notes 🎉

We’re thrilled to announce the release of `surveilr` v1.0, a significant milestone in our journey to deliver powerful tools for continuous security, quality and compliance evidence workflows. This release introduces a streamlined migration system and a seamless, user-friendly experience for accessing the `surveilr` Web UI.

---

## 🚀 New Features

### 1. **Database Migration System**

This release introduces a comprehensive database migration feature that allows smooth and controlled updates to the RSSD structure. Our migration system includes:

- **Structured Notebooks and Cells**: A structured system organizes SQL migration scripts into modular code notebooks, making migration scripts easy to track, audit, and execute as needed.
- **Idempotent vs. Non-Idempotent Handling**: Ensures each migration runs in an optimal and secure manner by tracking cell execution history, allowing for re-execution where safe.
- **Automated State Tracking**: All state changes are logged for complete auditing, showing timestamps, transition details, and the results of each migration step.
- **Transactional Execution**: All migrations run within a single transaction block for seamless rollbacks and data consistency.
- **Dynamic Migration Scripts**: Cells marked for migration are dynamically added to the migration script, reducing manual effort and risk of errors.

This system ensures safe, controlled migration of database changes, enhancing reliability and traceability for every update.

### 2. **Enhanced Default Command and Web UI Launch**

The surveilr executable now starts the Web UI as the default command when no specific CLI commands are passed. This feature aims to enhance accessibility and ease of use for new users and teams. Here’s what happens by default:

- **Automatic Web UI Startup**: By default, running surveilr without additional commands launches the surveilr Web UI.
- **Auto-Browser Launch**: Opens the default browser on the workstation, pointing to the Web UI’s URL and port, providing a user-friendly experience right from the first run.'' as description_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/functions.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''docs/functions.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              -- To display title
SELECT
  ''text'' AS component,
  ''Surveilr SQLite Functions'' AS title;

SELECT
  ''text'' AS component,
  ''Below is a comprehensive list and description of all Surveilr SQLite functions. Each function includes details about its parameters, return type, and version introduced.''
  AS contents_md;

SELECT
''list'' AS component,
''Surveilr Functions'' AS title;

  SELECT  name AS title,
        NULL AS icon,  -- Add an icon field if applicable
        ''functions-inner.sql?function='' || name || ''#function'' AS link,
        $function = name AS active
  FROM surveilr_function_doc
  ORDER BY name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'docs/functions-inner.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
select
  ''breadcrumb'' as component;
select
  ''Home'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
select
  ''Docs'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/docs/index.sql'' as link;
select
  ''SQL Functions'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/docs/functions.sql'' as link;
select
  $function as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/docs/functions-inner.sql?function=''  || $function AS link;


  SELECT
    ''text'' AS component,
    '''' || name || ''()'' AS title, ''function'' AS id
  FROM surveilr_function_doc WHERE name = $function;

  SELECT
    ''text'' AS component,
    description AS contents_md
  FROM surveilr_function_doc WHERE name = $function;

  SELECT
    ''text'' AS component,
    ''Introduced in version '' || version || ''.'' AS contents
  FROM surveilr_function_doc WHERE name = $function;

  SELECT
    ''title'' AS component,
    3 AS level,
    ''Parameters'' AS contents
  WHERE $function IS NOT NULL;

  SELECT
    ''card'' AS component,
    3 AS columns
    WHERE $function IS NOT NULL;
  SELECT
      json_each.value ->> ''$.name'' AS title,
      json_each.value ->> ''$.description'' AS description,
      json_each.value ->> ''$.data_type'' AS footer,
      ''azure'' AS color
  FROM surveilr_function_doc, json_each(surveilr_function_doc.parameters)
  WHERE name = $function;

  -- Navigation Buttons
  SELECT ''button'' AS component, ''sm'' AS size, ''pill'' AS shape;
  SELECT name AS title,
        NULL AS icon,  -- Add an icon field if needed
        sqlpage.link(''functions-inner.sql'', json_object(''function'', name)) AS link
  FROM surveilr_function_doc
  ORDER BY name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
