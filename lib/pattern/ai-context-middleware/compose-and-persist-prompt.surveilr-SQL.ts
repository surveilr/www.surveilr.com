#!/usr/bin/env -S deno run --allow-read --allow-env

/**
 * This script connects to the surveilr SQLite database and processes all unique merge groups from the ai_ctxe_prompt view.
 * For each merge group:
 *   - Gathers and merges prompt files, combining their YAML frontmatter and body.
 *   - Validates the frontmatter against a schema (if available) and logs any validation errors.
 *   - Resolves dependencies and adds them to the frontmatter.
 *   - Emits idempotent SQL INSERT statements to create or update uniform_resource_transform records for each composed system prompt, only if they don't already exist.
 *   - If errors occur (validation or parsing), emits error log SQL for tracking.
 *   - Outputs all generated SQL statements to stdout, wrapped in a single transaction (BEGIN; ... COMMIT;), and logs warnings/errors to stderr only.
 *
 * In summary:
 *   - It generates SQL to insert composed, validated, and dependency-annotated system prompts (one per merge group) into the surveilr database, ready for ingestion, and emits error logs as SQL if issues are found.
 *   - Only SQL is printed to stdout; all logs and warnings go to stderr.
 */


// CE: Emits SQL to stdout. Surveilr captures + executes it.
// Logs/warnings go to stderr ONLY.

import { DB } from "https://deno.land/x/sqlite/mod.ts";
import { crypto } from "jsr:@std/crypto";
import { join } from "https://deno.land/std@0.224.0/path/mod.ts";
import { load } from "jsr:@std/dotenv";
import { parse as parseYaml, stringify as stringifyYaml } from "https://deno.land/std@0.224.0/yaml/mod.ts";
import { z } from "jsr:@zod/zod";
import { frontmatterSchemas } from "./config/frontmatterSchema.ts";
import { v4 as uuidv4 } from "https://deno.land/std@0.224.0/uuid/mod.ts";

const errorSQLs: string[] = []; // At the top of your main function or module

// ---------------- Utils ----------------
await load({ export: true });

function errlog(...args: unknown[]) {
  // ensure no contamination of stdout (which must be pure SQL)
  console.error(...args);
}

function getAllMergeGroups(db: DB): string[] {
  const query = `
    SELECT DISTINCT merge_group
    FROM ai_ctxe_prompt
    WHERE merge_group IS NOT NULL
      AND merge_group != ''
      AND LOWER(merge_group) != 'common'
    ORDER BY merge_group;
  `;
  const results = db.query<[string]>(query);
  return results.map((row) => row[0]);
}

function toHex(bytes: Uint8Array): string {
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function splitFrontmatter(content: string): { frontmatter: string | null; body: string } {
  const match = content.match(/^---\s*([\s\S]*?)\s*---\s*([\s\S]*)$/);
  if (match) return { frontmatter: match[1], body: match[2].trim() };
  return { frontmatter: null, body: content.trim() };
}

// escape for single-quoted SQLite string literals
function sqlQuote(s: string): string {
  return `'${s.replaceAll("'", "''")}'`;
}

function emitErrorSQL(
  uniformResourceId: string | null,
  mergeGroup: string,
  errorType: string,
  errorDetails: unknown
): string {
  const transformId = uuidv4.generate();
  const uri = `ai-context-engineering/.build/errors/${mergeGroup}-error.json`;
  const elaboration = JSON.stringify({ errorType, details: errorDetails });
  return `
INSERT INTO uniform_resource_transform (
  uniform_resource_transform_id, uniform_resource_id, uri,
  content_digest, content, nature, size_bytes, created_by, elaboration
)
VALUES (
  '${transformId}',
  ${uniformResourceId ? `'${uniformResourceId}'` : "NULL"},
  '${uri}',
  NULL,
  NULL,
  'error_log',
  0,
  'compose-persist-ce',
  '${elaboration.replace(/'/g, "''")}'
);`.trim();
}

async function composeForMergeGroup(
  db: DB,
  mergeGroup: string,
): Promise<{
  sourceId: string | null;
  composedText: string | null;
  elaboration: Record<string, unknown>;
}> {
  const elaboration: { warnings: string[]; validation: Record<string, unknown> } = {
    warnings: [],
    validation: {},
  };

  const rows = db.query<[string, string]>(
    `SELECT body_text, uniform_resource_id
       FROM ai_ctxe_prompt
       WHERE merge_group = ?
       ORDER BY ord ASC;`,
    [mergeGroup],
  );

  const composedBodyParts: string[] = [];
  const dependencyIds = new Set<string>();
  let modifiedFrontmatterBlock = "";
  let frontmatterInjected = false;

  for (const [bodyText, uri] of rows) {
    const { frontmatter, body } = splitFrontmatter(bodyText);
    if (uri) dependencyIds.add(uri);

    if (!frontmatterInjected && frontmatter) {
      try {
        let parsed: unknown = parseYaml(frontmatter);

        // const schema = (frontmatterSchemas as Record<string, z.ZodType>)[mergeGroup];
        const schema = (frontmatterSchemas as unknown as Record<string, z.ZodType>)[mergeGroup];
        if (schema) {
          const res = schema.safeParse(parsed);
          if (res.success) {
            elaboration.validation = { status: "success" };
            parsed = res.data;
          } else {
            errlog(`Frontmatter validation failed for '${mergeGroup}':`);
            // Iterate through the Zod issues array
            const errorDetails = res.error.issues.map((error) => {
              const path = error.path.join("."); // Path to the field with the error
              const message = error.message; // Error message
              const code = error.code; // Zod error code
              errlog(`  Field '${path}': ${message} (Code: ${code})`);
              return {
                path: path,
                message: message,
                code: code,
              };
            });
            elaboration.validation = {
              status: "failure",
              errors: errorDetails,
            };

            // Compose a detailed error message for the elaboration column
            const errorContext = {
              mergeGroup,
              schema: schema.toString(),
              errorCount: res.error.issues.length,
              errorSummary: res.error.issues.map((e) => `Field '${e.path.join('.')}' - ${e.message} (Code: ${e.code})`).join('; '),
              issues: res.error.issues,
              receivedFrontmatter: parsed,
              timestamp: new Date().toISOString(),
            };
            const errorSQL = emitErrorSQL(
              uri,
              mergeGroup,
              "zod_validation",
              errorContext,
            );
            errorSQLs.push(errorSQL);
          }
        } else {
          const msg = `No frontmatter schema defined for merge group '${mergeGroup}'`;
          elaboration.warnings.push(msg);
          // errlog(`${msg}`);
        }

        if (typeof parsed !== "object" || parsed === null) throw new Error("Parsed frontmatter is not an object.");
        const parsedObj = parsed as Record<string, any>;
        if (!parsedObj.provenance) parsedObj.provenance = {};

        // OPTIMIZATION: Resolve all dependency paths in a single query.
        const resolvedDependencies: string[] = [];
        if (dependencyIds.size > 0) {
          const placeholders = Array.from(dependencyIds).map(() => "?").join(", ");
          const q = `
            SELECT substr(uri, instr(uri, 'opsfolio.com/') + length('opsfolio.com/')) AS file_path_rel
            FROM uniform_resource WHERE uniform_resource_id IN (${placeholders})`;
          const results = db.query<[string]>(q, [...dependencyIds]);
          results.forEach((row) => resolvedDependencies.push(row[0]));

          if (results.length !== dependencyIds.size) {
            const msg = `Could not resolve all file paths. Found ${results.length} of ${dependencyIds.size}.`;
            elaboration.warnings.push(msg);
            errlog(`⚠️ ${msg}`);
          }
        }
        parsedObj.provenance.dependencies = resolvedDependencies.sort();

        modifiedFrontmatterBlock = `---\n${stringifyYaml(parsedObj).trim()}\n---`;
        composedBodyParts.push(modifiedFrontmatterBlock);
        composedBodyParts.push(body);
        frontmatterInjected = true;
      } catch (e) {
        const msg = `Error parsing frontmatter: ${e instanceof Error ? e.message : String(e)}`;
        elaboration.warnings.push(msg);
        errlog(`${msg}`);
        composedBodyParts.push(bodyText.trim());

        const errorSQL = emitErrorSQL(
          uri,
          mergeGroup,
          "exception",
          { message: e instanceof Error ? e.message : String(e) },
        );
        errorSQLs.push(errorSQL);
      }
    } else {
      composedBodyParts.push(body);
    }
  }

  const composedText = composedBodyParts.join("\n\n").trim();
  if (!composedText) {
    errlog(`[SKIP] Merge group '${mergeGroup}': composedText is empty.`);
    return { sourceId: null, composedText: null, elaboration };
  }

  // representative sourceId
  const srcRow = db.query<[string]>(
    `SELECT uniform_resource_id
       FROM ai_ctxe_prompt
       WHERE merge_group = ?
       ORDER BY ord ASC
       LIMIT 1;`,
    [mergeGroup],
  )?.[0];

  const sourceId = srcRow?.[0] ?? null;
  if (!sourceId) {
    errlog(`[SKIP] Merge group '${mergeGroup}': No sourceId found.`);
    return { sourceId: null, composedText: null, elaboration };
  }

  return { sourceId, composedText, elaboration };
}

async function processAllMergeGroups(): Promise<void> {
  const databasePath = Deno.args[0];
  if (!databasePath) {
    errlog("Database path must be provided as the first CLI argument, e.g. deno run -A compose-and-persist-prompt.surveilr-SQL.ts resource-surveillance.sqlite.db");
    Deno.exit(1);
  }

  let db: DB | null = null;
  try {
    db = new DB(databasePath, { mode: "read" });
    const mergeGroups = getAllMergeGroups(db);

    if (mergeGroups.length === 0) {
      errlog("No merge groups found.");
      return;
    }

    const sqlChunks: string[] = [];
    for (const mergeGroup of mergeGroups) {
      // errlog(`Processing merge group: '${mergeGroup}'`);
      // Pass the existing DB connection instead of the path
      const res = await composeForMergeGroup(db, mergeGroup);
      if (!res.sourceId || !res.composedText) continue;

      // compute digest
      const data = new TextEncoder().encode(res.composedText);
      const buf = crypto.subtle.digestSync
        ? crypto.subtle.digestSync("SHA-256", data)
        : await crypto.subtle.digest("SHA-256", data);
      const digest = toHex(new Uint8Array(buf));

      const transformId = crypto.randomUUID();
      const outputUri = join("ai-context-engineering/.build/anythingllm/core", `${mergeGroup}.system-prompt.md`);

      // Emit idempotent INSERT as SQL text
      // NOTE: Only SQL goes to STDOUT; Surveilr captures and executes this.
      const sql = `
-- CE output for merge group ${sqlQuote(mergeGroup)}
INSERT INTO uniform_resource_transform (
  uniform_resource_transform_id, uniform_resource_id, uri,
  content_digest, content, nature, size_bytes, created_by, elaboration
)
SELECT
  ${sqlQuote(transformId)},
  ${sqlQuote(res.sourceId)},
  ${sqlQuote(outputUri)},
  ${sqlQuote(digest)},
  ${sqlQuote(res.composedText)},
  'system_prompt',
  ${res.composedText.length},
  'surveilr-sql-deno-client',
  ${sqlQuote(JSON.stringify(res.elaboration))}
WHERE NOT EXISTS (
  SELECT 1 FROM uniform_resource_transform WHERE uri = ${sqlQuote(outputUri)}
);`.trim();

      sqlChunks.push(sql);
    }

    // Wrap in a single transaction for atomicity (Surveilr will execute)
    if (sqlChunks.length > 0) {
      const finalSQL = ["BEGIN;", ...sqlChunks.map(s => s + ";"), "COMMIT;"].join("\n");
      // IMPORTANT: print SQL ONLY to stdout
      console.log(finalSQL);
    } else {
      errlog("Nothing to emit.");
    }
  } catch (e) {
    errlog("Error processing merge groups:", e);
    // emit no SQL on error
  } finally {
    db?.close();
  }

  if (errorSQLs.length > 0) {
    const finalSQL = ["BEGIN;", ...errorSQLs.map(s => s + ";"), "COMMIT;"].join("\n");
    console.log(finalSQL);
  }
}

// --- Run ---
await processAllMergeGroups();
