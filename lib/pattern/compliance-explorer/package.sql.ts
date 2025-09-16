#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-net
import { sqlPageNB as spn } from "./deps.ts";
import {
  console as c,
  orchestration as orch,
  shell as sh,
  uniformResource as ur,
} from "../../std/web-ui-content/mod.ts";

const SQE_TITLE = "Compliance Explorer";
const SQE_LOGO = "compliance-explorer.png";
const SQE_FAV_ICON = "content-assembler.ico";

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
    caption: "Controls",
    description:
      "SCF (Secure Controls Framework) controls are a set of cybersecurity and privacy requirements designed to help organizations manage and comply with various regulatory, statutory, and contractual frameworks.",
  })
  "ce/index.sql"() {
    return this.SQL`
    SELECT
      'text' AS component,
      'Compliance Explorer' AS title;

    SELECT
      'The compliance explorer covers a wide range of standards and guidelines across different areas of cybersecurity and data protection. They include industry-specific standards, privacy regulations, and cybersecurity frameworks. Complying with these frameworks supports a strong cybersecurity stance and alignment with data protection laws.' AS contents;

    SELECT
      'card' AS component,
      '' AS title,
      2 AS columns;

    SELECT
      'Secure Controls Framework (SCF)' AS title,
      'Explore SCF Controls' AS description_md,
      ${this.absoluteURL("/ce/regime/scf.sql")} as link
    UNION
    SELECT
      'AICPA SOC 2' AS title,
      'Explore SOC 2 Controls' AS description_md,
      ${this.absoluteURL("/ce/regime/soc2.sql")} as link
    UNION
    SELECT
      'HiTRUST e1 Assessment' AS title,
      'Explore HiTRUST e1 Assessment  Controls' AS description_md,
      ${this.absoluteURL("/ce/regime/hitrust.sql")} as link
    UNION
    SELECT
      'ISO 27001:2022' AS title,
      'Explore ISO 27001:2022  Controls' AS description_md,
      ${this.absoluteURL("/ce/regime/iso-27001.sql")} as link
    UNION
    SELECT
      'HIPAA' AS title,
      'Explore HIPAA Controls' AS description_md,
      ${this.absoluteURL("/ce/regime/hipaa_security_rule.sql")} AS link
    UNION
    SELECT
      'Together.Health Security Assessment (THSA)' AS title,
      'Explore THSA Controls' AS description_md,
      ${this.absoluteURL("/ce/regime/thsa.sql")} AS link;
 
  `;
  }

  @ceNav({
    caption: " ",
    description: ``,
    siblingOrder: 2,
  })
  "ce/regime/scf.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
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
      '[**Detail View**](' || ${this.absoluteURL(
      "/ce/regime/controls.sql?regimeType=US%20HIPAA",
    )
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
      '[**Detail View**](' || ${this.absoluteURL(
        "/ce/regime/controls.sql?regimeType=NIST",
      )
      } || ')' AS description_md
    FROM compliance_regime
    WHERE title = 'NIST';`;
  }

  @ceNav({
    caption: "SOC 2",
    description: "AICPA SOC 2 trust services criteria controls.",
    siblingOrder: 3,
  })
  "ce/regime/soc2.sql"() {
    return this.SQL`
      ${this.activePageTitle()}
      SELECT
        'text' AS component,
        'SOC 2 Controls' AS title;

      SELECT
        'The SOC 2 controls are based on the AICPA Trust Services Criteria, focusing on security, availability, processing integrity, confidentiality, and privacy.' AS contents;

      SELECT
        'table' AS component,
        TRUE AS sort,
        TRUE AS search;

      SELECT
        control_id AS "Control Identifier",
        control_name AS "Control Name",
        common_criteria AS "Common Criteria",
        criteria_type AS "Criteria Type",
        control_question AS "Control Question",
        control_code AS "SCF Reference",
        tenant_name AS "Tenant"
      FROM compliance_regime_control_soc2;
    `;
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
      SELECT '[' || control_code || ']('|| ${this.absoluteURL(
      "/ce/regime/control/control_detail.sql?id=",
    )
      } || control_code || '&regimeType='|| replace($regimeType,
    " ", "%20")||')' AS "Control Code",
      scf_control AS "Title",
      scf_domain AS "Domain",
      control_description AS "Control Description",
      control_id AS "Requirements"
      FROM compliance_regime_control WHERE control_type=$regimeType::TEXT;`;
  }

  @ceNav({
    caption: "HiTRUST e1 Assessment",
    description: "HiTRUST e1 Assessment services criteria controls.",
    siblingOrder: 3,
  })
  "ce/regime/hitrust.sql"() {
    return this.SQL`
     ${this.activePageTitle()}
     SELECT
      'text' AS component,
      'HiTRUST e1 Assessment Controls' AS title;

     SELECT
      'The HiTRUST e1 Assessment controls provide a comprehensive set of security and privacy requirements to support compliance with various standards and regulations.' AS contents;

     SELECT
      'table' AS component,
      TRUE AS sort,
      TRUE AS search;

     SELECT
      control_code AS "ID",
      control_id AS "Control Identifier",
      fii_id AS "Fii ID",
      common_criteria AS "Common Criteria",
      control_name AS "Control Name",
      control_question AS "Control Description",
      tenant_name AS "Tenant"
     FROM compliance_regime_control_hitrust_e1;
    `;
  }

  @ceNav({
    caption: "ISO 27001 v3",
    description: "ISO 27001 v3 controls mapped with SCF.",
    siblingOrder: 4,
  })
  "ce/regime/iso-27001.sql"() {
    return this.SQL`
     ${this.activePageTitle()}
     SELECT
      'text' AS component,
      'ISO 27001 v3 Controls' AS title;

     SELECT
      'The ISO 27001 v3 controls are aligned with the Secure Controls Framework (SCF) to provide a comprehensive mapping of security requirements.' AS contents;

     SELECT
      'table' AS component,
      TRUE AS sort,
      TRUE AS search;

     SELECT
      control_code AS "Control Code",
      scf_domain AS "SCF Domain",
      scf_control AS "SCF Control",
      control_description AS "Control Description",
      control_question AS "Control Question",
      evidence AS "Evidence",
      tenant_name AS "Tenant"
     FROM compliance_iso_27001_control;
    `;
  }

  @ceNav({
    caption: "HIPAA Security Rule Safeguards",
    description:
      "HIPAA Security Rule safeguards and their mapping with SCF and FII IDs.",
    siblingOrder: 5,
  })
  "ce/regime/hipaa_security_rule.sql"() {
    return this.SQL`
     ${this.activePageTitle()}
     SELECT
      'text' AS component,
      'HIPAA Security Rule Safeguards' AS title;

     SELECT
      'The HIPAA Security Rule safeguards define administrative, physical, and technical measures required to ensure the confidentiality, integrity, and availability of electronic protected health information (ePHI).' AS contents;

     SELECT
      'table' AS component,
      TRUE AS sort,
      TRUE AS search;

     SELECT
      id AS "ID",
      common_criteria AS "Common Criteria",
      hipaa_security_rule_reference AS "HIPAA Security Rule Reference",
      safeguard AS "Safeguard",
      handled_by_nq AS "Handled by nQ",
      fii_id AS "FII ID",
      tenant_name AS "Tenant"
     FROM hipaa_security_rule_safeguards;
    `;
  }

  @ceNav({
    caption: "THSA Controls",
    description:
      "Texas Health Services Authority (THSA) control mappings with SCF.",
    siblingOrder: 6,
  })
  "ce/regime/thsa.sql"() {
    return this.SQL`
     ${this.activePageTitle()}
     SELECT
      'text' AS component,
      'THSA Controls' AS title;
 
     SELECT
      'The THSA controls provide compliance requirements for health services, mapped against the Secure Controls Framework (SCF).' AS contents;
 
     SELECT
      'table' AS component,
      TRUE AS sort,
      TRUE AS search;
 
    SELECT
      id,
      scf_domain,
      scf_control,
      scf_control_question,
      scf_code,
      your_answer,
      tenant_id,
      tenant_name
    FROM
      compliance_regime_thsa;
    `;
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

    SELECT 'card' as component, 1 as columns;
    SELECT

      '\n' || p.body_text AS description_md
      FROM ai_ctxe_policy p

      WHERE p.satisfies = $id
      ;
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
    new ur.UniformResourceSqlPages(),
    new c.ConsoleSqlPages(),
    new orch.OrchestrationSqlPages(),
    new ComplianceExplorerSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await controlSQL()).join("\n"));
}
