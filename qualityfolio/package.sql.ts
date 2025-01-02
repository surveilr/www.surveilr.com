#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";
import { QualityfolioShellSqlPages } from "./custom-shell.ts";

/**
 * These pages depend on ../../std/package.sql.ts being loaded into RSSD (for nav).
 *
 * TODO: in TypicalSqlPageNotebook.SQL() call at the bottom of this code it
 * probably makese sense to just add all dependent notebooks into the sources
 * list like so:
 *
 *   TypicalSqlPageNotebook.SQL(new X(), new Y(), ..., new FhirSqlPages())
 *
 * where X, Y, etc. are in lib/std/content/mod.ts
 */

// custom decorator that makes navigation for this notebook type-safe
function qltyfolioNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "/qltyfolio",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class QualityfolioSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /qltyfolio-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE path like '/qltyfolio%';
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Test Management System",
    description: "Test management system",
  })
  "qltyfolio/index.sql"() {
    return this.SQL`
      WITH navigation_cte AS (
          SELECT COALESCE(title, caption) as title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path = '/qltyfolio'
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title, COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = '/qltyfolio'
       ORDER BY sibling_order;`;
  }
  @qltyfolioNav({
    caption: "Projects",
    description: ``,
    siblingOrder: 1,
  })
  "qltyfolio/test-management.sql"() {
    return this.SQL`
      ${this.activePageTitle()}

      SELECT 'list' AS component,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search;
      
    
      
      SELECT 
      '[' || project_name || '](/qltyfolio/detail.sql?name=' || project || ')' as description_md
      from projects
      
      `;
  }
  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "qltyfolio/detail.sql"() {
    return this.SQL`
      ${this.activePageTitle()}

      SELECT 'table' as component,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search;
      SELECT 
      title,
      description,
      priority,
      status
      
      from test_cases where folder_name=$name and file_extension='md';`;
  }

  // @qltyfolioNav({
  //   caption: "Failed",
  //   description: "",
  //   siblingOrder: 2,
  // })
  // "qltyfolio/failed.sql"() {
  //   return this.SQL`
  //     ${this.activePageTitle()}

  //     SELECT 'table' as component,
  //           'subject' AS markdown,
  //           'Column Count' as align_right,
  //           TRUE as sort,
  //           TRUE as search;
  //     SELECT * from phimail_delivery_detail where status!='dispatched'`;
  // }
}

export async function SQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statelessqltyfolioSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }
    }(),
    new QualityfolioSqlPages(),
    new c.ConsoleSqlPages(),
    new ur.UniformResourceSqlPages(),
    new orch.OrchestrationSqlPages(),   
    new QualityfolioShellSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
