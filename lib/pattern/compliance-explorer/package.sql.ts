#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-net
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

const SQE_TITLE = "Compliance Explorer";
const SQE_LOGO = "scf-icon.png";
const SQE_FAV_ICON = "scf-favicon.ico";

// custom decorator that makes navigation for this notebook type-safe
function ceNav(route: Omit<spn.RouteConfig, "path" | "parentPath">) {
  return spn.navigationPrime({
    ...route,
    parentPath: "ce/index.sql",
  });
}

/**
 * These pages depend on ../../prime/ux.sql.ts being loaded into RSSD (for nav).
 */
export class ComplianceExplorerSqlPages extends spn.TypicalSqlPageNotebook {
  // TypicalSqlPageNotebook.SQL injects any method that ends with `DQL`, `DML`,
  // or `DDL` as general SQL before doing any upserts into sqlpage_files.
  navigationDML() {
    return this.SQL`
      -- delete all /ip-related entries and recreate them in case routes are changed
      DELETE FROM sqlpage_aide_navigation WHERE path like 'ce%';
      ${this.upsertNavSQL(...Array.from(this.navigation.values()))}
    `;
  }

  @spn.navigationPrimeTopLevel({
    caption: "SCF Controls",
    description:
      "SCF (Secure Controls Framework) controls are a set of cybersecurity and privacy requirements designed to help organizations manage and comply with various regulatory, statutory, and contractual frameworks.",
  })
  "ce/index.sql"() {
    return this.SQL`
    SELECT
    'text' AS component,
    'Compliance Explorer ' AS title;
    SELECT
    'The compliance explorer cover a wide range of standards and guidelines across different areas of cybersecurity and data protection. They include industry-specific standards, privacy regulations, and cybersecurity frameworks. Complying with these frameworks supports a strong cybersecurity stance and alignment with data protection laws.' as contents;
    SELECT
    'card' AS component,
    '' AS title,
    2 AS columns;
    SELECT
      title,
      '**Geography:** ' || geography || '  \n' ||
      '**Source:** ' || source || '  \n' ||
      '**Health Insurance Portability and Accountability Act (HIPAA)**' || '  \n' ||
      '**Version:** ' || version || '  \n' ||
      '**Published/Last Reviewed Date/Year:** ' || last_reviewed_date || '  \n' ||
      '[**Detail View**](' || ${this.absoluteURL("/ce/regime/controls.sql?regimeType=US%20HIPAA")
      }|| ')' AS description_md
    FROM compliance_regime
    WHERE title = 'US HIPAA';

    SELECT
      title,
      '**Geography:** ' || geography || '  \n' ||
      '**Source:** ' || source || '  \n' ||
      '**Standard 800-53 rev4**' || '  \n' ||
      '**Version:** ' || version || '  \n' ||
      '**Published/Last Reviewed Date/Year:** ' || last_reviewed_date || '  \n' ||
      '[**Detail View**](' || ${this.absoluteURL("/ce/regime/controls.sql?regimeType=NIST")
      } || ')' AS description_md
    FROM compliance_regime
    WHERE title = 'NIST';`;
  }

  @ceNav({
    caption: " ",
    description: ``,
    siblingOrder: 2,
  })
  "ce/regime/controls.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
      SELECT
      'text' AS component,
      ''|| $regimeType ||' Controls' AS title;
      SELECT
      description as contents FROM compliance_regime WHERE title = $regimeType::TEXT;
      SELECT
      'table' AS component,
      TRUE AS sort,
      TRUE AS search,
      "Control Code" AS markdown;
      SELECT '[' || control_code || ']('|| ${this.absoluteURL("/ce/regime/control/control_detail.sql?id=")
      } || control_code || '&regimeType='|| replace($regimeType,
    " ", "%20")||')' AS "Control Code",
      scf_control AS "Title",
      scf_domain AS "Domain",
      control_description AS "Control Description",
      control_id AS "Requirements"
      FROM compliance_regime_control WHERE control_type=$regimeType::TEXT;`;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/control/control_detail.sql"() {
    return this.SQL`
    SELECT
    'card' AS component,
    'Control Details' AS title,
    1 AS columns;
    SELECT
      control_code AS title,
      '**Control Question:** ' || REPLACE(REPLACE(control_question, '▪', '-'), '\n', '  \n') || '  \n\n' ||
      '**Control Description:** ' || REPLACE(REPLACE(control_description, '▪', '-'), '\n', '  \n') || '  \n\n' ||
      '**Control Id:** ' || control_id || '  \n\n' ||
      '**Control Domain:** ' || scf_domain || '  \n\n' ||
      '**SCF Control:** ' || scf_control AS description_md
    FROM compliance_regime_control
    WHERE control_code = $id::TEXT AND control_type = $regimeType::TEXT;
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
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve("./stateful.sql"),
        );
      }
    }(),
    new sh.ShellSqlPages(SQE_TITLE, SQE_LOGO, SQE_FAV_ICON),
    new c.ConsoleSqlPages(),
    new ur.UniformResourceSqlPages(),
    new orch.OrchestrationSqlPages(),
    new ComplianceExplorerSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await controlSQL()).join("\n"));
}
