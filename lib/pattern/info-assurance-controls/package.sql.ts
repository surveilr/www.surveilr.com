#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-net
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

// custom decorator that makes navigation for this notebook type-safe
function icNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "/opsfolio",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class InfoAssuranceControlsSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /ip-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE path like '/opsfolio/info/control%';
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "Opsfolio",
    description: "Opsfolio",
  })
  "opsfolio/index.sql"() {
    return this.SQL`
    select
     'card'             as component,
     3                 as columns;
      SELECT caption as title, COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = '/opsfolio' AND sibling_order = 2
       ORDER BY sibling_order;`;
  }

  @icNav({
    caption: "Information Assurance Controls",
    description:
      `The Infra Controls is designed to manage and implement controls specific
      to various audit requirements, such as CC1001, CC1002, and others. This project
      provides a platform for defining, applying, and tracking the effectiveness of
      these controls, ensuring that your organization meets the necessary standards
      for audit compliance.`,
    siblingOrder: 2,
  })
  "opsfolio/info/control/control_dashboard.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
    SELECT
    'card'             as component
   SELECT DISTINCT
    control_regime  as title,
    'arrow-big-right'       as icon,
    '/opsfolio/info/control/control_regime.sql?id=' ||control_regime_id || '' as link
    FROM
    control_regimes;
  `;
  }

  @icNav({
    caption: "Control Regimes",
    description: ``,
    siblingOrder: 3,
  })
  "opsfolio/info/control/control.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
    SELECT
    'card'             as component
   SELECT DISTINCT
    control_regime  as title,
    'arrow-big-right'       as icon,
    '/opsfolio/info/control/control_regime.sql?id=' ||control_regime_id || '' as link
    FROM
    control_regimes;
  `;
  }

  @icNav({
    caption: "Audit Types",
    description: ``,
    siblingOrder: 4,
  })
  "opsfolio/info/control/control_regime.sql"() {
    return this.SQL`
  SELECT
    'title' AS component,
    'Audit Types' AS contents
    select 'card' as component
    SELECT audit_type_name  as title,
      'arrow-big-right'       as icon,
     '/opsfolio/info/control/controls.sql?id=' ||audit_type_id || '' as link
      FROM control_regimes WHERE control_regime_id = $id::TEXT;
    `;
  }

  @icNav({
    caption: "Control List",
    description: ``,
    siblingOrder: 5,
  })
  "opsfolio/info/control/controls.sql"() {
    return this.SQL`
    SELECT
    'title' AS component,
    'Control List' AS contents
    select 'table' as component,
    'Control code' AS markdown;
    SELECT
    '[' || control_code || '](/opsfolio/info/control/control_detail.sql?id=' || control_id || ')' AS "Control code",
    common_criteria as "Common criteria",
    fii as "Fii Id",
    question as "Question"
      FROM control WHERE audit_type_id = $id::TEXT;
    `;
  }

  @icNav({
    caption: "Control Details",
    description: ``,
    siblingOrder: 6,
  })
  "opsfolio/info/control/control_detail.sql"() {
    return this.SQL`
     select
    'card'             as component,
    1               as columns;
    SELECT
      'title' AS component,
      common_criteria AS contents
    FROM
      control
    WHERE
      control_id = $id::TEXT
    SELECT
      'title' AS component,
      "Control Code" AS contents,
  3        as level;
      SELECT
      'text' AS component,
      control_code AS contents
      FROM
      control
    WHERE
      control_id = $id::TEXT
      SELECT
      'title' AS component,
      "Control Question" AS contents,
      3        as level;
         select
    'card'             as component,
    1               as columns;
    select question as title
    FROM
      control
    WHERE
      control_id = $id::TEXT
      SELECT
      'title' AS component,
      "Expected Evidence" AS contents,
      3         as level;
  select
    'card'             as component,
    1               as columns;
    select expected_evidence as title
    FROM
      control
    WHERE
      control_id = $id::TEXT
         SELECT
      'title' AS component,
      "Mapped Requirements" AS contents,
      3       as level;
      SELECT
    'card'             as component,
    1               as columns
    select fii as title
    FROM
      control
    WHERE
      control_id = $id::TEXT
    `;
  }
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT

export async function controlSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statelessControlSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }

      async orchestrateStatefulControlSQL() {
        // read the file from either local or remote (depending on location of this file)
        // return await spn.TypicalSqlPageNotebook.fetchText(
        //   import.meta.resolve("./stateful-drh-surveilr.sql"),
        // );
      }
    }(),
    new sh.ShellSqlPages(),
    new ur.UniformResourceSqlPages(),
    new c.ConsoleSqlPages(),
    new orch.OrchestrationSqlPages(),
    new InfoAssuranceControlsSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await controlSQL()).join("\n"));
}
