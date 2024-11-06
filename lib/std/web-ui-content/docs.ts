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
        description: "Information Schema documentation for orchestrated objects",
        siblingOrder: 99,
      })
      async "docs/release-notes.sql"() {
        const sqlSnippets: string[] = []
        const directory = path.join(Deno.cwd(), "docs/release");
        for await (const entry of Deno.readDir(directory)) {
            if (entry.isFile && entry.name.endsWith('.md')) {
                const title = entry.name.replace('.md', '');
                const content = await this.fetchTextForSqlLiteral(import.meta.resolve(`${directory}/${entry.name}`));
                const sqlSnippet = `
                    SELECT 'foldable' as component;
                    SELECT '${title}' as title, '${content}' as description_md;
                `;
                
                sqlSnippets.push(sqlSnippet);
            }
        }

        return this.SQL`
            SELECT 'title' AS component, 'Release Notes for surveilr Versions' as contents;
            ${sqlSnippets.join('\n')}
        `;
      }
}