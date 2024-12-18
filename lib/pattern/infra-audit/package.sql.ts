#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

// custom decorator that makes navigation for this notebook type-safe
function iaNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "/opsfolio",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class InfraAuditSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /ip-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE path like '/opsfolio/infra/audit%';
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

  @iaNav({
    caption: "Infrastructure Audits",
    description:
      `The Infra Audit is designed to manage and streamline audits across
various frameworks, including HIPAA, HITRUST, AICPA, and others. This project
provides a comprehensive platform for conducting, tracking, and reporting on
compliance audits, ensuring that your organization meets the necessary
regulatory requirements.`,
    siblingOrder: 2,
  })
  "opsfolio/infra/audit/index.sql"() {
    return this.SQL`
    SELECT 'card' as component
    SELECT name  as title,
    'arrow-big-right' as icon,
    '/opsfolio/infra/audit/control_regime.sql?id=' ||control_regime_id || '' as link
    FROM
    tenant_based_control_regime WHERE tenant_id = '239518031485599747' AND parent_id == ''`;
  }

  @iaNav({
    caption: "Control Regimes",
    description: ``,
    siblingOrder: 3,
  })
  "opsfolio/infra/audit/control_regime.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
      SELECT 'card' as component
      SELECT name  as title,
      'arrow-big-right' as icon,
      '/opsfolio/infra/audit/session_list.sql?id=' ||control_regime_id || '' as link
      FROM
      tenant_based_control_regime WHERE tenant_id = '239518031485599747' AND parent_id = $id:: Text`;
  }

  @iaNav({
    caption: "Audit Sessions",
    description: ``,
    siblingOrder: 1,
  })
  "opsfolio/infra/audit/session_list.sql"() {
    return this.SQL`
    ${this.activePageTitle()}

    SELECT 'table' AS component,
           TRUE AS sort,
           TRUE AS search,
           'Session' AS markdown;

    SELECT '[' || title || '](/opsfolio/infra/audit/session_detail.sql?id=' || audit_type_id  || '&sessionid=' || audit_session_id || ')' AS "Session",
           audit_type AS "Audit Type",
           due_date AS "Due Date",
           tenant_name AS "Tenant"
    FROM audit_session_list
    WHERE tenant_id = '239518031485599747' AND audit_type_id = $id::TEXT;
  `;
  }

  @iaNav({
    caption: "Audit Sessions",
    description: ``,
    siblingOrder: 1,
  })
  "opsfolio/infra/audit/session_detail.sql"() {
    return this.SQL`
    SELECT
    'title' AS component,
    'Control List' AS contents
    select 'table' as component,
    'Control code' AS markdown;
    SELECT
    '[' || control_code || '](/opsfolio/infra/audit/control_detail.sql?id=' || control_id || ')' AS "Control code",
    common_criteria as "Common criteria",
    question as "Question"
      FROM control WHERE CAST(audit_type_id AS TEXT)=CAST($id AS TEXT);
    `;
  }

  @iaNav({
    caption: "Controls Detail",
    description: ``,
    siblingOrder: 1,
  })
  "opsfolio/infra/audit/control_detail.sql"() {
    return this.SQL`
    SELECT
      'title' AS component
      select 'table' as component
      SELECT
      fii AS "FII",
      question AS "Question",
      common_criteria as "Common criteria",
      expected_evidence as "Evidence",
      control_regime as "Control Regime"
        FROM control WHERE CAST(control_id AS TEXT)=CAST($id AS TEXT);
      `;
  }
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
export async function auditSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends spn.TypicalSqlPageNotebook {
      async statelessAuditSQL() {
        // read the file from either local or remote (depending on location of this file)
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateless.sql"),
        );
      }

      async orchestrateStatefulIaSQL() {
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
    new InfraAuditSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await auditSQL()).join("\n"));
}
