#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import * as nb from "./notebook/rssd.ts";
import * as cnb from "./notebook/code.ts";
import { lifecycle as lcm } from "./models/mod.ts";
import { polygen as p, SQLa } from "./deps.ts";
import * as stdPackage from "./package.sql.ts";

// deno-lint-ignore no-explicit-any
type Any = any;

const surveilrSpecialMigrationNotebookName = "ConstructionSqlNotebook" as const;

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

      ${this.uniformResourceGraphViews()}

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
    `
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
      ];
    };

    // deno-fmt-ignore
    return this.SQL`
      ${urIngestPathMatchRules()}

      ${urIngestPathRewriteRules()}

      ${partyTypeRules()}

      ${orchestrationNatureRules()}

      ${uniformResourceGraphRules}
      `;
  }

  // @migratableCell({
  //   description:
  //     "Creates a simple graph infrastructure so that uniform_resource content can be tracked as graphs in addition to relationally.",
  // })
  // v002_uniform_resource_graphs() {
  //   return this.SQL`
  //     CREATE TABLE IF NOT EXISTS uniform_resource_graph (
  //         name TEXT PRIMARY KEY
  //     );

  //     CREATE TABLE IF NOT EXISTS uniform_resource_edge (
  //         graph_name TEXT PRIMARY KEY,
  //         nature TEXT,
  //         node_id TEXT,
  //         uniform_resource_id TEXT,
  //         elaboration TEXT,
  //         UNIQUE(graph_name, nature, node_id, uniform_resource_id) ON CONFLICT REPLACE,
  //         FOREIGN KEY(graph_name) REFERENCES uniform_resource_graph(name),
  //         FOREIGN KEY(uniform_resource_id) REFERENCES uniform_resource(uniform_resource_id)
  //     );

  //     CREATE INDEX IF NOT EXISTS target_idx ON uniform_resource_edge(uniform_resource_id);

  //     INSERT OR IGNORE INTO uniform_resource_graph (name) VALUES('filesystem');
  //     INSERT OR IGNORE INTO uniform_resource_graph (name) VALUES('imap');
  //     INSERT OR IGNORE INTO uniform_resource_graph (name) VALUES('plm');
  //     `;
  // }

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
