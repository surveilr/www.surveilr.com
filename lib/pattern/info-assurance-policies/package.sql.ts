#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

// custom decorator that makes navigation for this notebook type-safe
function ipNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "opsfolio/index.sql",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class InfoAssurancePolicySqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /ip-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE path like 'opsfolio/info/policy%';
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
      SELECT caption as title, ${
      this.absoluteURL("/")
    } || COALESCE(url, path) as link, description
        FROM sqlpage_aide_navigation
       WHERE namespace = 'prime' AND parent_path = ${
      this.constructHomePath("opsfolio")
    } AND sibling_order = 2
       ORDER BY sibling_order; `;
  }

  @ipNav({
    caption: "Information Assurance Policies",
    description:
      `The Information Assurance Policies is designed to display and create views for policies
        specific to tenants within the Opsfolio platform.These policies are ingested
        from Markdown(.md) or Markdown with JSX(.mdx) files, originating from
    Opsfolio, and are stored in the uniform_resource table.`,
    siblingOrder: 2,
  })
  "opsfolio/info/policy/policy_dashboard.sql"() {
    return this.SQL`
    select
    'card' as component,
      2 as columns;
    select
    "Policies" as title,
      'arrow-big-right' as icon,
      ${this.absoluteURL("/opsfolio/info/policy/policy.sql")} as link;
    select
    "Evidences" as title,
      'arrow-big-right' as icon,
      ${this.absoluteURL("/opsfolio/info/policy/evidence.sql")} as link; `;
  }

  @ipNav({
    caption: "Policies",
    description: ``,
    siblingOrder: 3,
  })
  "opsfolio/info/policy/policy.sql"() {
    return this.SQL`
    select
    'card' as component,
      3 as columns;
    select
    UPPER(SUBSTR(title, 1, 1)) || LOWER(SUBSTR(title, 2)) as title,
      'arrow-big-right' as icon,
      ${
      this.absoluteURL("/opsfolio/info/policy/policy_list.sql?segment=")
    } || segment || '' as link
     FROM policy_dashboard; `;
  }

  @ipNav({
    caption: "Evidences",
    description: ``,
    siblingOrder: 3,
  })
  "opsfolio/info/policy/evidence.sql"() {
    return this.SQL`
    select
    'card' as component,
      3 as columns;
    select
    'card' as component,
      3 as columns;
    SELECT
    A.title as title,
      'arrow-big-right' as icon,
      ${
      this.absoluteURL("/")
    }||replace(b.path, 'opsfolio/info/policy/', '') as link
FROM vigetallviews A
inner join sqlpage_files b on A.path = b.path
 where a.used_path = 0; `;
  }

  @ipNav({
    caption: "Policy List",
    description: ``,
    siblingOrder: 4,
  })
  "opsfolio/info/policy/policy_list.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
    select
    'card' as component,
      1 as columns;
    select
    title,
      'arrow-big-right' as icon,
      ${
      this.absoluteURL("/opsfolio/info/policy/policy_detail.sql?id=")
    } || uniform_resource_id || '' as link
        FROM policy_list WHERE parentfolder = $segment::TEXT AND segment1 = ""

        UNION ALL

    SELECT
    REPLACE(segment1, '-', ' ') as title,
      'chevrons-down' as icon,
      ${
      this.absoluteURL(
        "/opsfolio/info/policy/policy_inner_list.sql?parentfolder=",
      )
    } || parentfolder || '&segment=' || segment1 as link
    FROM
    policy_list
    WHERE
    parentfolder = $segment:: TEXT
          AND segment1 != ''
      GROUP BY
    segment1
      ;
    `;
  }

  @ipNav({
    caption: "Policy Inner List",
    description: ``,
    siblingOrder: 5,
  })
  "opsfolio/info/policy/policy_inner_list.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
    select
    'card' as component,
      1 as columns;
    select
    title,
      'arrow-big-right' as icon,
      ${
      this.absoluteURL("/opsfolio/info/policy/policy_detail.sql?id=")
    } || uniform_resource_id || '' as link
        FROM policy_list WHERE parentfolder = $parentfolder::TEXT AND segment1 = $segment:: TEXT;
    `;
  }

  @ipNav({
    caption: "Policy Detail",
    description: ``,
    siblingOrder: 6,
  })
  "opsfolio/info/policy/policy_detail.sql"() {
    return this.SQL`

    select 'card' as component,
      1 as columns;
      SELECT  json_extract(content_fm_body_attrs, '$.attrs.title') AS title,
      json_extract(content_fm_body_attrs, '$.body') AS description_md
    FROM policy_detail WHERE uniform_resource_id = $id:: TEXT;


    `;
  }
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
export async function policySQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statelessPolicySQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }

      async orchestrateStatefulPolicySQL() {
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
    new InfoAssurancePolicySqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await policySQL()).join("\n"));
}
