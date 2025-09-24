#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys

/**
 * Drizzle-based Docs SQLPages
 * 
 * Recreates the docs web UI content using Drizzle decorators instead of SQLa
 */

import { DrizzleSqlPageNotebook, navigationPrimeDrizzle } from "../notebook-drizzle/drizzle-sqlpage.ts";
import { inlinedSQL, SQL } from "../../universal/sql-text.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";

function docsNavDrizzle(route: { caption: string; description: string; siblingOrder?: number }) {
  return navigationPrimeDrizzle({
    ...route,
    parentPath: "docs/index.sql",
  });
}

export class DrizzleDocsSqlPages extends DrizzleSqlPageNotebook {
  constructor() {
    super("docs");
  }

  @navigationPrimeDrizzle({
    caption: "Docs",
    description: "Explore surveilr functions and release notes",
    siblingOrder: 1,
  })
  "docs/index.sql"() {
    return inlinedSQL(SQL`WITH navigation_cte AS (
      SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
      WHERE namespace = 'prime' AND path = '/docs/index.sql'
    )
    SELECT 'list' AS component, title, description
    FROM navigation_cte;
    
    SELECT caption as title, '/' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
    WHERE namespace = 'prime' AND parent_path = '/docs/index.sql'
    ORDER BY sibling_order;`);
  }

  @docsNavDrizzle({
    caption: "Release Notes",
    description: "surveilr releases details",
    siblingOrder: 99,
  })
  async "docs/release-notes.sql"() {
    const sqlSnippets: string[] = [];
    const resolvedUrl = import.meta.resolve(`../docs/release`);
    
    // Handle both local file URLs and remote HTTP URLs
    if (resolvedUrl.startsWith('file://')) {
      const directory = path.fromFileUrl(resolvedUrl);

      const entries: Deno.DirEntry[] = [];
      try {
        for await (const entry of Deno.readDir(directory)) {
          if (entry.isFile && entry.name.endsWith(".md")) {
            entries.push(entry);
          }
        }

        const sortedEntries = entries.sort((a, b) => {
          const versionA = a.name.replace(".md", "").split(".").map(Number);
          const versionB = b.name.replace(".md", "").split(".").map(Number);

          for (let i = 0; i < Math.max(versionA.length, versionB.length); i++) {
            const numA = versionA[i] || 0;
            const numB = versionB[i] || 0;
            if (numA !== numB) {
              return numB - numA;
            }
          }
          return 0;
        });

        for (const entry of sortedEntries) {
          const title = entry.name.replace(".md", "");
          const content = await this.fetchTextForSqlLiteral(
            import.meta.resolve(`../docs/release/${entry.name}`),
          );
          const sqlSnippet = `
            SELECT 'foldable' as component;
            SELECT '${title}' as title, '${content}' as description_md;
          `;
          sqlSnippets.push(sqlSnippet);
        }
      } catch (error) {
        // Directory doesn't exist or can't be read
        const sqlSnippet = `
          SELECT 'alert' as component;
          SELECT 'Release notes directory not found' as description;
        `;
        sqlSnippets.push(sqlSnippet);
      }
    } else {
      // When running from remote URL, we can't read directory contents
      const sqlSnippet = `
        SELECT 'alert' as component;
        SELECT 'Release notes not available when running from remote URL' as description;
      `;
      sqlSnippets.push(sqlSnippet);
    }

    return inlinedSQL(SQL`SELECT 'title' AS component, 'Release Notes for surveilr Versions' as contents;
    ${sqlSnippets.join("\n")}`);
  }

  @docsNavDrizzle({
    caption: "SQL Functions",
    description: "surveilr specific SQLite functions for extensibilty",
    siblingOrder: 2,
  })
  "docs/functions.sql"() {
    return inlinedSQL(SQL`-- To display title
    SELECT 'text' AS component, 'Surveilr SQLite Functions' AS title;

    SELECT 'text' AS component,
      'Below is a comprehensive list and description of all Surveilr SQLite functions. Each function includes details about its parameters, return type, and version introduced.'
      AS contents_md;

    SELECT 'list' AS component, 'Surveilr Functions' AS title;

    SELECT name AS title,
      NULL AS icon,
      'functions-inner.sql?function=' || name || '#function' AS link,
      $function = name AS active
    FROM surveilr_function_doc
    ORDER BY name;`);
  }

  "docs/functions-inner.sql"() {
    return inlinedSQL(SQL`select 'breadcrumb' as component;
    select 'Home' as title, '/' as link;
    select 'Docs' as title, '/docs/index.sql' as link;
    select 'SQL Functions' as title, '/docs/functions.sql' as link;
    select $function as title, '/docs/functions-inner.sql?function=' || $function AS link;

    SELECT 'text' AS component,
      '' || name || '()' AS title, 'function' AS id
    FROM surveilr_function_doc WHERE name = $function;

    SELECT 'text' AS component,
      description AS contents_md
    FROM surveilr_function_doc WHERE name = $function;

    SELECT 'text' AS component,
      'Introduced in version ' || version || '.' AS contents
    FROM surveilr_function_doc WHERE name = $function;

    SELECT 'title' AS component,
      3 AS level,
      'Parameters' AS contents
    WHERE $function IS NOT NULL;

    SELECT 'card' AS component,
      3 AS columns
      WHERE $function IS NOT NULL;
    SELECT
      json_each.value ->> '$.name' AS title,
      json_each.value ->> '$.description' AS description,
      json_each.value ->> '$.data_type' AS footer,
      'azure' AS color
    FROM surveilr_function_doc, json_each(surveilr_function_doc.parameters)
    WHERE name = $function;

    -- Navigation Buttons
    SELECT 'button' AS component, 'sm' AS size, 'pill' AS shape;
    SELECT name AS title,
      NULL AS icon,
      sqlpage.link('functions-inner.sql', json_object('function', name)) AS link
    FROM surveilr_function_doc
    ORDER BY name;`);
  }

  // Utility method to fetch text content for SQL literals
  private async fetchTextForSqlLiteral(url: string): Promise<string> {
    try {
      if (url.startsWith('file://')) {
        const content = await Deno.readTextFile(path.fromFileUrl(url));
        // Escape single quotes for SQL and limit content length
        return content.replace(/'/g, "''").substring(0, 5000);
      } else {
        const response = await fetch(url);
        const content = await response.text();
        return content.replace(/'/g, "''").substring(0, 5000);
      }
    } catch (error) {
      return "Content could not be loaded";
    }
  }
}