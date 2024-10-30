#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

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
function cakNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "/cak",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class ContentAssemblerSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /cak-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE path like '/cak%';
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Content Assembler IMAP",
    description: "Email system with IMAP",
  })
  "cak/index.sql"() {
    return this.SQL`
      WITH navigation_cte AS (
          SELECT COALESCE(title, caption) as title, description
            FROM sqlpage_aide_navigation
           WHERE namespace = 'prime' AND path = '/cak'
      )
      SELECT 'list' AS component, title, description
        FROM navigation_cte;
      SELECT caption as title, COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = '/cak'
       ORDER BY sibling_order;`;
  }

  @cakNav({
    caption: "Inbox",
    description: ``,
    siblingOrder: 1,
  })
  "cak/inbox.sql"() {
    return this.SQL`
      ${this.activePageTitle()}

      SELECT 'table' AS component,
            'subject' AS markdown,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search;

      SELECT extended_uniform_resource_id as "uniform resource id",
      "message_from" as "message from",
       '[' || message_subject || '](/cak/email-detail.sql?id=' || extended_uniform_resource_id || ')' AS "subject",
       strftime('%m/%d/%Y', message_date) as "message date"
      from inbox
      `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "cak/email-detail.sql"() {
    return this.SQL`
      select
      'breadcrumb' as component;
      select
          'Home' as title,
          '/'    as link;
      select
          'IMAP Email System' as title,
          '/cak/' as link;
      select
          'inbox' as title,
          '/cak/inbox.sql' as link;
      select
          "message_subject" as title from inbox where CAST(extended_uniform_resource_id AS TEXT)=CAST($id AS TEXT);

      SELECT 'table' AS component,
                  'Column Count' as align_right,
                  TRUE as sort,
                  TRUE as search;
       SELECT
        uniform_resource_id,
        anchor as "News letter link",
        anchor_text as "link text"
        from
          ur_transform_html_email_anchor where CAST(uniform_resource_id AS TEXT)=CAST($id AS TEXT);`;
  }
}

export async function SQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statefulcakSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateful.sql"),
        );
      }
      async statelesscakSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }
    }(),
    new sh.ShellSqlPages(),
    new c.ConsoleSqlPages(),
    new ur.UniformResourceSqlPages(),
    new orch.OrchestrationSqlPages(),
    new ContentAssemblerSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
