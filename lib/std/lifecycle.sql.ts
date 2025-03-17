#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import * as nb from "./notebook/rssd.ts";
import * as cnb from "./notebook/code.ts";
import { lifecycle as lcm } from "./models/mod.ts";
import { polygen as p, SQLa } from "./deps.ts";
import * as stdPackage from "./package.sql.ts";

// deno-lint-ignore no-explicit-any
type Any = any;

const surveilrSpecialMigrationNotebookName = "ConstructionSqlNotebook" as const;
const osQueryMsNotebookName = "osQuery Management Server (Prime)" as const;
const osQueryMsCellGovernance = {
  "osquery-ms-interval": 60,
  "results-uniform-resource-store-jq-filters": [
    "del(.calendarTime, .unixTime, .action, .counter)",
  ],
  "results-uniform-resource-captured-jq-filters": ["{calendarTime, unixTime}"],
};
const osQueryMsFilterNotebookName =
  "osQuery Management Server Default Filters (Prime)" as const;

const osQueryMsPolicyNotebookName =
  "osQuery Management Server (Policy)" as const;

// TODO: should the `CREATE VIEW` definitions be in code_notebook_cell or straight in RSSD?
// TODO: update ON CONFLICT to properly do updates, not just "DO NOTHING"
// TODO: use SQLa/pattern/typical/typical.ts:activityLogDmlPartial for history tracking

// TODO: types of SQL
// - `surveilr` tables for RSSD initialization ("bootstrap.sql" embedded in Rust binary)
//    code_notebook_*, assurance_schema, uniform_resource, etc.
// - `surveilr` CLI UX views needed to operate CLI
// - services tables, views needed by users of `surveilr` (not surveilr itself)
// - web-ui tables, views needs

/**
 * Decorator function which declares that the method it decorates creates a
 * code_notebook_cell SQL kernel row but forced to be in a special notebook
 * called "ConstructionSqlNotebook", which defines "migratable" SQL blocks.
 *
 * @param init - The code_notebook_cell.* column values
 * @returns A decorator function that informs its host notebook about declaration
 *
 * @example
 * class MyNotebook extends TypicalCodeNotebook {
 *   @migratableCell({ ... })
 *   "myCell"() {
 *     // method implementation
 *   }
 * }
 */
export function migratableCell(
  init?: Omit<Parameters<typeof cnb.sqlCell>[0], "notebook_name">,
) {
  return cnb.sqlCell<RssdInitSqlNotebook>({
    ...init,
    notebook_name: surveilrSpecialMigrationNotebookName,
  }, (dc, methodCtx) => {
    methodCtx.addInitializer(function () {
      this.migratableCells.set(String(methodCtx.name), dc);
    });
    // we're not modifying the DecoratedCell
    return dc;
  });
}

/**
 * Decorator function which declares that the method it decorates creates a
 * code_notebook_cell SQL kernel row but forced to be in a special notebook
 * called "osQuery Management Server (Prime)", which defines osQuery SQL blocks.
 *
 * @param init - The code_notebook_cell.* column values
 * @returns A decorator function that informs its host notebook about declaration
 *
 * @example
 * class MyNotebook extends TypicalCodeNotebook {
 *   @osQueryMsCell({ ... })
 *   "myCell"() {
 *     // method implementation
 *   }
 * }
 */
export function osQueryMsCell(
  init?: Omit<
    Parameters<typeof cnb.sqlCell>[0],
    "notebook_name" | "cell_governance"
  >,
  targets: string[] = ["macos", "windows", "linux"],
  singleton: boolean = false,
  extraFilters: string[] = [],
) {
  const cellGovernance = JSON.stringify({
    ...osQueryMsCellGovernance,
    "results-uniform-resource-store-jq-filters": [
      ...osQueryMsCellGovernance["results-uniform-resource-store-jq-filters"],
      ...extraFilters,
    ],
    targets,
    singleton,
  });

  return cnb.sqlCell<RssdInitSqlNotebook>({
    ...init,
    notebook_name: osQueryMsNotebookName,
    cell_governance: cellGovernance,
  }, (dc, methodCtx) => {
    methodCtx.addInitializer(function () {
      this.migratableCells.set(String(methodCtx.name), dc);
    });
    // we're not modifying the DecoratedCell
    return dc;
  });
}

interface OsqueryMsPolicyGovernance {
  targets: string[];
  required_note: string;
  resolution: string;
  critical: boolean;
  description: string;
}

export function osQueryMsPolicyCell(
  // init?: Omit<
  // Parameters<typeof cnb.sqlCell>[0],
  // "notebook_name" | "cell_governance"
  // >,
  policyGovernance: OsqueryMsPolicyGovernance,
) {
  return cnb.sqlCell<RssdInitSqlNotebook>({
    description: policyGovernance.description,
    notebook_name: osQueryMsPolicyNotebookName,
    cell_governance: JSON.stringify({
      ...osQueryMsCellGovernance,
      targets: policyGovernance.targets,
      singleton: false,
      policy: {
        required_note: policyGovernance.required_note,
        resolution: policyGovernance.resolution,
        critical: policyGovernance.critical,
      },
    }),
  }, (dc, methodCtx) => {
    methodCtx.addInitializer(function () {
      this.migratableCells.set(String(methodCtx.name), dc);
    });
    // we're not modifying the DecoratedCell
    return dc;
  });
}

/**
 * Decorator function which declares that the method it decorates creates a
 * code_notebook_cell SQL kernel row but forced to be in a special notebook
 * called "osQuery Management Server Default Filters (Prime)", which defines parameters on how to execute osQuerMS queries and how to post precess the results.
 *
 * @param init - The code_notebook_cell.* column values
 * @returns A decorator function that informs its host notebook about declaration
 *
 * @example
 * class MyNotebook extends TypicalCodeNotebook {
 *   @osQueryMsFilterCell({ ... })
 *   "myCell"() {
 *     // method implementation
 *   }
 * }
 */
export function osQueryMsFilterCell(
  init?: Omit<
    Parameters<typeof cnb.sqlCell>[0],
    "notebook_name" | "cell_governance"
  >,
) {
  return cnb.sqlCell<RssdInitSqlNotebook>({
    ...init,
    notebook_name: osQueryMsFilterNotebookName,
    cell_governance: JSON.stringify({
      ...osQueryMsCellGovernance,
      targets: [],
      singleton: false,
    }),
  }, (dc, methodCtx) => {
    methodCtx.addInitializer(function () {
      this.migratableCells.set(String(methodCtx.name), dc);
    });
    // we're not modifying the DecoratedCell
    return dc;
  });
}

/**
 * Decorator function which declares that the method it decorates creates a
 * code_notebook_cell DenoTaskShell kernel row.
 *
 * @param init - The code_notebook_cell.* column values
 * @returns A decorator function that informs its host notebook about declaration
 *
 * @example
 * class MyNotebook extends TypicalCodeNotebook {
 *   @denoTaskShellCell({ ... })
 *   myCell() {
 *     // method implementation
 *   }
 * }
 */
export function denoTaskShellCell(
  init?: Partial<cnb.CodeNotebookKernelCellRecord<"DenoTaskShell">>,
) {
  return cnb.kernelCell<"DenoTaskShell", cnb.TypicalCodeNotebook>(
    "DenoTaskShell",
    init,
    {
      code_notebook_kernel_id: "DenoTaskShell",
      kernel_name: "Deno Task Shell",
      mime_type: "application/x-deno-task-sh",
      file_extn: ".deno-task-sh",
    },
  );
}

/**
 * Decorator function which declares that the method it decorates creates a
 * code_notebook_cell AI LLM kernel row.
 *
 * @param init - The code_notebook_cell.* column values
 * @returns A decorator function that informs its host notebook about declaration
 *
 * @example
 * class MyNotebook extends TypicalCodeNotebook {
 *   @llmPromptCell({ ... })
 *   myCell() {
 *     // method implementation
 *   }
 * }
 */
export function llmPromptCell(
  init?: Partial<cnb.CodeNotebookKernelCellRecord<"AI LLM Prompt">>,
) {
  return cnb.kernelCell<"AI LLM Prompt", cnb.TypicalCodeNotebook>(
    "AI LLM Prompt",
    init,
    {
      code_notebook_kernel_id: "AI LLM Prompt",
      kernel_name: "Generative AI Large Language Model Prompt",
      mime_type: "text/plain",
      file_extn: ".llm-prompt.txt",
    },
  );
}

/**
 * Decorator function which declares that the method it decorates creates a
 * code_notebook_cell Documentation kernel row.
 *
 * @param init - The code_notebook_cell.* column values
 * @returns A decorator function that informs its host notebook about declaration
 *
 * @example
 * class MyNotebook extends TypicalCodeNotebook {
 *   @docsCell({ ... })
 *   myCell() {
 *     // method implementation
 *   }
 * }
 */
export function docsCell(
  init?: Partial<cnb.CodeNotebookKernelCellRecord<"Documentation">>,
) {
  return cnb.kernelCell<"Documentation", cnb.TypicalCodeNotebook>(
    "Documentation",
    init,
    {
      code_notebook_kernel_id: "Documentation",
      kernel_name: "Documentation",
      mime_type: "text/plain",
      file_extn: ".txt",
    },
  );
}

/**
 * RssdInitSqlNotebook creates all SQL which populates the `bootstrap.sql` file
 * embedded into the surveilr Rust binary during build time. All "minimal" RSSD
 * initialization SQL DDL, DML, DQL and and default SQL migrations for all
 * surveilr CLI UX objects such as tables and views are incorporated.
 *
 * Any methods ending in `SQL`, `DDL`, `DML` generate SQL that will be immediately
 * executed when loaded into SQLite. Any methods decorated with @cell will not be
 * immediately executed; they will be stored in `code_notebook_cell` and will be
 * executed using custom business logic at runtime depending on the kernel and
 * nature of the their content.
 *
 * Note that `once_` pragma in the cell names means it must only be run once in
 * the surveilr database; this `once_` pragma does not mean anything to the
 * code_notebook_* infra but the naming convention does tell `surveilr` migration
 * lifecycle how to operate the cell at runtime initiatlization of a RSSD.
 *
 * If there is no `once_` pragma in the name of the cell then it will be executed
 * (migrated) each time an RSSD is opened.
 */
export class RssdInitSqlNotebook extends cnb.TypicalCodeNotebook {
  readonly migratableCells: Map<string, cnb.DecoratedCell<"SQL">> = new Map();
  readonly codeNbModels = lcm.codeNotebooksModels();
  readonly serviceModels = lcm.serviceModels();

  constructor() {
    super("rssd-init");
  }

  bootstrapDDL() {
    return this.SQL`
      -- ${this.tsProvenanceComment(import.meta.url)}
      ${this.sqlEngineState.seedDML}

      ${this.codeNbModels.informationSchema.tables}

      ${this.codeNbModels.informationSchema.tableIndexes}

      ${this.notebookBusinessLogicViews()}
  
      ${this.surveilrFunctionsAndExtensionsDocs()}
      `;
  }

  // We store the entire bootstrap as a "comment" cell in code_notebook_cell
  // for history/documentation purposes in case the RSSD is sent for debugging
  // to Help Desk.
  @docsCell()
  "Boostrap SQL"() {
    return this.bootstrapDDL();
  }

  surveilrFunctionsAndExtensionsDocs() {
    return this.SQL`
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
    `;
  }

  uniformResourceGraphViews() {
    return [
      this.viewDefn("plm_graph")`
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
            ure.graph_name = 'plm';
      `,
      this.viewDefn("imap_graph")`
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
          ure.graph_name = 'imap';
      `,
      this.viewDefn("filesystem_graph")`
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
            ure.graph_name = 'filesystem';
      `,
    ];
  }

  notebookBusinessLogicViews() {
    return [
      this.viewDefn("code_notebook_cell_versions") /* sql */`
          -- ${this.tsProvenanceComment(import.meta.url)}
          -- All cells and how many different versions of each cell are available
          SELECT notebook_name,
                notebook_kernel_id,
                cell_name,
                COUNT(*) OVER(PARTITION BY notebook_name, cell_name) AS versions,
                code_notebook_cell_id
            FROM code_notebook_cell
        ORDER BY notebook_name, cell_name;`,

      this.viewDefn("code_notebook_cell_latest") /* sql */`
        -- ${this.tsProvenanceComment(import.meta.url)}
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
        ) c WHERE c.rn = 1;`,

      this.viewDefn("code_notebook_sql_cell_migratable_version") /* sql */`
        -- ${this.tsProvenanceComment(import.meta.url)}
        -- All cells that are candidates for migration (including duplicates)
        SELECT c.code_notebook_cell_id,
              c.notebook_name,
              c.cell_name,
              c.interpretable_code,
              c.interpretable_code_hash,
              CASE WHEN c.cell_name LIKE '%_once_%' THEN FALSE ELSE TRUE END AS is_idempotent,
              COALESCE(c.updated_at, c.created_at) version_timestamp
          FROM code_notebook_cell c
        WHERE c.notebook_name = '${surveilrSpecialMigrationNotebookName}'
        ORDER BY c.cell_name;`,

      this.viewDefn("code_notebook_sql_cell_migratable") /* sql */`
        -- ${this.tsProvenanceComment(import.meta.url)}
        -- All cells that are candidates for migration (latest only)
        SELECT c.*,
               CASE WHEN c.cell_name LIKE '%_once_%' THEN FALSE ELSE TRUE END AS is_idempotent
          FROM code_notebook_cell_latest c
        WHERE c.notebook_name = '${surveilrSpecialMigrationNotebookName}'
        ORDER BY c.cell_name;`,

      this.viewDefn("code_notebook_sql_cell_migratable_state") /* sql */`
        -- ${this.tsProvenanceComment(import.meta.url)}
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
        ORDER BY c.cell_name;`,

      this.viewDefn("code_notebook_sql_cell_migratable_not_executed") /* sql */`
        -- ${this.tsProvenanceComment(import.meta.url)}
        -- All latest migratable cells that have not yet been "executed" (based on the code_notebook_state table)
        SELECT c.*
          FROM code_notebook_sql_cell_migratable c
          LEFT JOIN code_notebook_state s
            ON c.code_notebook_cell_id = s.code_notebook_cell_id AND s.to_state = 'EXECUTED'
          WHERE s.code_notebook_cell_id IS NULL
        ORDER BY c.cell_name;`,

      this.viewDefn("code_notebook_migration_sql") /* sql */`
        -- ${this.tsProvenanceComment(import.meta.url)}
        -- Creates a dynamic migration script by concatenating all interpretable_code for cells that should be migrated.
        -- Excludes cells with names containing '_once_' if they have already been executed.
        -- Includes comments before each block and special comments for excluded cells.
        -- Wraps everything in a single transaction
        SELECT
            'BEGIN TRANSACTION;\n\n'||
            '${this.sessionStateTable}\n\n' ||
            GROUP_CONCAT(
              CASE
                  -- Case 1: Non-idempotent and already executed
                  WHEN c.is_idempotent = FALSE AND s.code_notebook_cell_id IS NOT NULL THEN
                      '-- ' || c.notebook_name || '.' || c.cell_name || ' not included because it is non-idempotent and was already executed on ' || s.transitioned_at || '\n'

                  -- Case 2: Idempotent and not yet executed, idempotent and being reapplied, or non-idempotent and being run for the first time
                  ELSE
                      '-- ' || c.notebook_name || '.' || c.cell_name || '\n' ||
                      CASE
                          -- First execution (non-idempotent or idempotent)
                          WHEN s.code_notebook_cell_id IS NULL THEN
                              '-- Executing for the first time.\n'

                          -- Reapplying execution (idempotent)
                          ELSE
                              '-- Reapplying execution. Last executed on ' || s.transitioned_at || '\n'
                      END ||
                      c.interpretable_code || '\n' ||
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
                      'CURRENT_TIMESTAMP' || ')' || '\n' ||
                      'ON CONFLICT(code_notebook_cell_id, from_state, to_state) DO UPDATE SET updated_at = CURRENT_TIMESTAMP, ' ||
                        'transition_reason = ''Reapplied ' || datetime('now', 'localtime') || ''';' || '\n'
              END,
              '\n'
            ) || '\n\nCOMMIT;' AS migration_sql
        FROM
            code_notebook_sql_cell_migratable c
        LEFT JOIN
            code_notebook_state s
            ON c.code_notebook_cell_id = s.code_notebook_cell_id AND s.to_state = 'EXECUTED'
        ORDER BY
            c.cell_name;`,
    ];
  }

  @migratableCell({
    description:
      "Creates all service tables to initialize an RSS (`once_` pragma means it will only be run once in the database by surveilr)",
  })
  v001_once_initialDDL() {
    // deno-fmt-ignore
    return this.SQL`
      -- ${this.tsProvenanceComment(import.meta.url)}

      ${this.serviceModels.informationSchema.tables}

      ${this.serviceModels.informationSchema.tableIndexes}`;
  }

  @migratableCell({
    description:
      "Creates a session_state_ephemeral table for session arguments",
  })
  session_ephemeral_table() {
    // deno-fmt-ignore
    return this.SQL`
      ${this.sessionStateTable}
      `;
  }

  // TODO: check with DML should only be inserted once so that if customers override
  //       content, a future migration won't overwrite their data
  @migratableCell({
    description:
      "Seed data which provides default configuration for surveilr app",
  })
  v001_seedDML() {
    const created_at = this.sqlEngineNow;
    const namespace = "default";

    const urIngestPathMatchRules = () => {
      const { urIngestPathMatchRule } = this.serviceModels;
      const options = {
        onConflict: this.onConflictDoUpdateSet(
          urIngestPathMatchRule,
          this.ANY_CONFLICT,
          "ur_ingest_resource_path_match_rule_id",
          "namespace",
          "regex",
          "flags",
          "description",
        ),
      };
      // NOTE: all `\\` will be replaced by JS runtime with single `\`
      return [
        urIngestPathMatchRule.insertDML({
          ur_ingest_resource_path_match_rule_id:
            "ignore .git and node_modules paths",
          namespace,
          regex: "/(\\.git|node_modules)/",
          flags: "IGNORE_RESOURCE",
          description:
            "Ignore any entry with `/.git/` or `/node_modules/` in the path.",
          created_at,
        }, options),
        urIngestPathMatchRule.insertDML({
          ur_ingest_resource_path_match_rule_id: "typical ingestion extensions",
          namespace,
          regex:
            "\\.(?P<nature>md|mdx|html|json|jsonc|puml|txt|toml|yml|xml|tap|csv|tsv|ssv|psv|tm7|pdf|docx|doc|pptx|ppt|xlsx|xls)$",
          flags: "CONTENT_ACQUIRABLE",
          nature: "?P<nature>", // should be same as src/resource.rs::PFRE_READ_NATURE_FROM_REGEX
          description:
            "Ingest the content for md, mdx, html, json, jsonc, puml, txt, toml, and yml extensions. Assume the nature is the same as the extension.",
          created_at,
        }, options),
        urIngestPathMatchRule.insertDML({
          ur_ingest_resource_path_match_rule_id:
            "surveilr-[NATURE] style capturable executable",
          namespace,
          regex: "surveilr\\[(?P<nature>[^\\]]*)\\]",
          flags: "CAPTURABLE_EXECUTABLE",
          nature: "?P<nature>", // should be same as src/resource.rs::PFRE_READ_NATURE_FROM_REGEX
          description:
            "Any entry with `surveilr-[XYZ]` in the path will be treated as a capturable executable extracting `XYZ` as the nature",
          created_at,
        }, options),
        urIngestPathMatchRule.insertDML({
          ur_ingest_resource_path_match_rule_id:
            "surveilr-SQL capturable executable",
          namespace,
          regex: "surveilr-SQL",
          flags: "CAPTURABLE_EXECUTABLE | CAPTURABLE_SQL",
          description:
            "Any entry with surveilr-SQL in the path will be treated as a capturable SQL executable and allow execution of the SQL",
          created_at,
        }, options),
      ];
    };

    const urIngestPathRewriteRules = () => {
      const { urIngestPathRewriteRule } = this.serviceModels;
      const options = { onConflict: { SQL: () => `ON CONFLICT DO NOTHING` } };
      // NOTE: all `\\` will be replaced by JS runtime with single `\`
      return [
        urIngestPathRewriteRule.insertDML({
          ur_ingest_resource_path_rewrite_rule_id: ".plantuml -> .puml",
          namespace,
          regex: "(\\.plantuml)$",
          replace: ".puml",
          description: "Treat .plantuml as .puml files",
          created_at,
        }, options),
        urIngestPathRewriteRule.insertDML({
          ur_ingest_resource_path_rewrite_rule_id: ".text -> .txt",
          namespace,
          regex: "(\\.text)$",
          replace: ".txt",
          description: "Treat .text as .txt files",
          created_at,
        }, options),
        urIngestPathRewriteRule.insertDML({
          ur_ingest_resource_path_rewrite_rule_id: ".yaml -> .yml",
          namespace,
          regex: "(\\.yaml)$",
          replace: ".yml",
          description: "Treat .yaml as .yml files",
          created_at,
        }, options),
      ];
    };

    const partyTypeRules = () => {
      const { partyType } = this.serviceModels;
      const options = { onConflict: { SQL: () => `ON CONFLICT DO NOTHING` } };

      return [
        partyType.insertDML({
          party_type_id: this.sqlEngineNewUlid,
          code: "ORGANIZATION",
          value: lcm.PartyType.ORGANIZATION,
        }, options),
        partyType.insertDML({
          party_type_id: this.sqlEngineNewUlid,
          code: "PERSON",
          value: lcm.PartyType.PERSON,
        }, options),
      ];
    };

    const orchestrationNatureRules = () => {
      const { orchestrationNature } = this.serviceModels;
      const options = { onConflict: { SQL: () => `ON CONFLICT DO NOTHING` } };

      return [
        orchestrationNature.insertDML({
          orchestration_nature_id: "surveilr-transform-csv",
          nature: "Transform CSV",
        }, options),
        orchestrationNature.insertDML({
          orchestration_nature_id: "surveilr-transform-xml",
          nature: "Transform XML",
        }, options),
        orchestrationNature.insertDML({
          orchestration_nature_id: "surveilr-transform-html",
          nature: "Transform HTML",
        }, options),
      ];
    };

    const uniformResourceGraphRules = () => {
      const { uniformResourceGraph } = this.serviceModels;
      const options = { onConflict: { SQL: () => `ON CONFLICT DO NOTHING` } };

      return [
        uniformResourceGraph.insertDML({
          name: "filesystem",
          elaboration: "{}",
        }, options),
        uniformResourceGraph.insertDML({
          name: "imap",
          elaboration: "{}",
        }, options),
        uniformResourceGraph.insertDML({
          name: "plm",
          elaboration: "{}",
        }, options),
        uniformResourceGraph.insertDML({
          name: "osquery-ms",
          elaboration: "{}",
        }, options),
      ];
    };

    // deno-fmt-ignore
    return this.SQL`
      ${urIngestPathMatchRules()}

      ${urIngestPathRewriteRules()}

      ${partyTypeRules()}

      ${orchestrationNatureRules()}

      ${uniformResourceGraphRules}

      ${this.uniformResourceGraphViews()}

      ${this.allOsqueryPolicies()}
      `;
  }

  /**
   * Prepares a prompt that will allow the user to "teach" an LLM about this
   * project's "code notebooks" schema and how to interact with it.
   * @returns AI prompt as text that can be used to allow LLMs to generate SQL for you
   */
  @llmPromptCell()
  async "understand notebooks schema"() {
    const { codeNotebookKernel, codeNotebookCell, codeNotebookState } =
      this.codeNbModels;
    // deno-fmt-ignore
    return nb.unindentedText`
      Understand the following structure of an SQLite database designed to store code notebooks and execution kernels.
      The database comprises three main tables: 'code_notebook_kernel', 'code_notebook_cell', and 'code_notebook_state'.

      1. '${codeNotebookKernel.tableName}': ${codeNotebookKernel.tblQualitySystem?.description}

      2. '${codeNotebookCell.tableName}': ${codeNotebookCell.tblQualitySystem?.description}

      3. '${codeNotebookState.tableName}': ${codeNotebookState.tblQualitySystem?.description}

      The relationships are as follows:
      - Each cell in 'code_notebook_cell' is associated with a kernel in 'code_notebook_kernel'.
      - The 'code_notebook_state' table tracks changes in the state of each cell, linking back to the 'code_notebook_cell' table.

      Use the following SQLite tables and views to generate SQL queries that interact with these tables and once you understand them let me know so I can ask you for help:

      ${await this.textFrom(this.bootstrapDDL(), () => `ERROR: unknown value should never happen`)}`;
  }

  @llmPromptCell()
  async "understand service schema"() {
    // TODO: add table and column descriptions into migratableSQL to help LLMs
    const migratableSQL: string[] = [];
    for (const mc of this.migratableCells.values()) {
      // this is put into a `for` loop instead of `map` because we need ordered awaits
      migratableSQL.push(
        await this.textFrom(
          await mc.methodFn.apply(this),
          (value) =>
            // deno-fmt-ignore
            `\n/* '${String(mc.methodName)}' in 'RssdInitSqlNotebook' returned type ${typeof value} instead of string | string[] | SQLa.SqlTextSupplier */`,
        ),
      );
    }

    // deno-fmt-ignore
    return nb.unindentedText`
        Understand the following structure of an SQLite database designed to store cybersecurity and compliance data for files in a file system.
        The database is designed to store devices in the 'device' table and entities called 'resources' stored in the immutable append-only
        'uniform_resource' table. Each time files are "walked" they are stored in ingestion session and link back to 'uniform_resource'. Because all
        tables are generally append only and immutable it means that the ingest_session_fs_path_entry table can be used for revision control
        and historical tracking of file changes.

        Use the following SQLite Schema to generate SQL queries that interact with these tables and once you understand them let me know so I can ask you for help:

        ${migratableSQL}
      `;
  }

  @cnb.textAssetCell(".puml", "Text Asset (.puml)")
  async "surveilr-code-notebooks-erd.auto.puml"() {
    const { codeNbModels } = this;
    const pso: Parameters<
      typeof p.diagram.typicalPlantUmlIeOptions<
        SQLa.SqlEmitContext,
        SQLa.SqlDomainQS,
        SQLa.SqlDomainsQS<SQLa.SqlDomainQS>
      >
    >[0] = {
      includeEntityAttr: (ea) =>
        this.exludedHousekeepingCols.find((c) => c == ea.attr.identity)
          ? false
          : true,
    };
    const nbPumlIE = new p.diagram.PlantUmlIe<SQLa.SqlEmitContext, Any, Any>(
      this.emitCtx,
      function* () {
        for (const table of codeNbModels.informationSchema.tables) {
          if (SQLa.isGraphEntityDefinitionSupplier(table)) {
            yield table.graphEntityDefn();
          }
        }
      },
      p.diagram.typicalPlantUmlIeOptions({
        diagramName: "surveilr-code-notebooks",
        ...pso,
      }),
    );
    return await SQLa.polygenCellContent(
      this.emitCtx,
      await nbPumlIE.polygenContent(),
    );
  }

  @cnb.textAssetCell(".puml", "Text Asset (.puml)")
  async "surveilr-service-erd.auto.puml"() {
    const { serviceModels } = this;
    const pso: Parameters<
      typeof p.diagram.typicalPlantUmlIeOptions<
        SQLa.SqlEmitContext,
        SQLa.SqlDomainQS,
        SQLa.SqlDomainsQS<SQLa.SqlDomainQS>
      >
    >[0] = {
      // emit without housekeeping since rusqlite_serde doesn't support Date/Timestamp
      includeEntityAttr: (ea) =>
        this.exludedHousekeepingCols.find((c) => c == ea.attr.identity)
          ? false
          : true,
    };
    const servicePumlIE = new p.diagram.PlantUmlIe(
      this.emitCtx,
      function* () {
        for (const table of serviceModels.informationSchema.tables) {
          if (SQLa.isGraphEntityDefinitionSupplier(table)) {
            yield table.graphEntityDefn();
          }
        }
      },
      p.diagram.typicalPlantUmlIeOptions({
        diagramName: "surveilr-state",
        ...pso,
      }),
    );
    return await SQLa.polygenCellContent(
      this.emitCtx,
      await servicePumlIE.polygenContent(),
    );
  }

  // TODO: fix compiler errors
  // tblsYAML() {
  //   const { serviceModels, codeNbModels } = this;
  //   return [
  //     {
  //       identity: "surveilr-state.tbls.auto.yml",
  //       emit: tbls.tblsConfig(
  //         function* () {
  //           for (const table of serviceModels.informationSchema.tables) {
  //             yield table;
  //           }
  //         },
  //         tbls.defaultTblsOptions(),
  //         { name: "Resource Surveillance State Schema" },
  //       ),
  //     },
  //     {
  //       identity: "surveilr-code-notebooks.tbls.auto.yml",
  //       emit: tbls.tblsConfig(
  //         function* () {
  //           for (const table of codeNbModels.informationSchema.tables) {
  //             yield table;
  //           }
  //         },
  //         tbls.defaultTblsOptions(),
  //         { name: "Resource Surveillance Notebooks Schema" },
  //       ),
  //     },
  //   ];
  // }

  @cnb.textAssetCell(".rs", "Text Asset (.rs)")
  async "models_polygenix.rs"() {
    const { serviceModels, codeNbModels } = this;
    const pso = p.typicalPolygenInfoModelOptions<SQLa.SqlEmitContext, Any, Any>(
      {
        // emit without housekeeping since rusqlite_serde doesn't support Date/Timestamp
        includeEntityAttr: (ea) =>
          this.exludedHousekeepingCols.find((c) => c == ea.attr.identity)
            ? false
            : true,
      },
    );
    const schemaNB = new p.rust.RustSerDeModels<SQLa.SqlEmitContext, Any, Any>(
      this.emitCtx,
      function* () {
        for (const table of serviceModels.informationSchema.tables) {
          if (SQLa.isGraphEntityDefinitionSupplier(table)) {
            yield table.graphEntityDefn();
          }
        }
        for (const table of codeNbModels.informationSchema.tables) {
          if (SQLa.isGraphEntityDefinitionSupplier(table)) {
            yield table.graphEntityDefn();
          }
        }
      },
      pso,
    );
    return await SQLa.polygenCellContent(
      this.emitCtx,
      await schemaNB.polygenContent(),
    );
  }

  allOsqueryPolicies() {
    const { osQueryPolicy } = this.serviceModels;
    const options = { onConflict: { SQL: () => `ON CONFLICT DO NOTHING` } };

    const policyPassLabel = "Pass";
    const policyFailLabel = "Fail";

    return [
      osQueryPolicy.insertDML({
        osquery_policy_id: this.sqlEngineNewUlid,
        policy_name: "Ad tracking is limited (macOS)",
        osquery_code:
          "SELECT CASE WHEN EXISTS (SELECT 1 FROM managed_policies WHERE domain='com.apple.AdLib' AND name='forceLimitAdTracking' AND value='1' LIMIT 1) THEN 'true' ELSE 'false' END AS policy_result;",
        policy_description:
          "Checks that a mobile device management (MDM) solution configures the Mac to limit advertisement tracking.",
        policy_fail_remarks:
          "Contact your IT administrator to ensure your Mac is receiving a profile that disables advertisement tracking.",
        policy_pass_label: policyPassLabel,
        policy_fail_label: policyFailLabel,
        osquery_platforms: JSON.stringify(["macos"]),
      }, options),
      osQueryPolicy.insertDML({
        osquery_policy_id: this.sqlEngineNewUlid,
        policy_name: "Antivirus healthy (Linux)",
        osquery_code:
          "SELECT score FROM (SELECT CASE WHEN COUNT(*) = 2 THEN 'true' ELSE 'false' END AS score FROM processes WHERE (name = 'clamd') OR (name = 'freshclam')) WHERE score = 'true';",
        policy_description:
          "Checks that both ClamAV's daemon and its updater service (freshclam) are running.",
        policy_fail_remarks:
          "Ensure ClamAV and Freshclam are installed and running.",
        policy_pass_label: policyPassLabel,
        policy_fail_label: policyFailLabel,
        osquery_platforms: JSON.stringify(["linux", "windows", "macos"]),
      }, options),
      osQueryPolicy.insertDML({
        osquery_policy_id: this.sqlEngineNewUlid,
        policy_name: "Antivirus healthy (macOS)",
        osquery_code:
          "SELECT score FROM (SELECT case when COUNT(*) = 2 then 1 ELSE 0 END AS score FROM plist WHERE (key = 'CFBundleShortVersionString' AND path = '/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Info.plist' AND value>=2162) OR (key = 'CFBundleShortVersionString' AND path = '/Library/Apple/System/Library/CoreServices/MRT.app/Contents/Info.plist' and value>=1.93)) WHERE score == 1;",
        policy_description:
          "Checks the version of Malware Removal Tool (MRT) and the built-in macOS AV (Xprotect). Replace version numbers with the latest version regularly.",
        policy_fail_remarks:
          "To enable automatic security definition updates, on the failing device, select System Preferences > Software Update > Advanced > Turn on Install system data files and security updates.",
        policy_pass_label: policyPassLabel,
        policy_fail_label: policyFailLabel,
        osquery_platforms: JSON.stringify(["macos"]),
      }, options),
      osQueryPolicy.insertDML({
        osquery_policy_id: this.sqlEngineNewUlid,
        policy_name: "Antivirus healthy (Windows)",
        osquery_code:
          "SELECT 1 from windows_security_center wsc CROSS JOIN windows_security_products wsp WHERE antivirus = 'Good' AND type = 'Antivirus' AND signatures_up_to_date=1;",
        policy_description:
          "Checks the status of antivirus and signature updates from the Windows Security Center.",
        policy_fail_remarks:
          "Ensure Windows Defender or your third-party antivirus is running, up to date, and visible in the Windows Security Center.",
        policy_pass_label: policyPassLabel,
        policy_fail_label: policyFailLabel,
        osquery_platforms: JSON.stringify(["windows"]),
      }, options),
      osQueryPolicy.insertDML({
        osquery_policy_id: this.sqlEngineNewUlid,
        policy_name:
          "Automatic installation of application updates is enabled (macOS)",
        osquery_code:
          "SELECT 1 FROM managed_policies WHERE domain='com.apple.SoftwareUpdate' AND name='AutomaticallyInstallAppUpdates' AND value=1 LIMIT 1;",
        policy_description:
          "Checks that a mobile device management (MDM) solution configures the Mac to automatically install updates to App Store applications.",
        policy_fail_remarks:
          "Contact your IT administrator to ensure your Mac is receiving a profile that enables automatic installation of application updates.",
        policy_pass_label: policyPassLabel,
        policy_fail_label: policyFailLabel,
        osquery_platforms: JSON.stringify(["macos"]),
      }, options),
      osQueryPolicy.insertDML({
        osquery_policy_id: this.sqlEngineNewUlid,
        policy_name:
          "Automatic installation of operating system updates is enabled (macOS)",
        osquery_code:
          "SELECT 1 FROM managed_policies WHERE domain='com.apple.SoftwareUpdate' AND name='AutomaticallyInstallMacOSUpdates' AND value=1 LIMIT 1;",
        policy_description:
          "Checks that a mobile device management (MDM) solution configures the Mac to automatically install operating system updates.",
        policy_fail_remarks:
          "Contact your IT administrator to ensure your Mac is receiving a profile that enables automatic installation of operating system updates.",
        policy_pass_label: policyPassLabel,
        policy_fail_label: policyFailLabel,
        osquery_platforms: JSON.stringify(["macos"]),
      }, options),
      osQueryPolicy.insertDML({
        osquery_policy_id: this.sqlEngineNewUlid,
        policy_name:
          "Ensure 'Minimum password length' is set to '14 or more characters'",
        osquery_code:
          "SELECT 1 FROM security_profile_info WHERE minimum_password_length >= 14;",
        policy_description:
          "This policy setting determines the least number of characters that make up a password for a user account.",
        policy_fail_remarks: `Automatic method:
Ask your system administrator to establish the recommended configuration via GP, set the following UI path to 14 or more characters
'Computer Configuration\Policies\Windows Settings\Security Settings\Account Policies\Password Policy\Minimum password length'`,
        policy_pass_label: policyPassLabel,
        policy_fail_label: policyFailLabel,
        osquery_platforms: JSON.stringify(["windows"]),
      }, options),
    ];
  }

  @osQueryMsCell(
    {
      description: "All running processes on the host system.",
    },
    ["macos", "windows", "linux"],
    false,
    ["del(.columns.elapsed_time, .columns.system_time, .columns.user_time, .columns.disk_bytes_read, .columns.resident_size)"],
  )
  "All Processes"() {
    return `select * from processes`;
  }

  @osQueryMsCell({
    description: "System information for identification.",
  })
  "System Information"() {
    return `SELECT * FROM system_info`;
  }

  @osQueryMsCell(
    {
      description: "Get the boundary for a node.",
    },
    ["linux", "macos"],
    true,
  )
  "osquery-ms Boundary (Linux and Macos)"() {
    return `SELECT DISTINCT value, key FROM process_envs WHERE key='SURVEILR_OSQUERY_BOUNDARY';`;
  }

  @osQueryMsCell(
    {
      description: "Get the boundary for a node.",
    },
    ["windows"],
    true,
  )
  "osquery-ms Boundary (Windows)"() {
    return `SELECT DISTINCT value, variable FROM default_environment WHERE variable='SURVEILR_OSQUERY_BOUNDARY';`;
  }

  @osQueryMsCell({
    description:
      "A single row containing the operating system name and version.",
  }, ["macos", "linux"])
  "OS Version (Linux and Macos)"() {
    return `SELECT
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
`;
  }

  @osQueryMsCell({
    description:
      "A single row containing the operating system name and version.",
  }, ["windows"])
  "OS Version (Windows)"() {
    return `
    WITH display_version_table AS (
      SELECT data as display_version
      FROM registry
      WHERE path = 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\DisplayVersion'
    ),
    ubr_table AS (
      SELECT data AS ubr
      FROM registry
      WHERE path ='HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\UBR'
    )
    SELECT
      os.name,
      COALESCE(d.display_version, '') AS display_version,
      COALESCE(CONCAT((SELECT version FROM os_version), '.', u.ubr), k.version) AS version
    FROM
      os_version os,
      kernel_info k
    LEFT JOIN
      display_version_table d
    LEFT JOIN
      ubr_table u;
`;
  }

  @osQueryMsCell({
    description:
      "Local user accounts (including domain accounts that have logged on locally (Windows)).",
  })
  "Users"() {
    return `SELECT * FROM users`;
  }

  @osQueryMsCell({
    description:
      "Retrieves information about network interfaces on devices running windows.",
  }, ["windows"])
  "Network Interfaces (Windows)"() {
    return `
      SELECT
          ia.address,
          id.mac
      FROM
          interface_addresses ia
          JOIN interface_details id ON id.interface = ia.interface
          JOIN routes r ON r.interface = ia.address
      WHERE
          (r.destination = '0.0.0.0' OR r.destination = '::') AND r.netmask = 0
          AND r.type = 'remote'
          AND (
          inet_aton(ia.address) IS NOT NULL AND (
            split(ia.address, '.', 0) = '10'
            OR (split(ia.address, '.', 0) = '172' AND (CAST(split(ia.address, '.', 1) AS INTEGER) & 0xf0) = 16)
            OR (split(ia.address, '.', 0) = '192' AND split(ia.address, '.', 1) = '168')
          )
          OR (inet_aton(ia.address) IS NULL AND regex_match(lower(ia.address), '^f[cd][0-9a-f][0-9a-f]:[0-9a-f:]+', 0) IS NOT NULL)
        )
      ORDER BY
          r.metric ASC,
        inet_aton(ia.address) IS NOT NULL DESC
      LIMIT 1;
    `;
  }

  @osQueryMsCell({
    description:
      "Retrieves information about network interfaces on macOS and Linux devices.",
  }, ["macos", "linux"])
  "Network Interfaces (Linux and Macos)"() {
    return `
      SELECT
          ia.address,
          id.mac
      FROM
          interface_addresses ia
          JOIN interface_details id ON id.interface = ia.interface
          JOIN routes r ON r.interface = ia.interface
      WHERE
          (r.destination = '0.0.0.0' OR r.destination = '::') AND r.netmask = 0
          AND r.type = 'gateway'
          AND (
          inet_aton(ia.address) IS NOT NULL AND (
            split(ia.address, '.', 0) = '10'
            OR (split(ia.address, '.', 0) = '172' AND (CAST(split(ia.address, '.', 1) AS INTEGER) & 0xf0) = 16)
            OR (split(ia.address, '.', 0) = '192' AND split(ia.address, '.', 1) = '168')
          )
          OR (inet_aton(ia.address) IS NULL AND regex_match(lower(ia.address), '^f[cd][0-9a-f][0-9a-f]:[0-9a-f:]+', 0) IS NOT NULL)
        )
      ORDER BY
          r.metric ASC,
        inet_aton(ia.address) IS NOT NULL DESC
      LIMIT 1;
    `;
  }

  @osQueryMsCell({
    description: "Processes with listening (bound) network sockets/ports.",
  })
  "Listening Ports"() {
    return `SELECT address, family, net_namespace, path, pid, port, protocol, socket FROM listening_ports`;
  }

  @osQueryMsCell(
    {
      description:
        "Track time passed since last boot. Some systems track this as calendar time, some as runtime.",
    },
    ["linux", "macos", "windows"],
    true,
  )
  "Server Uptime"() {
    return `SELECT * FROM uptime LIMIT 1;`;
  }

  @osQueryMsCell(
    {
      description:
        "Retrieves total amount of free disk space on a Windows host.",
    },
    ["windows"],
    true,
  )
  "Available Disk Space (Windows)"() {
    return `
    SELECT 
      ROUND((sum(free_space) * 100 * 10e-10) / (sum(size) * 10e-10)) AS percent_disk_space_available,
      ROUND(sum(free_space) * 10e-10) AS gigs_disk_space_available,
      ROUND(sum(size)       * 10e-10) AS gigs_total_disk_space
    FROM logical_drives
    WHERE file_system = 'NTFS' LIMIT 1;
`;
  }

  @osQueryMsCell(
    {
      description: "Retrieves total amount of free disk space on a host.",
    },
    ["macos", "linux"],
    true,
  )
  "Available Disk Space (Linux and Macos)"() {
    return `
    SELECT 
      (blocks_available * 100 / blocks) AS percent_disk_space_available,
      round((blocks_available * blocks_size * 10e-10),2) AS gigs_disk_space_available,
      round((blocks           * blocks_size * 10e-10),2) AS gigs_total_disk_space
    FROM mounts
    WHERE path = '/' LIMIT 1;
`;
  }

  @osQueryMsCell({
    description:
      "Get all software installed on a Linux computer, including browser plugins and installed packages. Note that this does not include other running processes in the processes table.",
  }, ["linux"])
  "Installed Linux software"() {
    return `SELECT name AS name, version AS version, 'Package (APT)' AS type, 'apt_sources' AS source FROM apt_sources UNION SELECT name AS name, version AS version, 'Package (deb)' AS type, 'deb_packages' AS source FROM deb_packages UNION SELECT package AS name, version AS version, 'Package (Portage)' AS type, 'portage_packages' AS source FROM portage_packages UNION SELECT name AS name, version AS version, 'Package (RPM)' AS type, 'rpm_packages' AS source FROM rpm_packages UNION SELECT name AS name, '' AS version, 'Package (YUM)' AS type, 'yum_sources' AS source FROM yum_sources UNION SELECT name AS name, version AS version, 'Package (NPM)' AS type, 'npm_packages' AS source FROM npm_packages UNION SELECT name AS name, version AS version, 'Package (Python)' AS type, 'python_packages' AS source FROM python_packages;`;
  }

  @osQueryMsCell({
    description:
      "Get all software installed on a Windows computer, including browser plugins and installed packages. Note that this does not include other running processes in the processes table.",
  }, ["windows"])
  "Installed Windows software"() {
    return `SELECT name AS name, version AS version, 'Program (Windows)' AS type, 'programs' AS source FROM programs UNION SELECT name AS name, version AS version, 'Package (Python)' AS type, 'python_packages' AS source FROM python_packages UNION SELECT name AS name, version AS version, 'Browser plugin (IE)' AS type, 'ie_extensions' AS source FROM ie_extensions UNION SELECT name AS name, version AS version, 'Browser plugin (Chrome)' AS type, 'chrome_extensions' AS source FROM chrome_extensions UNION SELECT name AS name, version AS version, 'Browser plugin (Firefox)' AS type, 'firefox_addons' AS source FROM firefox_addons UNION SELECT name AS name, version AS version, 'Package (Chocolatey)' AS type, 'chocolatey_packages' AS source FROM chocolatey_packages;`;
  }

  @osQueryMsCell({
    description:
      "Get all software installed on a Macos computer, including browser plugins and installed packages. Note that this does not include other running processes in the processes table.",
  }, ["macos"])
  "Installed Macos software"() {
    return `SELECT name AS name, bundle_short_version AS version, 'Application (macOS)' AS type, 'apps' AS source FROM apps UNION SELECT name AS name, version AS version, 'Package (Python)' AS type, 'python_packages' AS source FROM python_packages UNION SELECT name AS name, version AS version, 'Browser plugin (Chrome)' AS type, 'chrome_extensions' AS source FROM chrome_extensions UNION SELECT name AS name, version AS version, 'Browser plugin (Firefox)' AS type, 'firefox_addons' AS source FROM firefox_addons UNION SELECT name As name, version AS version, 'Browser plugin (Safari)' AS type, 'safari_extensions' AS source FROM safari_extensions UNION SELECT name AS name, version AS version, 'Package (Homebrew)' AS type, 'homebrew_packages' AS source FROM homebrew_packages;`;
  }

  @osQueryMsPolicyCell({
    targets: ["macos", "windows", "linux"],
    required_note: "osQuery must have Full Disk Access.",
    resolution:
      "Use this command to encrypt existing SSH keys by providing the path to the file: ssh-keygen -o -p -f /path/to/file",
    critical: false,
    description:
      "Policy passes if all keys are encrypted, including if no keys are present.",
  })
  "SSH keys encrypted"() {
    return `SELECT 
  CASE 
    WHEN NOT EXISTS (
      SELECT 1
      FROM users
      CROSS JOIN user_ssh_keys USING (uid)
      WHERE encrypted = '0'
    ) THEN 'true' 
    ELSE 'false' 
  END AS policy_result;
`;
  }

  @osQueryMsPolicyCell({
    targets: ["linux"],
    required_note:
      "Checks if the root drive is encrypted. There are many ways to encrypt Linux systems. This is the default on distributions such as Ubuntu.",
    resolution:
      "Ensure the image deployed to your Linux workstation includes full disk encryption.",
    critical: false,
    description: "Checks if the root drive is encrypted.",
  })
  "Full disk encryption enabled (Linux)"() {
    return `SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM mounts m
      JOIN disk_encryption d ON m.device_alias = d.name
      WHERE d.encrypted = 1 AND m.path = '/'
    ) THEN 'true'
    ELSE 'false'
  END AS policy_result;
`;
  }

  @osQueryMsPolicyCell({
    targets: ["windows"],
    required_note:
      "Checks to make sure that full disk encryption is enabled on Windows devices.",
    resolution:
      "To get additional information, run the following osquery query on the failing device: SELECT * FROM bitlocker_info. In the query results, if protection_status is 2, then the status cannot be determined. If it is 0, it is considered unprotected. Use the additional results (percent_encrypted, conversion_status, etc.) to help narrow down the specific reason why Windows considers the volume unprotected.",
    critical: false,
    description: "Checks if the root drive is encrypted.",
  })
  "Full disk encryption enabled (Windows)"() {
    return `SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM bitlocker_info 
      WHERE drive_letter = 'C:' AND protection_status = 1
    ) THEN 'true'
    ELSE 'false'
  END AS policy_result;
`;
  }

  @osQueryMsPolicyCell({
    targets: ["macos"],
    required_note:
      "Checks to make sure that full disk encryption (FileVault) is enabled on macOS devices.",
    resolution:
      "To enable full disk encryption, on the failing device, select System Preferences > Security & Privacy > FileVault > Turn On FileVault.",
    critical: false,
    description: "Checks if the root drive is encrypted.",
  })
  "Full disk encryption enabled (Macos)"() {
    return `SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM disk_encryption 
      WHERE user_uuid IS NOT '' AND filevault_status = 'on'
      LIMIT 1
    ) THEN 'true'
    ELSE 'false'
  END AS policy_result;
`;
  }

  @osQueryMsFilterCell({
    description:
      "Default filters for post-processing the results from osQuery.",
  })
  "osQuery Result Filters"() {
    return osQueryMsCellGovernance;
  }
}

export async function SQL() {
  return [
    ...await RssdInitSqlNotebook.SQL(new RssdInitSqlNotebook()),
    ...await stdPackage.SQL(),
  ];
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
