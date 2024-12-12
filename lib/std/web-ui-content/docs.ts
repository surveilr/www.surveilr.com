import * as spn from "../notebook/sqlpage.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";

export function docsNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "docs/index.sql",
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
                WHERE namespace = 'prime' AND path = ${this.constructHomePath("docs")
      }
                )
                SELECT 'list' AS component, title, description
                    FROM navigation_cte;
                SELECT caption as title, ${this.absoluteURL("/")
      } || COALESCE(url, path) as link, description
                    FROM sqlpage_aide_navigation
                WHERE namespace = 'prime' AND parent_path =  ${this.constructHomePath("docs")
      }
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

    const entries: Deno.DirEntry[] = [];
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
        import.meta.resolve(`${directory}/${entry.name}`),
      );
      const sqlSnippet = `
                    SELECT 'foldable' as component;
                    SELECT '${title}' as title, '${content}' as description_md;
                `;

      sqlSnippets.push(sqlSnippet);
    }

    return this.SQL`
            SELECT 'title' AS component, 'Release Notes for surveilr Versions' as contents;
            ${sqlSnippets.join("\n")}
        `;
  }

  @docsNav({
    caption: "SQL Functions",
    description: "surveilr specific SQLite functions for extensibilty",
    siblingOrder: 2,
  })
  "docs/functions.sql"() {
    return this.SQL`
        -- To display title
        SELECT
          'text' AS component,
          'Surveilr SQLite Functions' AS title
          WHERE $function IS NULL;

        SELECT
          'text' AS component,
          'Below is a comprehensive list and description of all Surveilr SQLite functions. Each function includes details about its parameters, return type, and version introduced.'
          AS contents_md WHERE $function IS NULL;

        SELECT
        'list' AS component,
        'Surveilr Functions' AS title
        WHERE $function IS NULL;

          SELECT  name AS title,
                NULL AS icon,  -- Add an icon field if applicable
                'functions-inner.sql?function=' || name || '#function' AS link,
                $function = name AS active
          FROM surveilr_function_doc
          ORDER BY name;

        SELECT
          'text' AS component,
          '' || name || '()' AS title, 'function' AS id
        FROM surveilr_function_doc WHERE name = $function;

        SELECT
          'text' AS component,
          description AS contents_md
        FROM surveilr_function_doc WHERE name = $function;

        SELECT
          'text' AS component,
          'Introduced in version ' || version || '.' AS contents
        FROM surveilr_function_doc WHERE name = $function;

        SELECT
          'title' AS component,
          3 AS level,
          'Parameters' AS contents
        WHERE $function IS NOT NULL;

        SELECT
          'card' AS component,
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
              NULL AS icon,  -- Add an icon field if needed
              sqlpage.link('functions.sql', json_object('function', name)) AS link
        FROM surveilr_function_doc
        ORDER BY name;
   `;
  }

  @docsNav({
    caption: "Diagnostics",
    description: "Diagnose `surveilr` specific dependencies, capturable executables in the PATH, and `surveilr-doctor*`database views.",
    siblingOrder: 2,
  })
  "docs/diagnostics.sql"() {
    return this.SQL`
        -- Title Component
        SELECT
            'text' AS component,
            'Surveilr Doctor' AS title;

        -- Description Component
        SELECT
            'text' AS component,
            'A detailed diagnosis to assess your system''s readiness for surveilr. It checks critical dependencies like Deno, Rustc, and SQLite, ensuring they are installed and meet version requirements. Additionally, it scans for and executes capturable executables in the PATH and evaluates surveilr_doctor_* database views for diagnostic insights.'
            AS contents_md;

  

            SELECT 
            'title'   as component,
            'Versions' as contents,
            2         as level;
          SELECT 
              'table' AS component,
              TRUE AS sort;
          SELECT 
              'deno' AS "Dependency",
              json_extract(json_data, '$.versions.deno') AS "Version"
          FROM (
              SELECT sqlpage.exec('surveilr', 'doctor', '--json') AS json_data
          );

          SELECT 
              'rust' AS "Dependency",
              json_extract(json_data, '$.versions.rustc') AS "Version"
          FROM (
              SELECT sqlpage.exec('surveilr', 'doctor', '--json') AS json_data
          );

          SELECT 
              'SQLite3' AS "Dependency",
              json_extract(json_data, '$.versions.sqlite3') AS "Version"
          FROM (
              SELECT sqlpage.exec('surveilr', 'doctor', '--json') AS json_data
          );


            SELECT 
            'title'   as component,
            'Extensions' as contents,
            2         as level;
          SELECT 
              'table' AS component,
              TRUE AS sort;

          -- Extract and display each extension
          SELECT 
              json_each.value AS "Extension"
          FROM json_each(
              json_extract(sqlpage.exec('surveilr', 'doctor', '--json'), '$.extensions')
          );

            SELECT 
            'title'   as component,
            'Views' as contents,
            2         as level;
          SELECT 
              'table' AS component,
              TRUE AS sort;

          WITH views AS (
              SELECT name AS view_name
              FROM sqlite_master
              WHERE type = 'view' AND name LIKE 'surveilr_doctor%'
          )
          SELECT *
          FROM (
              SELECT view_name, *
              FROM views, pragma_table_info(view_name) AS table_info
          );
        `
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "docs/functions-inner.sql"() {
    return this.SQL`

      select
        'breadcrumb' as component;
      select
        'Home' as title,
        ${this.absoluteURL("/")} as link;
      select
        'Docs' as title,
         ${this.absoluteURL("/docs/index.sql")} as link;
      select
        'SQL Functions' as title,
         ${this.absoluteURL("/docs/functions.sql")} as link;
      select
        $function as title,
        ${this.absoluteURL("/docs/functions-inner.sql?function=")
      }  || $function AS link;


        SELECT
          'text' AS component,
          '' || name || '()' AS title, 'function' AS id
        FROM surveilr_function_doc WHERE name = $function;

        SELECT
          'text' AS component,
          description AS contents_md
        FROM surveilr_function_doc WHERE name = $function;

        SELECT
          'text' AS component,
          'Introduced in version ' || version || '.' AS contents
        FROM surveilr_function_doc WHERE name = $function;

        SELECT
          'title' AS component,
          3 AS level,
          'Parameters' AS contents
        WHERE $function IS NOT NULL;

        SELECT
          'card' AS component,
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
              NULL AS icon,  -- Add an icon field if needed
              sqlpage.link('functions-inner.sql', json_object('function', name)) AS link
        FROM surveilr_function_doc
        ORDER BY name;
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
