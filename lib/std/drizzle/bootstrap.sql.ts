// This script is a **minimal demonstration** of how to use Drizzle ORM
// in an **SQL-first** and **typesafe** way, similar to tools like SQL Aide.
//
// The key idea here is that Drizzle can act as a **SQL generator** rather than
// immediately executing queries against a SQLite database. By defining tables,
// indexes, relationships, and constraints in TypeScript, you get full type
// safety while still working directly with SQL under the hood.
//
// This script shows how to:
//   • Define tables and relationships using Drizzle's SQLite core API
//   • Generate SQL queries safely using Drizzle's `QueryBuilder`
//   • Produce database migration SQL from schema differences using `drizzle-kit`
//   • Use Drizzle to prepare `.toSQL()` statements without actually executing them
//
// This is especially useful when you want to:
//   • Design your schema and generate migrations before connecting to a live DB
//   • Inspect SQL queries for logging, debugging, or code review purposes
//   • Use Drizzle as a **type-safe SQL generator** and defer execution until later
//
// Note: As of 08-23-2025, there’s a temporary workaround needed before using
// `drizzle-kit/api` with Deno 2.4+:
//    1. Run once: `deno install` (this will cache what's in `deno.json`)
//    2. Then run: `deno run -A --node-modules-dir ./drizzle-to-sql.ts`
//
// See these discussions for more details:
//    • https://github.com/drizzle-team/drizzle-orm/discussions/3162
//    • https://github.com/drizzle-team/drizzle-orm/discussions/1901
//
// TL;DR: This script focuses on **learning Drizzle's typesafe query
// generation** and **migration tooling** without requiring a persistent database.

import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const {
  generateSQLiteDrizzleJson: generateDrizzleJson,
  generateSQLiteMigration: generateMigration,
} = require(
  "drizzle-kit/api",
) as typeof import("npm:drizzle-kit/api");
import * as schema from "./models.ts";
import * as views from "./views.ts";
import { SQL, inlinedSQL } from "../../universal/sql-text.ts";

// ✓ RESOLVED: Foreign key relations are properly emitted in migrations
// Foreign keys are generated via:
//   1. .references(() => parentTable.column) in table definitions
//   2. relations() function provides TypeScript type safety and query building
//   3. drizzle-kit generates the FOREIGN KEY constraints in SQL DDL

const previousSchema = {};
const currentSchema = { ...schema, ...views };

const migrationStatements = await generateMigration(
  await generateDrizzleJson(previousSchema),
  await generateDrizzleJson(currentSchema),
);

// Generate the complete bootstrap SQL using Drizzle notebook system
// Sort tables by dependency order to avoid foreign key constraint failures
function sortTablesByDependency(statements: string[]): string[] {
  const tableStatements = new Map<string, string>();
  const indexStatements: string[] = [];
  const viewStatements: string[] = [];
  const insertStatements: string[] = [];
  const dependencies = new Map<string, Set<string>>();

  // Regexes to catch both "quoted" and `backticked` table names
  const createTableRegex =
    /CREATE TABLE(?: IF NOT EXISTS)? ["`]?([^"`\s]+)["`]?/i;
  const fkRegex =
    /FOREIGN KEY\s*\([^)]+\)\s*REFERENCES\s+["`]?([^"`\s]+)["`]?/gi;

  // Parse statements and extract dependencies
  statements.forEach((stmt) => {
    const normalized = stmt.trim();

    if (/^CREATE TABLE/i.test(normalized)) {
      const tableNameMatch = normalized.match(createTableRegex);
      if (tableNameMatch) {
        const tableName = tableNameMatch[1];
        tableStatements.set(tableName, normalized);

        // Extract foreign key dependencies
        const deps = new Set<string>();
        const foreignKeyMatches = normalized.matchAll(fkRegex);
        for (const match of foreignKeyMatches) {
          deps.add(match[1]);
        }
        dependencies.set(tableName, deps);
      }
    } else if (
      /^CREATE (?:UNIQUE )?INDEX/i.test(normalized) ||
      /^CREATE INDEX/i.test(normalized)
    ) {
      indexStatements.push(normalized);
    } else if (/^CREATE VIEW/i.test(normalized) || /^DROP VIEW/i.test(normalized)) {
      viewStatements.push(normalized);
    } else if (/^INSERT INTO/i.test(normalized)) {
      insertStatements.push(normalized);
    }
  });

  // Topological sort for tables
  const sorted: string[] = [];
  const visited = new Set<string>();
  const visiting = new Set<string>();

  function visit(tableName: string) {
    if (visiting.has(tableName)) {
      // Circular dependency - just bail for now, we'll handle later
      return;
    }
    if (visited.has(tableName)) {
      return;
    }

    visiting.add(tableName);
    const deps = dependencies.get(tableName) || new Set();

    for (const dep of deps) {
      if (tableStatements.has(dep)) {
        visit(dep);
      }
    }

    visiting.delete(tableName);
    visited.add(tableName);

    const statement = tableStatements.get(tableName);
    if (statement) {
      sorted.push(statement);
    }
  }

  // Visit all tables
  for (const tableName of tableStatements.keys()) {
    visit(tableName);
  }

  // Add any remaining tables that weren't processed (circular deps, etc.)
  for (const [tableName, statement] of tableStatements) {
    if (!visited.has(tableName)) {
      sorted.push(statement);
    }
  }

  // Add indexes after all tables
  sorted.push(...indexStatements);

  // Add views after tables and indexes
  sorted.push(...viewStatements);

  // Add inserts last (after tables + indexes + views exist)
  sorted.push(...insertStatements);

  return sorted;
}

// Note: Schema generation, views, and all other SQL is now handled inside bootstrapDDL()
// to match the working version's pattern where everything is wrapped in one method

const sortedStatements = sortTablesByDependency(migrationStatements);

const drizzleSchemaSQL = sortedStatements
  .map(stmt => stmt.replace(/^CREATE TABLE `/gm, 'CREATE TABLE IF NOT EXISTS `'))
  .map(stmt => stmt.replace(/^CREATE INDEX `/gm, 'CREATE INDEX IF NOT EXISTS `'))
  .map(stmt => stmt.replace(/^CREATE UNIQUE INDEX `/gm, 'CREATE UNIQUE INDEX IF NOT EXISTS `'))
  .map(stmt => stmt.replace(/^CREATE VIEW `/gm, 'CREATE VIEW IF NOT EXISTS `'))
  .join("\n");

// Generate view DDL from views.ts - Simple approach using known view names
// Since the Drizzle view objects are complex, we'll include them through migrations
const viewsGeneratedSQL = `-- Views from ../../universal/views.ts will be created by Drizzle migrations
-- This ensures proper type safety and schema consistency
-- Views include: uniform_resource_file, orchestration_session_by_device, console_information_schema_table, etc.
-- Views are automatically generated when the schema is applied`;

// Import notebook class from drizzle-lifecycle.ts
const { DrizzleRssdInitNotebook } = await import("../drizzle-lifecycle.ts");

// Create notebook instance and call bootstrapDDL directly
const drizzleNotebook = new DrizzleRssdInitNotebook();
const bootstrapDDL = await drizzleNotebook.bootstrapDDL();

// Generate web UI content using Drizzle-based package system
const { SQL: drizzlePackageSQL } = await import("../drizzle-package.ts");
const webUISQL = await drizzlePackageSQL();

// Combine everything into final bootstrap
const finalBootstrap = `-- Bootstrap SQL generated from Drizzle schema and notebook system
-- Generated at: ${new Date().toISOString()}

-- Drizzle schema DDL (tables, indexes, constraints)
${drizzleSchemaSQL}

-- Views generated from ../../universal/views.ts using Drizzle query builder
${viewsGeneratedSQL}

-- ALL migration content (sessions, seeds, web UI, etc.) from bootstrapDDL()
${bootstrapDDL}

-- Web UI content (SQLPage files and navigation) generated by Drizzle decorators
${webUISQL.join(';\n\n')}`;

console.log(finalBootstrap);
