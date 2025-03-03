#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  docs as d,
  orchestration as orch,
  //shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";
import * as sh from "./custom_shell.ts";

const WEB_UI_TITLE = "Feetfolio";
const WE_UI_LOGO = "feetfolio-logo.png";
const WE_UI_FAV_ICON = "feetfolio-favicon.ico";

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
    parentPath: "qltyfolio/index.sql",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class FleetFolioSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /qltyfolio-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE parent_path like ${this.constructHomePath("qltyfolio")
      };
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "FleetFolio",
    description: `FleetFolio is a powerful infrastructure assurance platform built on surveilr that helps organizations achieve continuous compliance, security, and operational reliability. Unlike traditional asset management tools that simply list discovered assets, FleetFolio takes a proactive approach by defining expected infrastructure assets and verifying them against actual assets found using osQuery Management Server (MS).`,
  })
  "cak/index.sql"() {
    return this.SQL`
    select
        'text'              as component,
        'FleetFolio is a powerful infrastructure assurance platform built on surveilr that helps organizations achieve continuous compliance, security, and operational reliability. Unlike traditional asset management tools that simply list discovered assets, FleetFolio takes a proactive approach by defining expected infrastructure assets and verifying them against actual assets found using osQuery Management Server (MS).' as contents;
      WITH navigation_cte AS (
          SELECT COALESCE(title, caption) as title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path = ${this.constructHomePath("cak")}
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title, ${this.absoluteURL("/")
      } || COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = ${this.constructHomePath("cak")
      }
       ORDER BY sibling_order;`;
  }
}

export async function SQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statefulqltyfolioSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateful.sql"),
        );
      }
      async statelessqltyfolioSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }
    }(),
    new FleetFolioSqlPages(),
    new c.ConsoleSqlPages(),
    new d.DocsSqlPages(),
    new ur.UniformResourceSqlPages(),
    new orch.OrchestrationSqlPages(),
    new sh.ShellSqlPages(WEB_UI_TITLE, WE_UI_LOGO, WE_UI_FAV_ICON),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
