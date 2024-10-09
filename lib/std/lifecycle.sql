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
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('Documentation', 'Documentation', NULL, 'text/plain', '.txt', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('SQL', 'SQLite SQL Statements', NULL, 'application/sql', '.sql', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('AI LLM Prompt', 'Generative AI Large Language Model Prompt', NULL, 'text/plain', '.llm-prompt.txt', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('Text Asset (.puml)', 'Text Asset (.puml)', NULL, 'text/plain', '.puml', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_kernel" ("code_notebook_kernel_id", "kernel_name", "description", "mime_type", "file_extn", "elaboration", "governance", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('Text Asset (.rs)', 'Text Asset (.rs)', NULL, 'text/plain', '.rs', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  code_notebook_kernel_id = COALESCE(EXCLUDED.code_notebook_kernel_id, code_notebook_kernel_id), kernel_name = COALESCE(EXCLUDED.kernel_name, kernel_name), description = COALESCE(EXCLUDED.description, description), mime_type = COALESCE(EXCLUDED.mime_type, mime_type), file_extn = COALESCE(EXCLUDED.file_extn, file_extn), governance = COALESCE(EXCLUDED.governance, governance), elaboration = COALESCE(EXCLUDED.elaboration, elaboration), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXAWHM2AFVKB47T53BZ', 'Documentation', 'rssd-init', 'Boostrap SQL', NULL, '-- code provenance: `RssdInitSqlNotebook.bootstrapDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)
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
                c.cell_name;', '937f852925c6c939d20b36517fdc121c45c50415', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXAPGT43Z2T3Z656S16', 'SQL', 'ConstructionSqlNotebook', 'v001_once_initialDDL', NULL, '-- code provenance: `RssdInitSqlNotebook.v001_once_initialDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)

CREATE TABLE IF NOT EXISTS "party_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party" (
    "party_id" VARCHAR PRIMARY KEY NOT NULL,
    "party_type_id" TEXT NOT NULL,
    "party_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_type_id") REFERENCES "party_type"("code")
);
CREATE TABLE IF NOT EXISTS "party_relation_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party_relation" (
    "party_relation_id" VARCHAR PRIMARY KEY NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "related_party_id" VARCHAR NOT NULL,
    "relation_type_id" TEXT NOT NULL,
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
    FOREIGN KEY("relation_type_id") REFERENCES "party_relation_type"("code"),
    UNIQUE("party_id", "related_party_id", "relation_type_id")
);
CREATE TABLE IF NOT EXISTS "gender_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "person" (
    "person_id" VARCHAR NOT NULL,
    "person_first_name" TEXT NOT NULL,
    "person_middle_name" TEXT,
    "person_last_name" TEXT NOT NULL,
    "honorific_prefix" TEXT,
    "honorific_suffix" TEXT,
    "gender_id" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("person_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("gender_id") REFERENCES "gender_type"("code"),
    UNIQUE("person_id")
);
CREATE TABLE IF NOT EXISTS "organization" (
    "organization_id" VARCHAR NOT NULL,
    "name" TEXT NOT NULL,
    "alias" TEXT,
    "description" TEXT,
    "license" TEXT,
    "federal_tax_id_num" TEXT,
    "registration_date" TIMESTAMPTZ,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("organization_id") REFERENCES "party"("party_id"),
    UNIQUE("organization_id", "name")
);
CREATE TABLE IF NOT EXISTS "organization_role_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "organization_role" (
    "organization_role_id" VARCHAR PRIMARY KEY NOT NULL,
    "person_id" VARCHAR NOT NULL,
    "organization_id" VARCHAR NOT NULL,
    "organization_role_type_id" TEXT NOT NULL,
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
    FOREIGN KEY("organization_role_type_id") REFERENCES "organization_role_type"("code"),
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
    "ingest_imap_acct_folder_id" VARCHAR,
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
    FOREIGN KEY("ingest_imap_acct_folder_id") REFERENCES "ur_ingest_session_imap_acct_folder"("ur_ingest_session_imap_acct_folder_id"),
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
    "uniform_resource_id" VARCHAR,
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
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
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
    "lebel" TEXT NOT NULL,
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
    UNIQUE("user_id", "login", "email", "name")
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

CREATE INDEX IF NOT EXISTS "idx_party__party_type_id__party_name" ON "party"("party_type_id", "party_name");
CREATE INDEX IF NOT EXISTS "idx_party_relation__party_id__related_party_id__relation_type_id" ON "party_relation"("party_id", "related_party_id", "relation_type_id");
CREATE INDEX IF NOT EXISTS "idx_person__person_id__person_first_name__person_middle_name__person_last_name" ON "person"("person_id", "person_first_name", "person_middle_name", "person_last_name");
CREATE INDEX IF NOT EXISTS "idx_organization__organization_id__name" ON "organization"("organization_id", "name");
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
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_user__user_id" ON "ur_ingest_session_plm_user"("user_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_comment__ur_ingest_session_plm_acct_project_issue_id" ON "ur_ingest_session_plm_comment"("ur_ingest_session_plm_acct_project_issue_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_reaction__ur_ingest_session_plm_reaction_id" ON "ur_ingest_session_plm_reaction"("ur_ingest_session_plm_reaction_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_issue_reaction__ur_ingest_session_plm_issue_reaction_id" ON "ur_ingest_session_plm_issue_reaction"("ur_ingest_session_plm_issue_reaction_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_issue_type__id" ON "ur_ingest_session_plm_issue_type"("id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_attachment__uniform_resource_id__content" ON "ur_ingest_session_attachment"("uniform_resource_id", "content");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_udi_pgp_sql__ingest_session_id" ON "ur_ingest_session_udi_pgp_sql"("ingest_session_id");
CREATE INDEX IF NOT EXISTS "idx_orchestration_nature__orchestration_nature_id__nature" ON "orchestration_nature"("orchestration_nature_id", "nature");', 'd5a380d80eb2fd3e468cd30130ef9367618788af', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXBDDW7SJR16WHE42DE', 'SQL', 'ConstructionSqlNotebook', 'v001_seedDML', NULL, 'INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''ignore .git and node_modules paths'', ''default'', ''/(\.git|node_modules)/'', ''IGNORE_RESOURCE'', NULL, NULL, ''Ignore any entry with `/.git/` or `/node_modules/` in the path.'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''typical ingestion extensions'', ''default'', ''\.(?P<nature>md|mdx|html|json|jsonc|puml|txt|toml|yml|xml|tap|csv|tsv|ssv|psv|tm7)$'', ''CONTENT_ACQUIRABLE'', ''?P<nature>'', NULL, ''Ingest the content for md, mdx, html, json, jsonc, puml, txt, toml, and yml extensions. Assume the nature is the same as the extension.'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-[NATURE] style capturable executable'', ''default'', ''surveilr\[(?P<nature>[^\]]*)\]'', ''CAPTURABLE_EXECUTABLE'', ''?P<nature>'', NULL, ''Any entry with `surveilr-[XYZ]` in the path will be treated as a capturable executable extracting `XYZ` as the nature'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-SQL capturable executable'', ''default'', ''surveilr-SQL'', ''CAPTURABLE_EXECUTABLE | CAPTURABLE_SQL'', NULL, NULL, ''Any entry with surveilr-SQL in the path will be treated as a capturable SQL executable and allow execution of the SQL'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');

INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.plantuml -> .puml'', ''default'', ''(\.plantuml)$'', ''.puml'', NULL, ''Treat .plantuml as .puml files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.text -> .txt'', ''default'', ''(\.text)$'', ''.txt'', NULL, ''Treat .text as .txt files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.yaml -> .yml'', ''default'', ''(\.yaml)$'', ''.yml'', NULL, ''Treat .yaml as .yml files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

INSERT INTO "party_type" ("code", "value", "created_at") VALUES (''ORGANIZATION'', ''Organization'', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "party_type" ("code", "value", "created_at") VALUES (''PERSON'', ''Person'', NULL) ON CONFLICT DO NOTHING;

INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-csv'', ''Transform CSV'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-xml'', ''Transform XML'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-html'', ''Transform HTML'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;', '667d6661a82ba7f55ac3759a84ed086cb6933075', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXBJ0XFA0TC57AV0A1S', 'SQL', 'ConstructionSqlNotebook', 'v002_fsContentIngestSessionFilesStatsViewDDL', NULL, 'DROP VIEW IF EXISTS "ur_ingest_session_files_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats" AS
    WITH Summary AS (
        SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_fs_path_entry.file_extn, '''') AS file_extension,
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
        file_extension;', '9870d0c179334958ddda85827e4966b406c86e0c', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXBQAYJ5611S8T3FA7M', 'SQL', 'ConstructionSqlNotebook', 'v002_fsContentIngestSessionFilesStatsLatestViewDDL', NULL, 'DROP VIEW IF EXISTS "ur_ingest_session_files_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_files_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;', 'f7a286b3b64881e069f05950d992a3b04af5c8f3', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXB9ZDJ2JJZEB3WBP93', 'SQL', 'ConstructionSqlNotebook', 'v002_urIngestSessionTasksStatsViewDDL', NULL, 'DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats" AS
      WITH Summary AS (
          SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_task.ur_status, ''Ok'') AS ur_status,
            COALESCE(uniform_resource.nature, ''UNKNOWN'') AS nature,
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
        ur_status;', '1f7a7f2e454cf81922df584750d84a4d39a2381e', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXBE2RZ8KR90TDRPFDR', 'SQL', 'ConstructionSqlNotebook', 'v002_urIngestSessionTasksStatsLatestViewDDL', NULL, 'DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_tasks_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;', '633501882d79e8bf255919bff540f9d0143489e3', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXBS500JVAP5PN3ZAHM', 'SQL', 'ConstructionSqlNotebook', 'v002_urIngestSessionFileIssueViewDDL', NULL, 'DROP VIEW IF EXISTS "ur_ingest_session_file_issue";
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
             ufs.ur_diagnostics;', '99136e34dcf27424fa7b873b319ac5400786691e', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXB6SBPM50J370K81F6', 'AI LLM Prompt', 'rssd-init', 'understand notebooks schema', NULL, 'Understand the following structure of an SQLite database designed to store code notebooks and execution kernels.
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
                c.cell_name;', 'c8ca408c48613bee7f576c69167610fdf54f6a13', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXCJZSFF8TKJ2E9AQ5D', 'AI LLM Prompt', 'rssd-init', 'understand service schema', NULL, 'Understand the following structure of an SQLite database designed to store cybersecurity and compliance data for files in a file system.
The database is designed to store devices in the ''device'' table and entities called ''resources'' stored in the immutable append-only
''uniform_resource'' table. Each time files are "walked" they are stored in ingestion session and link back to ''uniform_resource''. Because all
tables are generally append only and immutable it means that the ingest_session_fs_path_entry table can be used for revision control
and historical tracking of file changes.

Use the following SQLite Schema to generate SQL queries that interact with these tables and once you understand them let me know so I can ask you for help:

-- code provenance: `RssdInitSqlNotebook.v001_once_initialDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/lifecycle.sql.ts)

CREATE TABLE IF NOT EXISTS "party_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party" (
    "party_id" VARCHAR PRIMARY KEY NOT NULL,
    "party_type_id" TEXT NOT NULL,
    "party_name" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_type_id") REFERENCES "party_type"("code")
);
CREATE TABLE IF NOT EXISTS "party_relation_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party_relation" (
    "party_relation_id" VARCHAR PRIMARY KEY NOT NULL,
    "party_id" VARCHAR NOT NULL,
    "related_party_id" VARCHAR NOT NULL,
    "relation_type_id" TEXT NOT NULL,
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
    FOREIGN KEY("relation_type_id") REFERENCES "party_relation_type"("code"),
    UNIQUE("party_id", "related_party_id", "relation_type_id")
);
CREATE TABLE IF NOT EXISTS "gender_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "person" (
    "person_id" VARCHAR NOT NULL,
    "person_first_name" TEXT NOT NULL,
    "person_middle_name" TEXT,
    "person_last_name" TEXT NOT NULL,
    "honorific_prefix" TEXT,
    "honorific_suffix" TEXT,
    "gender_id" TEXT NOT NULL,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("person_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("gender_id") REFERENCES "gender_type"("code"),
    UNIQUE("person_id")
);
CREATE TABLE IF NOT EXISTS "organization" (
    "organization_id" VARCHAR NOT NULL,
    "name" TEXT NOT NULL,
    "alias" TEXT,
    "description" TEXT,
    "license" TEXT,
    "federal_tax_id_num" TEXT,
    "registration_date" TIMESTAMPTZ,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT ''UNKNOWN'',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("organization_id") REFERENCES "party"("party_id"),
    UNIQUE("organization_id", "name")
);
CREATE TABLE IF NOT EXISTS "organization_role_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "organization_role" (
    "organization_role_id" VARCHAR PRIMARY KEY NOT NULL,
    "person_id" VARCHAR NOT NULL,
    "organization_id" VARCHAR NOT NULL,
    "organization_role_type_id" TEXT NOT NULL,
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
    FOREIGN KEY("organization_role_type_id") REFERENCES "organization_role_type"("code"),
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
    "ingest_imap_acct_folder_id" VARCHAR,
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
    FOREIGN KEY("ingest_imap_acct_folder_id") REFERENCES "ur_ingest_session_imap_acct_folder"("ur_ingest_session_imap_acct_folder_id"),
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
    "uniform_resource_id" VARCHAR,
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
    FOREIGN KEY("uniform_resource_id") REFERENCES "uniform_resource"("uniform_resource_id"),
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
    "lebel" TEXT NOT NULL,
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
    UNIQUE("user_id", "login", "email", "name")
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

CREATE INDEX IF NOT EXISTS "idx_party__party_type_id__party_name" ON "party"("party_type_id", "party_name");
CREATE INDEX IF NOT EXISTS "idx_party_relation__party_id__related_party_id__relation_type_id" ON "party_relation"("party_id", "related_party_id", "relation_type_id");
CREATE INDEX IF NOT EXISTS "idx_person__person_id__person_first_name__person_middle_name__person_last_name" ON "person"("person_id", "person_first_name", "person_middle_name", "person_last_name");
CREATE INDEX IF NOT EXISTS "idx_organization__organization_id__name" ON "organization"("organization_id", "name");
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
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_user__user_id" ON "ur_ingest_session_plm_user"("user_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_comment__ur_ingest_session_plm_acct_project_issue_id" ON "ur_ingest_session_plm_comment"("ur_ingest_session_plm_acct_project_issue_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_reaction__ur_ingest_session_plm_reaction_id" ON "ur_ingest_session_plm_reaction"("ur_ingest_session_plm_reaction_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_issue_reaction__ur_ingest_session_plm_issue_reaction_id" ON "ur_ingest_session_plm_issue_reaction"("ur_ingest_session_plm_issue_reaction_id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_plm_issue_type__id" ON "ur_ingest_session_plm_issue_type"("id");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_attachment__uniform_resource_id__content" ON "ur_ingest_session_attachment"("uniform_resource_id", "content");
CREATE INDEX IF NOT EXISTS "idx_ur_ingest_session_udi_pgp_sql__ingest_session_id" ON "ur_ingest_session_udi_pgp_sql"("ingest_session_id");
CREATE INDEX IF NOT EXISTS "idx_orchestration_nature__orchestration_nature_id__nature" ON "orchestration_nature"("orchestration_nature_id", "nature");,INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''ignore .git and node_modules paths'', ''default'', ''/(\.git|node_modules)/'', ''IGNORE_RESOURCE'', NULL, NULL, ''Ignore any entry with `/.git/` or `/node_modules/` in the path.'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''typical ingestion extensions'', ''default'', ''\.(?P<nature>md|mdx|html|json|jsonc|puml|txt|toml|yml|xml|tap|csv|tsv|ssv|psv|tm7)$'', ''CONTENT_ACQUIRABLE'', ''?P<nature>'', NULL, ''Ingest the content for md, mdx, html, json, jsonc, puml, txt, toml, and yml extensions. Assume the nature is the same as the extension.'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-[NATURE] style capturable executable'', ''default'', ''surveilr\[(?P<nature>[^\]]*)\]'', ''CAPTURABLE_EXECUTABLE'', ''?P<nature>'', NULL, ''Any entry with `surveilr-[XYZ]` in the path will be treated as a capturable executable extracting `XYZ` as the nature'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');
INSERT INTO "ur_ingest_resource_path_match_rule" ("ur_ingest_resource_path_match_rule_id", "namespace", "regex", "flags", "nature", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-SQL capturable executable'', ''default'', ''surveilr-SQL'', ''CAPTURABLE_EXECUTABLE | CAPTURABLE_SQL'', NULL, NULL, ''Any entry with surveilr-SQL in the path will be treated as a capturable SQL executable and allow execution of the SQL'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  ur_ingest_resource_path_match_rule_id = COALESCE(EXCLUDED.ur_ingest_resource_path_match_rule_id, ur_ingest_resource_path_match_rule_id), namespace = COALESCE(EXCLUDED.namespace, namespace), regex = COALESCE(EXCLUDED.regex, regex), flags = COALESCE(EXCLUDED.flags, flags), description = COALESCE(EXCLUDED.description, description), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = ''current_user'');

INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.plantuml -> .puml'', ''default'', ''(\.plantuml)$'', ''.puml'', NULL, ''Treat .plantuml as .puml files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.text -> .txt'', ''default'', ''(\.text)$'', ''.txt'', NULL, ''Treat .text as .txt files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "ur_ingest_resource_path_rewrite_rule" ("ur_ingest_resource_path_rewrite_rule_id", "namespace", "regex", "replace", "priority", "description", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''.yaml -> .yml'', ''default'', ''(\.yaml)$'', ''.yml'', NULL, ''Treat .yaml as .yml files'', NULL, (CURRENT_TIMESTAMP), NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;

INSERT INTO "party_type" ("code", "value", "created_at") VALUES (''ORGANIZATION'', ''Organization'', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "party_type" ("code", "value", "created_at") VALUES (''PERSON'', ''Person'', NULL) ON CONFLICT DO NOTHING;

INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-csv'', ''Transform CSV'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-xml'', ''Transform XML'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "orchestration_nature" ("orchestration_nature_id", "nature", "elaboration", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES (''surveilr-transform-html'', ''Transform HTML'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;,DROP VIEW IF EXISTS "ur_ingest_session_files_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats" AS
    WITH Summary AS (
        SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_fs_path_entry.file_extn, '''') AS file_extension,
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
        file_extension;,DROP VIEW IF EXISTS "ur_ingest_session_files_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_files_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;,DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats" AS
      WITH Summary AS (
          SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_task.ur_status, ''Ok'') AS ur_status,
            COALESCE(uniform_resource.nature, ''UNKNOWN'') AS nature,
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
        ur_status;,DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_tasks_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;,DROP VIEW IF EXISTS "ur_ingest_session_file_issue";
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
      ', 'c0ee2d5fde59f5c178160ebcd8e39f3871de777d', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXDPX3DBEQC2CGE7M0C', 'Text Asset (.puml)', 'rssd-init', 'surveilr-code-notebooks-erd.auto.puml', NULL, '@startuml surveilr-code-notebooks
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
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXJC9EMCADY58CB2N5H', 'Text Asset (.puml)', 'rssd-init', 'surveilr-service-erd.auto.puml', NULL, '@startuml surveilr-state
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
    * **code**: TEXT
    --
    * value: TEXT
  }

  entity "party" as party {
    * **party_id**: VARCHAR
    --
    * party_type_id: TEXT
    * party_name: TEXT
      elaboration: TEXT
  }

  entity "party_relation_type" as party_relation_type {
    * **code**: TEXT
    --
    * value: TEXT
  }

  entity "party_relation" as party_relation {
    * **party_relation_id**: VARCHAR
    --
    * party_id: VARCHAR
    * related_party_id: VARCHAR
    * relation_type_id: TEXT
      elaboration: TEXT
  }

  entity "gender_type" as gender_type {
    * **code**: TEXT
    --
    * value: TEXT
  }

  entity "person" as person {
    * person_id: VARCHAR
    * person_first_name: TEXT
      person_middle_name: TEXT
    * person_last_name: TEXT
      honorific_prefix: TEXT
      honorific_suffix: TEXT
    * gender_id: TEXT
      elaboration: TEXT
  }

  entity "organization" as organization {
    * organization_id: VARCHAR
    * name: TEXT
      alias: TEXT
      description: TEXT
      license: TEXT
      federal_tax_id_num: TEXT
      registration_date: TIMESTAMPTZ
      elaboration: TEXT
  }

  entity "organization_role_type" as organization_role_type {
    * **code**: TEXT
    --
    * value: TEXT
  }

  entity "organization_role" as organization_role {
    * **organization_role_id**: VARCHAR
    --
    * person_id: VARCHAR
    * organization_id: VARCHAR
    * organization_role_type_id: TEXT
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
      ingest_imap_acct_folder_id: VARCHAR
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
      uniform_resource_id: VARCHAR
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
    * lebel: TEXT
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

  party_type |o..o{ party
  party |o..o{ party_relation
  party |o..o{ party_relation
  party_relation_type |o..o{ party_relation
  party |o..o{ person
  gender_type |o..o{ person
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
  ur_ingest_session_imap_acct_folder |o..o{ uniform_resource
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
  uniform_resource |o..o{ ur_ingest_session_imap_acct_folder_message
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
@enduml', '4b969b52a269e847a64619c377d3fa61e7dd9796', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
INSERT INTO "code_notebook_cell" ("code_notebook_cell_id", "notebook_kernel_id", "notebook_name", "cell_name", "cell_governance", "interpretable_code", "interpretable_code_hash", "description", "arguments", "created_at", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01J9QW0JXM87M4BJ6WH15BG3VW', 'Text Asset (.rs)', 'rssd-init', 'models_polygenix.rs', NULL, '/*
const PARTY_TYPE: &str = "party_type";
const PARTY: &str = "party";
const PARTY_RELATION_TYPE: &str = "party_relation_type";
const PARTY_RELATION: &str = "party_relation";
const GENDER_TYPE: &str = "gender_type";
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
const ASSURANCE_SCHEMA: &str = "assurance_schema";
const CODE_NOTEBOOK_KERNEL: &str = "code_notebook_kernel";
const CODE_NOTEBOOK_CELL: &str = "code_notebook_cell";
const CODE_NOTEBOOK_STATE: &str = "code_notebook_state";
*/

// `party_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct PartyType {
    code: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    value: String, // ''string'' maps directly to Rust type
}

// `party` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Party {
    party_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    party_type_id: String, // ''string'' maps directly to Rust type
    party_name: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `party_relation_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct PartyRelationType {
    code: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    value: String, // ''string'' maps directly to Rust type
}

// `party_relation` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct PartyRelation {
    party_relation_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    party_id: String, // ''string'' maps directly to Rust type
    related_party_id: String, // ''string'' maps directly to Rust type
    relation_type_id: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `gender_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct GenderType {
    code: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    value: String, // ''string'' maps directly to Rust type
}

// `person` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Person {
    person_id: String, // ''string'' maps directly to Rust type
    person_first_name: String, // ''string'' maps directly to Rust type
    person_middle_name: Option<String>, // ''string'' maps directly to Rust type
    person_last_name: String, // ''string'' maps directly to Rust type
    honorific_prefix: Option<String>, // ''string'' maps directly to Rust type
    honorific_suffix: Option<String>, // ''string'' maps directly to Rust type
    gender_id: String, // ''string'' maps directly to Rust type
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `organization` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Organization {
    organization_id: String, // ''string'' maps directly to Rust type
    name: String, // ''string'' maps directly to Rust type
    alias: Option<String>, // ''string'' maps directly to Rust type
    description: Option<String>, // ''string'' maps directly to Rust type
    license: Option<String>, // ''string'' maps directly to Rust type
    federal_tax_id_num: Option<String>, // ''string'' maps directly to Rust type
    registration_date: Option<String>, // uknown type ''TIMESTAMPTZ'', mapping to String by default
    elaboration: Option<String>, // uknown type ''string::json'', mapping to String by default
}

// `organization_role_type` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrganizationRoleType {
    code: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    value: String, // ''string'' maps directly to Rust type
}

// `organization_role` table
#[derive(Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct OrganizationRole {
    organization_role_id: String, // PRIMARY KEY (''string'' maps directly to Rust type)
    person_id: String, // ''string'' maps directly to Rust type
    organization_id: String, // ''string'' maps directly to Rust type
    organization_role_type_id: String, // ''string'' maps directly to Rust type
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
    ingest_imap_acct_folder_id: Option<String>, // ''string'' maps directly to Rust type
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
    uniform_resource_id: Option<String>, // ''string'' maps directly to Rust type
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
    lebel: String, // ''string'' maps directly to Rust type
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
', 'c29d1aab909513f6875d6b1b264dae939a7bf5f3', NULL, NULL, (CURRENT_TIMESTAMP), (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user'), NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO UPDATE SET  description = COALESCE(EXCLUDED.description, description), cell_governance = COALESCE(EXCLUDED.cell_governance, cell_governance), interpretable_code = COALESCE(EXCLUDED.interpretable_code, interpretable_code), "updated_at" = CURRENT_TIMESTAMP, "updated_by" = (SELECT "value" FROM "session_state_ephemeral" WHERE "key" = 'current_user');
