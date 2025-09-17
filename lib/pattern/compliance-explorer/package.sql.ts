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
      'CMMC' AS title,
      'Explore CMMC Controls' AS description_md,
      ${this.absoluteURL("/ce/regime/cmmc.sql")} as link
    UNION
    SELECT
      'AICPA' AS title,
      'Explore AICPA Controls' AS description_md,
      ${this.absoluteURL("/ce/regime/aicpa.sql")} as link
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
      )}|| ')' AS description_md
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
      )} || ')' AS description_md
    FROM compliance_regime
    WHERE title = 'NIST';`;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/aicpa.sql"() {
    return this.SQL`
    --- Display breadcrumb
    SELECT
      'breadcrumb' AS component;
    SELECT
      'Home' AS title,
      ${this.absoluteURL("/")} AS link;
    SELECT
      'Controls' AS title,
      ${this.absoluteURL("/ce/index.sql")} AS link;
    SELECT
      'AICPA' AS title,
      ${this.absoluteURL("/ce/regime/aicpa.sql")} AS link;
 
    ${this.activePageTitle()}
   
    SELECT
      'text' AS component,
      'AICPA' AS title;
 
    SELECT
      'The American Institute of Certified Public Accountants (AICPA) is the national professional organization for Certified Public Accountants (CPAs) in the United States. Established in 1887, the AICPA sets ethical standards for the profession and U.S. auditing standards for private companies, nonprofit organizations, federal, state, and local governments. It also develops and grades the Uniform CPA Examination and offers specialty credentials for CPAs who concentrate on personal financial planning; forensic accounting; business valuation; and information technology.' AS contents;
 
    -- Cards for SOC 2 Type I & Type II
    SELECT
      'card' AS component;
 
    SELECT
      'SOC 2 Type I' AS title,
      'Report on Controls as a Service Organization. Relevant to Security, Availability, Processing Integrity, Confidentiality, or Privacy.' AS description,
      ${this.absoluteURL("/ce/regime/aicpa/soc2.sql")} AS link
    UNION ALL
    SELECT
      'SOC 2 Type II' AS title,
      'SOC 2 Type II reports provide lists of Internal controls that are audited by an Independent third-party to show how well those controls are implemented and operating.' AS description,
      ${this.absoluteURL("/ce/regime/aicpa/soc2_type2.sql")} AS link;
 
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/aicpa/soc2.sql"() {
    return this.SQL`
    --- Display breadcrumb
    SELECT
      'breadcrumb' AS component;
    SELECT
      'Home' AS title,
      ${this.absoluteURL("/")} AS link;
    SELECT
      'Controls' AS title,
      ${this.absoluteURL("/ce/index.sql")} AS link;
    SELECT
      'AICPA' AS title,
      ${this.absoluteURL("/ce/regime/aicpa.sql")} AS link;
    SELECT
      'SOC 2 Type I' AS title,
      ${this.absoluteURL("/ce/regime/aicpa/soc2.sql")} AS link;
 
    ${this.activePageTitle()}
 
    SELECT
      'text' AS component,
      'SOC 2 Type I Controls' AS title;
 
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

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/aicpa/soc2_type2.sql"() {
    return this.SQL`
    --- Display breadcrumb
    SELECT
      'breadcrumb' AS component;
    SELECT
      'Home' AS title,
      ${this.absoluteURL("/")} AS link;
    SELECT
      'Controls' AS title,
      ${this.absoluteURL("/ce/index.sql")} AS link;
    SELECT
      'AICPA' AS title,
      ${this.absoluteURL("/ce/regime/aicpa.sql")} AS link;
    SELECT
      'SOC 2 Type II' AS title,
      ${this.absoluteURL("/ce/regime/aicpa/soc2_type2.sql")} AS link;
 
    --- Display page title
    SELECT
      'title' AS component,
      'SOC 2 Type II Controls' AS contents;
 
    --- Display description
    SELECT
      'text' AS component,
      'SOC 2 Type II reports evaluate not just the design, but also the operating effectiveness of controls over a defined review period.' AS contents;
 
    --- Table
    SELECT
      'table' AS component,
      TRUE AS sort,
      TRUE AS search;
 
    SELECT
      control_id AS "Control Identifier",
      fii_id AS "FII Id",
      common_criteria AS "Common Criteria",
      criteria_type AS "Criteria Type",
      control_name AS "Control Name",
      control_question AS "Control Question",
      tenant_id AS "Tenant Id",
      tenant_name AS "Tenant"
    FROM aicpa_soc2_type2_controls;
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
      )} || control_code || '&regimeType='|| replace($regimeType,
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
    caption: "HIPAA",
    description: "HIPAA and their mapping with SCF and FII IDs.",
    siblingOrder: 5,
  })
  "ce/regime/hipaa_security_rule.sql"() {
    const pagination = this.pagination({
      tableOrViewName: "hipaa_security_rule_safeguards",
    });

    return this.SQL`
    ${this.activePageTitle()}
 
    SELECT
      'text' AS component,
      'HIPAA' AS title;
 
    SELECT
      'The HIPAA define administrative, physical, and technical measures required to ensure the confidentiality, integrity, and availability of electronic protected health information (ePHI).' AS contents;
 
    -- Pagination controls (top)
    ${pagination.init()}
 
    SELECT
      'table' AS component,
      TRUE AS sort,
      TRUE AS search,
      "Control Code" AS markdown;
 
    SELECT
      '[' || hipaa_security_rule_reference || '](' ||
        ${this.absoluteURL(
          "/ce/regime/hipaa_security_rule_detail.sql?id=",
        )} || hipaa_security_rule_reference || ')' AS "Control Code",
      common_criteria AS "Common Criteria",
      safeguard AS "Control Question",
      handled_by_nq AS "Handled by nQ",
      fii_id AS "FII ID",
      tenant_name AS "Tenant"
    FROM hipaa_security_rule_safeguards
    ORDER BY hipaa_security_rule_reference
    LIMIT $limit OFFSET $offset;
 
    -- Pagination controls (bottom)
    ${pagination.renderSimpleMarkdown()}
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/hipaa_security_rule_detail.sql"() {
    return this.SQL`
    SELECT
      'breadcrumb' AS component;
 
    SELECT
      'Home' AS title,
      ${this.absoluteURL("/")} AS link;
 
    SELECT
      'Controls' AS title,
      ${this.absoluteURL("/ce/index.sql")} AS link;
 
    SELECT
      'HIPAA' AS title,
      ${this.absoluteURL("/ce/regime/hipaa_security_rule.sql")} AS link;
 
    -- Dynamic last breadcrumb using the reference from the DB
    SELECT
      hipaa_security_rule_reference AS title,
      '#' AS link
    FROM hipaa_security_rule_safeguards
    WHERE hipaa_security_rule_reference = $id::TEXT;
 
    SELECT
      'card' AS component,
      'HIPAA Security Rule Detail' AS title,
      1 AS columns;
 
    SELECT
      common_criteria AS title,
      '**Control Code:** ' || hipaa_security_rule_reference || '  \n\n' ||
      '**Control Question:** ' || safeguard || '  \n\n' ||
      '**FII ID:** ' || fii_id || '  \n\n'  AS description_md
    FROM hipaa_security_rule_safeguards
    WHERE hipaa_security_rule_reference = $id::TEXT;
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

  @ceNav({
    caption: "CMMC",
    description:
      "Cybersecurity Maturity Model Certification (CMMC) Levels 1-3.",
    siblingOrder: 6,
  })
  "ce/regime/cmmc.sql"() {
    return this.SQL`
    ${this.activePageTitle()}
    SELECT 'text' AS component, 'Cybersecurity Maturity Model Certification (CMMC)' AS title;

    SELECT
      "The Cybersecurity Maturity Model Certification (CMMC) program aligns with the information security requirements of the U.S. Department of Defense (DoD) for Defense Industrial Base (DIB) partners. The DoD has mandated that all organizations engaged in business with them, irrespective of size, industry, or level of involvement, undergo a cybersecurity maturity assessment based on the CMMC framework. This initiative aims to ensure the protection of sensitive unclassified information shared between the Department and its contractors and subcontractors. The program enhances the Department's confidence that contractors and subcontractors adhere to cybersecurity requirements applicable to acquisition programs and systems handling controlled unclassified information" AS contents;

    SELECT 'card' AS component, '' AS title, 3 AS columns;

    SELECT
      'CMMC Model 2.0 LEVEL 1' AS title,
      '15 requirements; Annual self-assessment & annual affirmation. The Department views Level 1 as an opportunity to engage its contractors in developing and strengthening their approach to cybersecurity. Self-assessments will suffice to meet CMMC Level 1 requirements. Contractors will be required to conduct self-assessment on an annual basis, accompanied by an annual affirmation from a senior company official that the company is meeting requirements. The Department intends to require companies to register self-assessments and affirmations in the Supplier Performance Risk System (SPRS).' AS description_md,
      ${this.absoluteURL("/ce/regime/cmmc_level.sql?level=1")} AS link
    UNION
    SELECT
      'CMMC Model 2.0 LEVEL 2',
      '110 requirements aligned with NIST SP 800-171; Triennial third-party assessment & annual affirmation; Triennial self-assessment & annual affirmation for select programs. A subset of programs with Level 2 requirements do not involve information critical to national security, and associated contractors will be permitted to meet the requirement through self-assessments. Contractors will be required to conduct self-assessment on an annual basis, accompanied by an annual affirmation from a senior company official that the company is meeting requirements. The Department intends to require companies to register self-assessments and affirmations in the Supplier Performance Risk System (SPRS).',
      ${this.absoluteURL("/ce/regime/cmmc_level.sql?level=2")}
    UNION
    SELECT
      'CMMC Model 2.0 LEVEL 3',
      '110+ requirements based on NIST SP 800-171 & 800-172; Triennial government-led assessment & annual affirmation. The Department intends for Level 3 cybersecurity requirements to be assessed by government officials. Assessment requirements are currently under development. Level 3 information will likewise be posted as it becomes available.',
      ${this.absoluteURL("/ce/regime/cmmc_level.sql?level=3")};
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/cmmc_level.sql"() {
    // Define pagination
    const pagination = this.pagination({
      tableOrViewName: "scf_view",
      // Only fetch rows for the selected CMMC level
      whereSQL: `
      WHERE 
        (@level = 1 AND cmmc_level_1 IS NOT NULL AND cmmc_level_1 != '')
     OR (@level = 2 AND cmmc_level_2 IS NOT NULL AND cmmc_level_2 != '')
     OR (@level = 3 AND cmmc_level_3 IS NOT NULL AND cmmc_level_3 != '')
    `,
    });

    return this.SQL`
    ${this.activePageTitle()}

    --- Breadcrumbs
    SELECT 'breadcrumb' AS component;
    SELECT 'Home' AS title, ${this.absoluteURL("/")} AS link;
    SELECT 'Controls' AS title, ${this.absoluteURL("/ce/index.sql")} AS link;
    SELECT 'CMMC' AS title, ${this.absoluteURL("/ce/regime/cmmc.sql")} AS link;
    SELECT 'CMMC Level ' || COALESCE(@level::TEXT,'') AS title, '#' AS link;

    --- Description text
    SELECT 'text' AS component,
       "The Cybersecurity Maturity Model Certification (CMMC) program aligns with the information security requirements of the U.S. Department of Defense (DoD) for Defense Industrial Base (DIB) partners. The DoD has mandated that all organizations engaged in business with them, irrespective of size, industry, or level of involvement, undergo a cybersecurity maturity assessment based on the CMMC framework. This initiative aims to ensure the protection of sensitive unclassified information shared between the Department and its contractors and subcontractors. The program enhances the Department's confidence that contractors and subcontractors adhere to cybersecurity requirements applicable to acquisition programs and systems handling controlled unclassified information" AS contents;


    --- Table (markdown column)
    SELECT 'table' AS component, TRUE AS sort, TRUE AS search, "Control Code" AS markdown;

    -- Pagination Controls (Top)
    ${pagination.init()}

    --- Table data
    SELECT
      '[' || replace(replace(
          CASE 
            WHEN @level = 1 THEN cmmc_level_1
            WHEN @level = 2 THEN cmmc_level_2
            ELSE cmmc_level_3
          END,
          '\n', ' '),
          '\r', ' ')
      || '](' || ${this.absoluteURL("/ce/regime/cmmc_detail.sql?code=")}
      || replace(replace(
          CASE 
            WHEN @level = 1 THEN cmmc_level_1
            WHEN @level = 2 THEN cmmc_level_2
            ELSE cmmc_level_3
          END,
          '\n', ' '), ' ', '%20')
      || '&level=' || @level || ')' AS "Control Code",

      scf_domain       AS "Domain",
      scf_control      AS "Title",
      control_code     AS "SCF Code",
      control_description AS "Control Description",
      control_question AS "Question"

    FROM scf_view
    WHERE 
          (@level = 1 AND cmmc_level_1 IS NOT NULL AND cmmc_level_1 != '')
      OR (@level = 2 AND cmmc_level_2 IS NOT NULL AND cmmc_level_2 != '')
      OR (@level = 3 AND cmmc_level_3 IS NOT NULL AND cmmc_level_3 != '')
    ORDER BY control_code
    LIMIT $limit OFFSET $offset;

    -- Pagination Controls (Bottom)
    ${pagination.renderSimpleMarkdown("level")};
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/cmmc_detail.sql"() {
    return this.SQL`
    ${this.activePageTitle()}
    --- Breadcrumbs
    SELECT 'breadcrumb' AS component;
    SELECT 'Home' AS title, ${this.absoluteURL("/")} AS link;
    SELECT 'Controls' AS title, ${this.absoluteURL("/ce/index.sql")} AS link;
    SELECT 'CMMC' AS title, ${this.absoluteURL("/ce/regime/cmmc.sql")} AS link;
    SELECT 'CMMC Level ' || COALESCE($level::TEXT, '') AS title, ${this.absoluteURL("/ce/regime/cmmc_level.sql?level=")} || COALESCE($level::TEXT,'1') AS link;
    SELECT COALESCE($code, '') AS title, '#' AS link;;

    --- Primary details card
    SELECT 'card' AS component, 'CMMC Control Details' AS title, 1 AS columns;
    SELECT
        COALESCE($code, '(unknown)') AS title,
        '**Control Question:** ' || COALESCE(control_question, '') || '  \n\n' ||
        '**Control Description:** ' || COALESCE(control_description, '') || '  \n\n' ||
        '**SCF Domain:** ' || COALESCE(scf_domain, '') || '  \n\n' ||
        '**SCF Control:** ' || COALESCE(scf_control, '') || '  \n\n' ||
        '**SCF / FII IDs:** ' || COALESCE(control_code, '') AS description_md
    FROM scf_view
    WHERE
          ($level = 1 AND replace(replace(cmmc_level_1,'\n',' '),'\\r','') = $code)
      OR ($level = 2 AND replace(replace(cmmc_level_2,'\n',' '),'\\r','') = $code)
      OR ($level = 3 AND replace(replace(cmmc_level_3,'\n',' '),'\\r','') = $code)
    LIMIT 1;

    --- Fallback if no exact match
    SELECT 'text' AS component,
          'No exact control found for code: ' || COALESCE($code,'(empty)') || '. Showing a fallback example for Level ' || COALESCE($level::TEXT,'1') || '.' AS contents
    WHERE NOT EXISTS (
        SELECT 1 FROM scf_view
        WHERE
              ($level = 1 AND replace(replace(cmmc_level_1,'\n',' '),'\\r','') = $code)
          OR ($level = 2 AND replace(replace(cmmc_level_2,'\n',' '),'\\r','') = $code)
          OR ($level = 3 AND replace(replace(cmmc_level_3,'\n',' '),'\\r','') = $code)
    );

    --- Example fallback card (optional)
    SELECT 'card' AS component, 'Fallback control' AS title, 1 AS columns
    WHERE NOT EXISTS (
        SELECT 1 FROM scf_view
        WHERE
              ($level = 1 AND replace(replace(cmmc_level_1,'\n',' '),'\\r','') = $code)
          OR ($level = 2 AND replace(replace(cmmc_level_2,'\n',' '),'\\r','') = $code)
          OR ($level = 3 AND replace(replace(cmmc_level_3,'\n',' '),'\\r','') = $code)
    );
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
