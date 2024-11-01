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
    caption: "IMAP Accounts",
    description: ``,
    siblingOrder: 1,
  })
  "cak/accounts.sql"() {
    return this.SQL`
      ${this.activePageTitle()}

      SELECT 'table' AS component,
            'subject' AS markdown,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search,
            'accounts' AS markdown;

       SELECT
        '[' || email || '](/cak/account-folder.sql?imap_account_id=' || ur_ingest_session_imap_account_id || ')' AS "accounts"
          FROM uniform_resource_imap
          GROUP BY ur_ingest_session_imap_account_id
          ORDER BY uniform_resource_id;
      `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "cak/account-folder.sql"() {
    return this.SQL`
    SELECT 'breadcrumb' as component;
      SELECT
          'Home' as title,
          '/'    as link;
      SELECT
          'Content Assembler IMAP' as title,
          '/cak' as link;
      SELECT
          'IMAP Accounts' as title,
          '/cak/accounts.sql' as link;
      SELECT
          (SELECT
        'Folder (' || email || ')'
          FROM uniform_resource_imap WHERE ur_ingest_session_imap_account_id = $imap_account_id::TEXT
          GROUP BY ur_ingest_session_imap_account_id
          ORDER BY uniform_resource_id) as title,
          '/cak/account-folder.sql?imap_account_id=' || $imap_account_id::TEXT as link;

        SELECT
          'title'   as component,
          (SELECT
        'Folder (' || email || ')'
          FROM uniform_resource_imap WHERE ur_ingest_session_imap_account_id = $imap_account_id::TEXT
          GROUP BY ur_ingest_session_imap_account_id
          ORDER BY uniform_resource_id) as contents;

      SELECT 'table' AS component,
            'subject' AS markdown,
            'Column Count' as align_right,
            TRUE as sort,
            TRUE as search,
            'folder' AS markdown;

     SELECT '[' || folder_name || '](/cak/imap-mail-list.sql?folder_id=' || ur_ingest_session_imap_acct_folder_id || ')' AS "folder"
        FROM uniform_resource_imap
        WHERE ur_ingest_session_imap_account_id=$imap_account_id::TEXT
        GROUP BY ur_ingest_session_imap_acct_folder_id
        ORDER BY uniform_resource_id;
      `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "cak/imap-mail-list.sql"() {
    return this.SQL`
    SELECT 'breadcrumb' as component;
    SELECT
          'Home' as title,
          '/'    as link;
      SELECT
          'Content Assembler IMAP' as title,
          '/cak' as link;
      SELECT
          'IMAP Accounts' as title,
          '/cak/accounts.sql' as link;
      SELECT
          (SELECT
        'Folder (' || email || ')'
          FROM uniform_resource_imap WHERE ur_ingest_session_imap_acct_folder_id = $folder_id::TEXT
          GROUP BY ur_ingest_session_imap_account_id
          ORDER BY uniform_resource_id) as title,
          '/cak/account-folder.sql?imap_account_id=' || (SELECT
        ur_ingest_session_imap_account_id
          FROM uniform_resource_imap WHERE ur_ingest_session_imap_acct_folder_id = $folder_id::TEXT
          GROUP BY ur_ingest_session_imap_account_id) as link;

      SELECT
          (
        SELECT email || ' (' || folder_name || ')'
          FROM uniform_resource_imap WHERE ur_ingest_session_imap_acct_folder_id = $folder_id::TEXT
          GROUP BY ur_ingest_session_imap_account_id
          ORDER BY uniform_resource_id) as title,
          '/cak/imap-mail-list.sql?folder_id=' || $folder_id::TEXT as link;


      SELECT 'table' AS component,
            'Uniform Resources' AS title,
            "Size (bytes)" as align_right,
            TRUE AS sort,
            TRUE AS search,
            TRUE AS hover,
            TRUE AS striped_rows,
            TRUE AS small;

     SELECT subject,"from",
     CASE
          WHEN ROUND(julianday('now') - julianday(date)) = 0 THEN 'Today'
          WHEN ROUND(julianday('now') - julianday(date)) = 1 THEN '1 day ago'
          WHEN ROUND(julianday('now') - julianday(date)) BETWEEN 2 AND 6 THEN CAST(ROUND(julianday('now') - julianday(date)) AS INT) || ' days ago'
          WHEN ROUND(julianday('now') - julianday(date)) < 30 THEN CAST(ROUND(julianday('now') - julianday(date)) AS INT) || ' days ago'
          WHEN ROUND(julianday('now') - julianday(date)) < 365 THEN CAST(ROUND((julianday('now') - julianday(date)) / 30) AS INT) || ' months ago'
          ELSE CAST(ROUND((julianday('now') - julianday(date)) / 365) AS INT) || ' years ago'
      END AS "Relative Time",
      strftime('%Y-%m-%d', substr(date, 1, 19)) as date
      FROM uniform_resource_imap
      WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT
      ORDER BY uniform_resource_id;
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
