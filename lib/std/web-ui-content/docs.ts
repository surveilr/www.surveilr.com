import * as spn from "../notebook/sqlpage.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";

export function docsNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "/docs",
  });
}

export class DocsSqlPages extends spn.TypicalSqlPageNotebook {
  navigationDML() {
    return this.SQL`
            ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
          `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Docs",
    description: "Explore surveilr functions and release notes",
  })
  "docs/index.sql"() {
    return this.SQL`
                WITH navigation_cte AS (
                SELECT COALESCE(title, caption) as title, description
                    FROM sqlpage_aide_navigation
                WHERE namespace = 'prime' AND path = '/docs'
                )
                SELECT 'list' AS component, title, description
                    FROM navigation_cte;
                SELECT caption as title, COALESCE(url, path) as link, description
                    FROM sqlpage_aide_navigation
                WHERE namespace = 'prime' AND parent_path = '/docs'
                ORDER BY sibling_order;
            `;
  }

  @docsNav({
    caption: "Release Notes",
    description: "surveilr releases details",
    siblingOrder: 99,
  })
  async "docs/release-notes.sql"() {
    const sqlSnippets: string[] = [];
    const directory = path.fromFileUrl(import.meta.resolve(`../docs/release`));

    for await (const entry of Deno.readDir(directory)) {
      if (entry.isFile && entry.name.endsWith(".md")) {
        const title = entry.name.replace(".md", "");
        const content = await this.fetchTextForSqlLiteral(
          import.meta.resolve(`${directory}/${entry.name}`),
        );
        const sqlSnippet = `
                    SELECT 'foldable' as component;
                    SELECT '${title}' as title, '${content}' as description_md;
                `;

        sqlSnippets.push(sqlSnippet);
      }
    }

    return this.SQL`
            SELECT 'title' AS component, 'Release Notes for surveilr Versions' as contents;
            ${sqlSnippets.join("\n")}
        `;
  }

  @docsNav({
    caption: "SQL Functions",
    description: "surveilr specific SQLite functions for extensibilty",
    siblingOrder: 99,
  })
  async "docs/sql-functions.sql"() {
    const sqlSnippets: string[] = [];
    const directory = path.fromFileUrl(
      import.meta.resolve(`../docs/sql-functions`),
    );
    for await (const entry of Deno.readDir(directory)) {
      if (entry.isFile && entry.name.endsWith(".md")) {
        const function_entry = entry.name.replace(".md", "").split("-");
        const title = function_entry[0];
        const version = function_entry[1];

        const content = await this.fetchTextForSqlLiteral(
          import.meta.resolve(`${directory}/${entry.name}`),
        );
        const sqlSnippet = `
                    SELECT 
                        '${title}'  as title,
                        '${content}' as description_md,
                        'green'  as color,
                        '${version}' as footer_md;
                `;

        sqlSnippets.push(sqlSnippet);
      }
    }

    return this.SQL`
            SELECT 'title' as component, 'surveilr SQLite Functions' as contents;
            SELECT 'text' as component, 
            'Below is a comprehensive list and description of all \`\`surveilr\`\` SQLite functions exposed during any execution. This document details each function, it''s
            parameters/arguments and the return type if any. Also included is the version number of when it was introduced in \`\`surveilr\`\`.
            Usage examples for most of these functions can be found in the [assurance](https://github.com/surveilr/www.surveilr.com/tree/main/lib/assurance) section of the \`\`surveilr\`\` repository.
            ' as contents_md;
            SELECT 'card' as component, 2 as columns;
            ${sqlSnippets.join("\n")}
        `;
  }

  //   @docsNav({
  //     caption: "More about surveilr",
  //     description: "Current surveilr and major internal dependencies versions",
  //     siblingOrder: 99,
  //   })
  //   "docs/about.sql"() {
  //     return this.SQL`
  //         SELECT 'title' as component, 'surveilr Details' as contents;
  //         SELECT 'text' as component, 'Learn about the versions of \`\`surveilr\`\`, the major internal dependencies that power \`\`surveilr\`\`,
  //         \`\`rusqlite\`\` for powering SQL execution, \`\`sqlpage\`\` which powers this Web UI, \`\`pgwire\`\` instrumental to the UDI-PGP server.
  //         ' as contents_md;

  //         WITH json_data AS (
  //             SELECT
  //                 json_extract(versions, '$.sqlpage') AS sqlpage_version,
  //                 json_extract(versions, '$.pgwire') AS pgwire_version,
  //                 json_extract(versions, '$.rusqlite') AS rusqlite_version,
  //                 json_extract(versions, '$.sqlean') AS sqlean_version,
  //                 json_extract(versions, '$.surveilr') AS surveilr_version
  //             FROM (
  //                 SELECT surveilr_version() AS versions
  //             )
  //         )
  //         SELECT
  //             'sqlpage' AS component,
  //             sqlpage_version AS contents
  //         FROM json_data
  //         UNION ALL
  //         SELECT
  //             'pgwire' AS component,
  //             pgwire_version AS contents
  //         FROM json_data
  //         UNION ALL
  //         SELECT
  //             'rusqlite' AS component,
  //             rusqlite_version AS contents
  //         FROM json_data
  //         UNION ALL
  //         SELECT
  //             'sqlean' AS component,
  //             sqlean_version AS contents
  //         FROM json_data
  //         UNION ALL
  //         SELECT
  //             'surveilr' AS component,
  //             surveilr_version AS contents
  //         FROM json_data;

  //         `;
  //   }
}
