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
    parentPath: "ce/regime/index.sql",
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
  "ce/regime/index.sql"() {
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
      '**Geography**: US \n
      **Source**: Department of Defense (DoD) \n
      **Version**: 2.0 \n
      **Published/Last Reviewed Date/Year**: 2021-11-04 00:00:00+00' AS description_md,      
      ${this.absoluteURL("/ce/regime/cmmc.sql")} as link
    UNION
    SELECT
      'AICPA' AS title,
      '**Geography**: US \n
      **Source**: American Institute of Certified Public Accountants (AICPA) \n
      **Version**: N/A \n
      **Published/Last Reviewed Date/Year**: 2023-10-01 00:00:00+00' AS description_md,
      ${this.absoluteURL("/ce/regime/aicpa.sql")} as link
    UNION
    SELECT
      'HiTRUST e1 Assessment' AS title,
      '**Geography**: US \n
      **Source**: HITRUST Alliance \n
      **HITRUST Essentials, 1-Year (e1) Assessment** \n
      **Version**: e1 \n
      **Published/Last Reviewed Date/Year**: 2021-09-13 00:00:00+00' AS description_md,      
      ${this.absoluteURL("/ce/regime/hitrust.sql")} as link
    UNION
    SELECT
      'ISO 27001:2022' AS title,
      '**Geography**: International \n
      **Source**: International Organization for Standardization (ISO) \n
      **Version**: 2022 \n
      **Published/Last Reviewed Date/Year**: 2022-10-25 00:00:00+00' AS description_md,      
      ${this.absoluteURL("/ce/regime/iso-27001.sql")} as link
    UNION
    SELECT
      'HIPAA' AS title,
      '**Geography**: US \n
      **Source**: Federal \n
      **Health Insurance Portability and Accountability Act (HIPAA)** \n
      **Version**: N/A \n
      **Published/Last Reviewed Date/Year**: 2024-01-06 00:00:00+00' AS description_md,
      ${this.absoluteURL("/ce/regime/hipaa_security_rule.sql")} AS link
    UNION
    SELECT
      'Together.Health Security Assessment (THSA)' AS title,
      '**Geography**: US \n
      **Source**: Together.Health (health innovation collaborative) \n
      **Together.Health Security Assessment (THSA)** \n
      **Version**: v2019.1 \n
      **Published/Last Reviewed Date/Year**: 2019-10-26 00:00:00+00' AS description_md,      
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
      '[**Detail View**](' || ${
      this.absoluteURL(
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
      '[**Detail View**](' || ${
      this.absoluteURL(
        "/ce/regime/controls.sql?regimeType=NIST",
      )
    } || ')' AS description_md
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
  ${this.absoluteURL("/ce/regime/index.sql")} AS link;
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
    'card' AS component,
      2 AS columns;
 
  SELECT
    'SOC 2 Type I' AS title,
    'Report on Controls as a Service Organization. Relevant to Security, Availability, Processing Integrity, Confidentiality, or Privacy.' AS description,
    ${this.absoluteURL("/ce/regime/soc2_type1.sql")} AS link
  UNION ALL
  SELECT
    'SOC 2 Type II' AS title,
    'SOC 2 Type II reports provide lists of Internal controls that are audited by an Independent third-party to show how well those controls are implemented and operating.' AS description,
    ${this.absoluteURL("/ce/regime/soc2_type2.sql")} AS link;
 
`;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/soc2_type1.sql"() {
    const pagination = this.pagination({
      tableOrViewName: "compliance_regime_control_soc2",
    });

    return this.SQL`
    --- Display breadcrumb
    SELECT
      'breadcrumb' AS component;
    SELECT
      'Home' AS title,
      ${this.absoluteURL("/")} AS link;
    SELECT
      'Controls' AS title,
      ${this.absoluteURL("/ce/regime/index.sql")} AS link;
    SELECT
      'AICPA' AS title,
      ${this.absoluteURL("/ce/regime/aicpa.sql")} AS link;
    SELECT
      'SOC 2 Type I' AS title,
      ${this.absoluteURL("/ce/regime/soc2_type1.sql")} AS link;
 
    ${this.activePageTitle()}
 
    SELECT
      'text' AS component,
      'SOC 2 Type I Controls' AS title;
 
    SELECT
        'The SOC 2 controls are based on the AICPA Trust Services Criteria, focusing on security, availability, processing integrity, confidentiality, and privacy.' AS contents;
 
    SELECT
      'table' AS component,
      "Control Code" AS markdown,
      TRUE AS sort,
      TRUE AS search;
 
    -- Pagination Controls (Top)
    ${pagination.init()}
 
    SELECT
      '[' || control_id || '](' ||
        ${
      this.absoluteURL(
        "/ce/regime/soc2_detail.sql?type=soc2-type1&id=",
      )
    } || control_id || ')' AS "Control Code",
        control_name AS "Control Name",
        common_criteria AS "Common Criteria",
        criteria_type AS "Criteria Type",
        control_question AS "Control Question"
    FROM compliance_regime_control_soc2
    LIMIT $limit OFFSET $offset;
 
    -- Pagination Controls (Bottom)
    ${pagination.renderSimpleMarkdown()};
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/soc2_type2.sql"() {
    const pagination = this.pagination({
      tableOrViewName: "aicpa_soc2_type2_controls",
    });

    return this.SQL`
    --- Display breadcrumb
    SELECT
      'breadcrumb' AS component;
    SELECT
      'Home' AS title,
      ${this.absoluteURL("/")} AS link;
    SELECT
      'Controls' AS title,
      ${this.absoluteURL("/ce/regime/index.sql")} AS link;
    SELECT
      'AICPA' AS title,
      ${this.absoluteURL("/ce/regime/aicpa.sql")} AS link;
    SELECT
      'SOC 2 Type II' AS title,
      ${this.absoluteURL("/ce/regime/soc2_type2.sql")} AS link;
 
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
      "Control Code" AS markdown,
      TRUE AS sort,
      TRUE AS search;
 
    -- Pagination Controls (Top)
    ${pagination.init()}
 
    SELECT
      '[' || control_id || '](' ||
        ${
      this.absoluteURL(
        "/ce/regime/soc2_detail.sql?type=soc2-type2&id=",
      )
    } || control_id || ')' AS "Control Code",
      fii_id AS "FII ID",
      common_criteria AS "Common Criteria",
      criteria_type AS "Criteria Type",
      control_name AS "Control Name",
      control_question AS "Control Question"
    FROM aicpa_soc2_type2_controls
    LIMIT $limit OFFSET $offset;
 
    -- Pagination Controls (Bottom)
    ${pagination.renderSimpleMarkdown()};
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/soc2_detail.sql"() {
    return this.SQL`
    -- Breadcrumbs
    SELECT 'breadcrumb' AS component;
    SELECT 'Home' AS title, ${this.absoluteURL("/")} AS link;
    SELECT 'Controls' AS title, ${
      this.absoluteURL("/ce/regime/index.sql")
    } AS link;
    SELECT 'AICPA' AS title, ${
      this.absoluteURL("/ce/regime/aicpa.sql")
    } AS link;
 
    -- SOC 2 Type breadcrumb
    SELECT
      CASE
        WHEN $type = 'soc2-type1' THEN 'SOC 2 Type I'
        WHEN $type = 'soc2-type2' THEN 'SOC 2 Type II'
        ELSE 'SOC 2'
      END AS title,
      CASE
        WHEN $type = 'soc2-type1' THEN ${
      this.absoluteURL("/ce/regime/soc2_type1.sql")
    }
        WHEN $type = 'soc2-type2' THEN ${
      this.absoluteURL("/ce/regime/soc2_type2.sql")
    }
        ELSE ${this.absoluteURL("/ce/regime/aicpa.sql")}
      END AS link;
 
    -- Last breadcrumb (dynamic control_id, non-clickable)
    SELECT
      control_id AS title, '#' AS link
    FROM (
      SELECT control_id
      FROM compliance_regime_control_soc2
      WHERE $type = 'soc2-type1' AND control_id = $id::TEXT
      UNION ALL
      SELECT control_id
      FROM aicpa_soc2_type2_controls
      WHERE $type = 'soc2-type2' AND control_id = $id::TEXT
    ) t
    LIMIT 1;
 
    -- Card Header
    SELECT 'card' AS component,
           CASE
             WHEN $type = 'soc2-type1' THEN 'SOC 2 Type I Control Detail'
             WHEN $type = 'soc2-type2' THEN 'SOC 2 Type II Control Detail'
             ELSE 'SOC 2 Control Detail'
           END AS title,
           1 AS columns;
 
    -- Detail Section (aligned UNION)
    SELECT
      common_criteria AS title,
      '**Control Code:** ' || control_id || '  \n\n' ||
      '**Control Name:** ' || control_name || '  \n\n' ||
      (CASE WHEN $type = 'soc2-type2' THEN '**FII ID:** ' || COALESCE(fii_id,'') || '  \n\n' ELSE '' END) ||
      '**Control Question:** ' || COALESCE(control_question,'') || '  \n\n'
      AS description_md
    FROM (
      -- Type I controls (with SCF reference)
      SELECT control_id, control_name, fii_id, common_criteria, control_question
      FROM compliance_regime_control_soc2
      WHERE $type = 'soc2-type1' AND control_id = $id::TEXT
     
      UNION ALL
     
      -- Type II controls (no SCF reference → add NULL for column alignment)
      SELECT control_id, control_name, fii_id, common_criteria, control_question
      FROM aicpa_soc2_type2_controls
      WHERE $type = 'soc2-type2' AND control_id = $id::TEXT
    );
    -- TODO Placeholder Card
    SELECT
      'card' AS component,
      1 AS columns;
 
 
   -----accordion start
   SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: ' || $id || '</b> &mdash; <b>FII ID: ' || fii_id || '</b>.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM (SELECT control_id, fii_id
    FROM compliance_regime_control_soc2
    WHERE $type = 'soc2-type1' AND control_id = $id::TEXT
    
    UNION ALL
    
    SELECT control_id, fii_id
    FROM aicpa_soc2_type2_controls
    WHERE $type = 'soc2-type2' AND control_id = $id::TEXT
)

     
    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = 'Author Prompt' AND (
    ($type = 'soc2-type1' AND regime = 'SOC2-TypeI') OR
    ($type = 'soc2-type2' AND regime = 'SOC2-TypeII')
  );
      

    
    SELECT 'html' AS component,
      '</div></details>' AS html;

      --accordion for audit prompt

SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM (SELECT control_id, fii_id
    FROM compliance_regime_control_soc2
    WHERE $type = 'soc2-type1' AND control_id = $id::TEXT
    
    UNION ALL
    
    SELECT control_id, fii_id
    FROM aicpa_soc2_type2_controls
    WHERE $type = 'soc2-type2' AND control_id = $id::TEXT
)

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = 'Audit Prompt' AND (
    ($type = 'soc2-type1' AND regime = 'SOC2-TypeI') OR
    ($type = 'soc2-type2' AND regime = 'SOC2-TypeII')
  );
      
 SELECT 'html' AS component,
      '</div></details>' AS html;

      
SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM (SELECT control_id, fii_id
    FROM compliance_regime_control_soc2
    WHERE $type = 'soc2-type1' AND control_id = $id::TEXT
    
    UNION ALL
    
    SELECT control_id, fii_id
    FROM aicpa_soc2_type2_controls
    WHERE $type = 'soc2-type2' AND control_id = $id::TEXT
)

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $id AND (
    ($type = 'soc2-type1' AND regimeType = 'SOC2-TypeI') OR
    ($type = 'soc2-type2' AND regimeType = 'SOC2-TypeII')
  );
   SELECT 'html' AS component,
      '</div></details>' AS html;
      SELECT 'html' as component,
    '<style>
        tr.actualClass-passed td.State {
            color: green !important; /* Default to red */
        }
         tr.actualClass-failed td.State {
            color: red !important; /* Default to red */
        }
          tr.actualClass-passed td.Statealign-middle {
            color: green !important; /* Default to red */
        }
          tr.actualClass-failed td.Statealign-middle {
            color: red !important; /* Default to red */
        }
        
        .btn-list {
        display: flex;
        justify-content: flex-end;
        }
       h2.accordion-header button {
        font-weight: 700;
      }

      /* Test Detail Outer Accordion Styles */
      .test-detail-outer-accordion {
        border: 1px solid #ddd;
        border-radius: 8px;
        margin: 20px 0;
        overflow: hidden;
      }

      .test-detail-outer-summary {
        background-color: #f5f5f5;
        padding: 15px 20px;
        cursor: pointer;
        font-weight: 600;
        color: #333;
        border: none;
        outline: none;
        user-select: none;
        list-style: none;
        position: relative;
        transition: background-color 0.2s;
      }

      .test-detail-outer-summary::-webkit-details-marker {
        display: none;
      }

      .test-detail-outer-summary::after {
        content: "+";
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 18px;
        font-weight: bold;
        color: #666;
      }

      .test-detail-outer-accordion[open] .test-detail-outer-summary::after {
        content: "−";
      }

      .test-detail-outer-summary:hover {
        background-color: #ebebeb;
      }

      .test-detail-outer-content {
        padding: 20px;
        background-color: white;
        border-top: 1px solid #ddd;
      }
    </style>

    ' as html;


          -- end
   
   
   
   
   
   
   --------------accordion end 
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
      SELECT '[' || control_code || ']('|| ${
      this.absoluteURL(
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

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/hitrust.sql"() {
    const pagination = this.pagination({
      tableOrViewName: "compliance_regime_control_hitrust_e1",
    });
    return this.SQL`
    ${this.activePageTitle()}

    --- Breadcrumbs
    SELECT 'breadcrumb' AS component;
    SELECT 'Home' AS title, ${this.absoluteURL("/")} AS link;
    SELECT 'Controls' AS title, ${
      this.absoluteURL("/ce/regime/index.sql")
    } AS link;
    SELECT 'HiTRUST e1 Assessment' AS title, '#' AS link;

    --- Description text
    SELECT 'text' AS component,
          'The HiTRUST e1 Assessment controls provide a comprehensive set of security and privacy requirements to support compliance with various standards and regulations.' AS contents;

    --- Pagination Controls (Top)
    ${pagination.init()}

    --- Table (markdown column)
    SELECT 'table' AS component, TRUE AS sort, TRUE AS search, "Control Code" AS markdown;

    --- Table data
    SELECT
      '[' || control_id || '](' || ${
      this.absoluteURL("/ce/regime/hitrust_detail.sql?code=")
    } || replace(control_id, ' ', '%20') || ')' AS "Control Code",
      fii_id AS "Fii ID",
      common_criteria AS "Common Criteria",
      control_name AS "Control Name",
      control_question AS "Control Description"
    FROM compliance_regime_control_hitrust_e1
    ORDER BY control_code ASC
    LIMIT $limit OFFSET $offset;

    --- Pagination Controls (Bottom)
    ${pagination.renderSimpleMarkdown()};
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/hitrust_detail.sql"() {
    return this.SQL`
    --- Breadcrumbs
    SELECT 'breadcrumb' AS component;
    SELECT 'Home' AS title, ${this.absoluteURL("/")} AS link;
    SELECT 'Controls' AS title, ${
      this.absoluteURL("/ce/regime/index.sql")
    } AS link;
    SELECT 'HiTRUST e1 Assessment' AS title, ${
      this.absoluteURL("/ce/regime/hitrust.sql")
    } AS link;
    SELECT COALESCE($code, '') AS title, '#' AS link;

    --- Primary details card
    SELECT 'card' AS component, 'HiTRUST Control Details' AS title, 1 AS columns;
    SELECT
        COALESCE(control_id, '(unknown)') AS title,
        '**Common Criteria:** ' || COALESCE(common_criteria,'') || '  \n\n' ||
        '**Control Name:** ' || COALESCE(control_name,'') || '  \n\n' ||
        '**Control Description:** ' || COALESCE(control_question,'') || '  \n\n' ||
        '**FII ID:** ' || COALESCE(fii_id,'') AS description_md
    FROM compliance_regime_control_hitrust_e1
    WHERE control_id = $code
    LIMIT 1;

    -- TODO Placeholder Card
    SELECT
      'card' AS component,
      1 AS columns;

      SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: ' || control_id || '</b> &mdash; <b>FII ID: ' || fii_id || '</b>.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM compliance_regime_control_hitrust_e1
WHERE control_id = $code::TEXT;

     
    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $code AND p.documentType = 'Author Prompt' and regime = 'HiTRUST'
      ;

    
    SELECT 'html' AS component,
      '</div></details>' AS html;

      --accordion for audit prompt

SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM compliance_regime_control_hitrust_e1
WHERE control_id = $code::TEXT;

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $code AND p.documentType = 'Audit Prompt' and regime = 'HiTRUST'
      ;
 SELECT 'html' AS component,
      '</div></details>' AS html;

      
SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM compliance_regime_control_hitrust_e1
WHERE control_id = $code::TEXT;

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $code and regimeType = 'HiTRUST';
   SELECT 'html' AS component,
      '</div></details>' AS html;
      SELECT 'html' as component,
    '<style>
        tr.actualClass-passed td.State {
            color: green !important; /* Default to red */
        }
         tr.actualClass-failed td.State {
            color: red !important; /* Default to red */
        }
          tr.actualClass-passed td.Statealign-middle {
            color: green !important; /* Default to red */
        }
          tr.actualClass-failed td.Statealign-middle {
            color: red !important; /* Default to red */
        }
        
        .btn-list {
        display: flex;
        justify-content: flex-end;
        }
       h2.accordion-header button {
        font-weight: 700;
      }

      /* Test Detail Outer Accordion Styles */
      .test-detail-outer-accordion {
        border: 1px solid #ddd;
        border-radius: 8px;
        margin: 20px 0;
        overflow: hidden;
      }

      .test-detail-outer-summary {
        background-color: #f5f5f5;
        padding: 15px 20px;
        cursor: pointer;
        font-weight: 600;
        color: #333;
        border: none;
        outline: none;
        user-select: none;
        list-style: none;
        position: relative;
        transition: background-color 0.2s;
      }

      .test-detail-outer-summary::-webkit-details-marker {
        display: none;
      }

      .test-detail-outer-summary::after {
        content: "+";
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 18px;
        font-weight: bold;
        color: #666;
      }

      .test-detail-outer-accordion[open] .test-detail-outer-summary::after {
        content: "−";
      }

      .test-detail-outer-summary:hover {
        background-color: #ebebeb;
      }

      .test-detail-outer-content {
        padding: 20px;
        background-color: white;
        border-top: 1px solid #ddd;
      }
    </style>

    ' as html;


          -- end



 
 
    

    --- Fallback if no exact match
    SELECT 'text' AS component,
          'No exact control found for code: ' || COALESCE($code,'(empty)') AS contents
    WHERE NOT EXISTS (
      SELECT 1 FROM compliance_regime_control_hitrust_e1 WHERE control_id = $code
    );
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/iso-27001.sql"() {
    const pagination = this.pagination({
      tableOrViewName: "compliance_iso_27001_control",
    });

    return this.SQL`
    ${this.activePageTitle()}

    --- Breadcrumbs
    SELECT 'breadcrumb' AS component;
    SELECT 'Home'     AS title, ${this.absoluteURL("/")}              AS link;
    SELECT 'Controls' AS title, ${
      this.absoluteURL("/ce/regime/index.sql")
    }  AS link;
    SELECT 'ISO 27001 v3' AS title, '#'                               AS link;

    --- Description text
    SELECT
      'text' AS component,
      'The ISO 27001 v3 controls are aligned with the Secure Controls Framework (SCF) to provide a comprehensive mapping of security requirements.' AS contents;

    --- Pagination Controls (Top)
    ${pagination.init()}

    --- Table (markdown column for detail links)
    SELECT
      'table' AS component,
      TRUE    AS sort,
      TRUE    AS search,
      "Control Code" AS markdown;

    --- Table data
    SELECT
      '[' || control_code || '](' || ${
      this.absoluteURL("/ce/regime/iso-27001_detail.sql?code=")
    } || replace(control_code, ' ', '%20') || ')' AS "Control Code",
      scf_domain        AS "SCF Domain",
      scf_control       AS "SCF Control",
      control_description AS "Control Description",
      control_question  AS "Control Question",
      evidence          AS "Evidence"
    FROM compliance_iso_27001_control
    ORDER BY control_code ASC
    LIMIT $limit OFFSET $offset;

    --- Pagination Controls (Bottom)
    ${pagination.renderSimpleMarkdown()};
  `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/iso-27001_detail.sql"() {
    return this.SQL`
    --- Breadcrumbs
    SELECT 'breadcrumb' AS component;
    SELECT 'Home' AS title, ${this.absoluteURL("/")} AS link;
    SELECT 'Controls' AS title, ${
      this.absoluteURL("/ce/regime/index.sql")
    } AS link;
    SELECT 'ISO 27001 v3' AS title, ${
      this.absoluteURL("/ce/regime/iso-27001.sql")
    } AS link;
    SELECT COALESCE($code, '') AS title, '#' AS link;

    --- Primary details card
    SELECT 'card' AS component, 'ISO 27001 v3 Control Details' AS title, 1 AS columns;
    SELECT
        COALESCE(control_code, '(unknown)') AS title,
        '**SCF Domain:** ' || COALESCE(scf_domain,'') || '  \n\n' ||
        '**SCF Control:** ' || COALESCE(scf_control,'') || '  \n\n' ||
        '**Control Description:** ' || COALESCE(control_description,'') || '  \n\n' ||
        '**Control Question:** ' || COALESCE(control_question,'') || '  \n\n' ||
        '**Evidence:** ' || COALESCE(evidence,'') AS description_md
    FROM compliance_iso_27001_control
    WHERE control_code = $code
    LIMIT 1;

    -- TODO Placeholder Card
    SELECT
      'card' AS component,
      1 AS columns;
 
      ---accordion start
      SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: ' || $code || '</b> &mdash;.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM compliance_iso_27001_control
WHERE control_code = $code::TEXT;

     
    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $code AND p.documentType = 'Author Prompt' and regime = 'ISO'
      ;

    
    SELECT 'html' AS component,
      '</div></details>' AS html;

      --accordion for audit prompt

SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM compliance_iso_27001_control
WHERE control_code = $code::TEXT;

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $code AND p.documentType = 'Audit Prompt' and regime = 'ISO'
      ;
 SELECT 'html' AS component,
      '</div></details>' AS html;

      
SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM compliance_iso_27001_control
WHERE control_code = $code::TEXT;

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $code and regimeType = 'ISO';
   SELECT 'html' AS component,
      '</div></details>' AS html;
      SELECT 'html' as component,
    '<style>
        tr.actualClass-passed td.State {
            color: green !important; /* Default to red */
        }
         tr.actualClass-failed td.State {
            color: red !important; /* Default to red */
        }
          tr.actualClass-passed td.Statealign-middle {
            color: green !important; /* Default to red */
        }
          tr.actualClass-failed td.Statealign-middle {
            color: red !important; /* Default to red */
        }
        
        .btn-list {
        display: flex;
        justify-content: flex-end;
        }
       h2.accordion-header button {
        font-weight: 700;
      }

      /* Test Detail Outer Accordion Styles */
      .test-detail-outer-accordion {
        border: 1px solid #ddd;
        border-radius: 8px;
        margin: 20px 0;
        overflow: hidden;
      }

      .test-detail-outer-summary {
        background-color: #f5f5f5;
        padding: 15px 20px;
        cursor: pointer;
        font-weight: 600;
        color: #333;
        border: none;
        outline: none;
        user-select: none;
        list-style: none;
        position: relative;
        transition: background-color 0.2s;
      }

      .test-detail-outer-summary::-webkit-details-marker {
        display: none;
      }

      .test-detail-outer-summary::after {
        content: "+";
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 18px;
        font-weight: bold;
        color: #666;
      }

      .test-detail-outer-accordion[open] .test-detail-outer-summary::after {
        content: "−";
      }

      .test-detail-outer-summary:hover {
        background-color: #ebebeb;
      }

      .test-detail-outer-content {
        padding: 20px;
        background-color: white;
        border-top: 1px solid #ddd;
      }
    </style>

    ' as html;


          -- end
    
     

    --- Fallback if no exact match
    SELECT 'text' AS component,
          'No exact control found for code: ' || COALESCE($code,'(empty)') AS contents
    WHERE NOT EXISTS (
      SELECT 1 FROM compliance_iso_27001_control WHERE control_code = $code
    );
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
        ${
      this.absoluteURL(
        "/ce/regime/hipaa_security_rule_detail.sql?id=",
      )
    } || hipaa_security_rule_reference || ')' AS "Control Code",
      common_criteria AS "Common Criteria",
      safeguard AS "Control Question",
      handled_by_nq AS "Handled by nQ",
      fii_id AS "FII ID"
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
        ${this.absoluteURL("/ce/regime/index.sql")} AS link;
  
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

      -- TODO Placeholder Card
    SELECT
      'card' AS component,
      1 AS columns;
 
          -- accordion for policy generator, audit prompt, and generated policies

              
   SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: ' || hipaa_security_rule_reference || '</b> &mdash; <b>FII ID: ' || fii_id || '</b>.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM hipaa_security_rule_safeguards
WHERE hipaa_security_rule_reference = $id::TEXT;

     
    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = 'Author Prompt'
      ;

    
    SELECT 'html' AS component,
      '</div></details>' AS html;

      --accordion for audit prompt

SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM hipaa_security_rule_safeguards
WHERE hipaa_security_rule_reference = $id::TEXT;

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = 'Audit Prompt'
      ;
 SELECT 'html' AS component,
      '</div></details>' AS html;

      
SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM hipaa_security_rule_safeguards
WHERE hipaa_security_rule_reference = $id::TEXT;

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $id;
   SELECT 'html' AS component,
      '</div></details>' AS html;
      SELECT 'html' as component,
    '<style>
        tr.actualClass-passed td.State {
            color: green !important; /* Default to red */
        }
         tr.actualClass-failed td.State {
            color: red !important; /* Default to red */
        }
          tr.actualClass-passed td.Statealign-middle {
            color: green !important; /* Default to red */
        }
          tr.actualClass-failed td.Statealign-middle {
            color: red !important; /* Default to red */
        }
        
        .btn-list {
        display: flex;
        justify-content: flex-end;
        }
       h2.accordion-header button {
        font-weight: 700;
      }

      /* Test Detail Outer Accordion Styles */
      .test-detail-outer-accordion {
        border: 1px solid #ddd;
        border-radius: 8px;
        margin: 20px 0;
        overflow: hidden;
      }

      .test-detail-outer-summary {
        background-color: #f5f5f5;
        padding: 15px 20px;
        cursor: pointer;
        font-weight: 600;
        color: #333;
        border: none;
        outline: none;
        user-select: none;
        list-style: none;
        position: relative;
        transition: background-color 0.2s;
      }

      .test-detail-outer-summary::-webkit-details-marker {
        display: none;
      }

      .test-detail-outer-summary::after {
        content: "+";
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 18px;
        font-weight: bold;
        color: #666;
      }

      .test-detail-outer-accordion[open] .test-detail-outer-summary::after {
        content: "−";
      }

      .test-detail-outer-summary:hover {
        background-color: #ebebeb;
      }

      .test-detail-outer-content {
        padding: 20px;
        background-color: white;
        border-top: 1px solid #ddd;
      }
    </style>

    ' as html;


          -- end



   
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/thsa.sql"() {
    const pagination = this.pagination({
      tableOrViewName: "compliance_regime_thsa",
    });
    return this.SQL`
      ${this.activePageTitle()}
  
      -- Breadcrumbs
      SELECT 'breadcrumb' AS component;
  
      SELECT
        'Home' AS title,
        ${this.absoluteURL("/")} AS link;
  
      SELECT
        'Controls' AS title,
        ${this.absoluteURL("/ce/regime/index.sql")} AS link;
  
      SELECT
        'Together.Health Security Assessment (THSA)' AS title,
        '#' AS link;  
  
      -- Page Heading
      SELECT
        'text' AS component,
        'Together.Health Security Assessment (THSA)' AS title;
  
      SELECT
        'The THSA controls provide compliance requirements for health services, mapped against the Secure Controls Framework (SCF).' AS contents;
  
      -- Pagination controls (top)
      ${pagination.init()}
  
      -- Table
      SELECT
        'table' AS component,
        TRUE AS sort,
        TRUE AS search,
        "Control Code" AS markdown;
  
      SELECT
        '[' || scf_code || '](' ||
          ${
      this.absoluteURL(
        "/ce/regime/thsa_detail.sql?id=",
      )
    } || scf_code || ')' AS "Control Code",
        scf_domain AS "Domain",
        scf_control AS "Control",
        scf_control_question AS "Control Question"
      FROM compliance_regime_thsa
      ORDER BY scf_code
      LIMIT $limit OFFSET $offset;
  
      -- Pagination controls (bottom)
      ${pagination.renderSimpleMarkdown()}
    `;
  }

  @spn.shell({ breadcrumbsFromNavStmts: "no" })
  "ce/regime/thsa_detail.sql"() {
    return this.SQL`
    SELECT
      'breadcrumb' AS component;
 
    SELECT
      'Home' AS title,
      ${this.absoluteURL("/")} AS link;
 
    SELECT
      'Controls' AS title,
       ${this.absoluteURL("/ce/regime/index.sql")} AS link;
 
    SELECT
      'Together.Health Security Assessment (THSA)' AS title,
      ${this.absoluteURL("/ce/regime/thsa.sql")} AS link;
 
    -- Dynamic last breadcrumb using the reference from the DB
    SELECT
      scf_code AS title,
      '#' AS link
    FROM compliance_regime_thsa
    WHERE scf_code = $id::TEXT;
 
    -- Main Control Detail Card
    SELECT
      'card' AS component,
      'Together.Health Security Assessment (THSA) Detail' AS title,
      1 AS columns;
 
    SELECT
      scf_domain AS title,
      '**Control Code:** ' || scf_code || '  \n\n' ||
      '**Control Question:** ' || scf_control_question || '  \n\n'  AS description_md
    FROM compliance_regime_thsa
    WHERE scf_code = $id::TEXT;
 
    -- TODO Placeholder Card
    SELECT
      'card' AS component,
      1 AS columns;
 
 SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: ' || $id || '</b> &mdash;.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM compliance_regime_thsa
WHERE scf_code = $id::TEXT;

     
    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = 'Author Prompt' and regime = 'THSA'
      ;

    
    SELECT 'html' AS component,
      '</div></details>' AS html;

      --accordion for audit prompt

SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM compliance_regime_thsa
WHERE scf_code = $id::TEXT;

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = 'Audit Prompt' and regime = 'THSA'
      ;
 SELECT 'html' AS component,
      '</div></details>' AS html;

      
SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">' AS html
FROM compliance_regime_thsa
WHERE scf_code = $id::TEXT;

    SELECT 'card' as component, 1 as columns;
    SELECT
      '\n' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $id and regimeType = 'THSA';
   SELECT 'html' AS component,
      '</div></details>' AS html;
      SELECT 'html' as component,
    '<style>
        tr.actualClass-passed td.State {
            color: green !important; /* Default to red */
        }
         tr.actualClass-failed td.State {
            color: red !important; /* Default to red */
        }
          tr.actualClass-passed td.Statealign-middle {
            color: green !important; /* Default to red */
        }
          tr.actualClass-failed td.Statealign-middle {
            color: red !important; /* Default to red */
        }
        
        .btn-list {
        display: flex;
        justify-content: flex-end;
        }
       h2.accordion-header button {
        font-weight: 700;
      }

      /* Test Detail Outer Accordion Styles */
      .test-detail-outer-accordion {
        border: 1px solid #ddd;
        border-radius: 8px;
        margin: 20px 0;
        overflow: hidden;
      }

      .test-detail-outer-summary {
        background-color: #f5f5f5;
        padding: 15px 20px;
        cursor: pointer;
        font-weight: 600;
        color: #333;
        border: none;
        outline: none;
        user-select: none;
        list-style: none;
        position: relative;
        transition: background-color 0.2s;
      }

      .test-detail-outer-summary::-webkit-details-marker {
        display: none;
      }

      .test-detail-outer-summary::after {
        content: "+";
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 18px;
        font-weight: bold;
        color: #666;
      }

      .test-detail-outer-accordion[open] .test-detail-outer-summary::after {
        content: "−";
      }

      .test-detail-outer-summary:hover {
        background-color: #ebebeb;
      }

      .test-detail-outer-content {
        padding: 20px;
        background-color: white;
        border-top: 1px solid #ddd;
      }
    </style>

    ' as html;


          -- end
    
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
      '**Geography**: US \n
      **Source**: Department of Defense (DoD) \n
      **Cybersecurity Maturity Model Certification (CMMC) - Level 1 (Foundational)** \n
      **Version**: 2.0 \n
      **Published/Last Reviewed Date/Year**: 2021-11-04 00:00:00+00' AS description_md, 
      ${this.absoluteURL("/ce/regime/cmmc_level.sql?level=1")} AS link
    UNION
    SELECT
      'CMMC Model 2.0 LEVEL 2' AS title,
      '**Geography**: US \n
      **Source**: Department of Defense (DoD) \n
      **Cybersecurity Maturity Model Certification (CMMC) - Level 2 (Advanced)** \n
      **Version**: 2.0 \n
      **Published/Last Reviewed Date/Year**: 2021-11-04 00:00:00+00' AS description_md, 
      ${this.absoluteURL("/ce/regime/cmmc_level.sql?level=2")}
    UNION
    SELECT
      'CMMC Model 2.0 LEVEL 3' AS title,
      '**Geography**: US \n
      **Source**: Department of Defense (DoD) \n
      **Cybersecurity Maturity Model Certification (CMMC) - Level 3 (Expert)** \n
      **Version**: 2.0 \n
      **Published/Last Reviewed Date/Year**: 2021-11-04 00:00:00+00' AS description_md, 
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
    SELECT 'Controls' AS title, ${
      this.absoluteURL("/ce/regime/index.sql")
    } AS link;
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
|| '&fiiid=' || replace(control_code, ' ', '%20')
|| '&level=' || @level
|| ')' AS "Control Code",

      scf_domain       AS "Domain",
      scf_control      AS "Title",
      control_code     AS "FII ID",
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
  SELECT 'Controls' AS title, ${
      this.absoluteURL("/ce/regime/index.sql")
    } AS link;
  SELECT 'CMMC' AS title, ${this.absoluteURL("/ce/regime/cmmc.sql")} AS link;
  SELECT 'CMMC Level ' || COALESCE($level::TEXT, '') AS title, ${
      this.absoluteURL("/ce/regime/cmmc_level.sql?level=")
    } || COALESCE($level::TEXT,'1') AS link;
  SELECT COALESCE($code, '') AS title, '#' AS link;

  

  --- Primary details card
  SELECT 'card' AS component, 'CMMC Control Details' AS title, 1 AS columns;
  SELECT
      COALESCE($code, '(unknown)') AS title,
      '**Control Question:** ' || COALESCE(control_question, '') || '  \n\n' ||
      '**Control Description:** ' || COALESCE(control_description, '') || '  \n\n' ||
      '**SCF Domain:** ' || COALESCE(scf_domain, '') || '  \n\n' ||
      '**SCF Control:** ' || COALESCE(scf_control, '') || '  \n\n' ||
      '**FII IDs:** ' || COALESCE($fiiid, '') AS description_md
      
  FROM scf_view
  WHERE
       ( ($level = 1 AND replace(replace(cmmc_level_1,'\n',' '),'\\r','') = $code)
    OR ($level = 2 AND replace(replace(cmmc_level_2,'\n',' '),'\\r','') = $code)
    OR ($level = 3 AND replace(replace(cmmc_level_3,'\n',' '),'\\r','') = $code))
    AND control_code = $fiiid
  LIMIT 1;

  -- TODO Placeholder Card
  SELECT
    'card' AS component,
    1 AS columns;

  -- Policy Generator Prompt Accordion
  SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: ' || $code || '</b> &mdash; <b>Level: ' || $level || '</b>.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">' AS html;

  SELECT 'card' as component, 1 as columns;
  SELECT
    '\n' || p.body_text AS description_md
    FROM ai_ctxe_compliance_prompt p
   
    WHERE p.control_id = $code AND  p.documentType = 'Author Prompt' AND p.fii_id=$fiiid
    AND (
    ($level = 1 AND regime = 'CMMC' AND category_type='Level 1') OR
    ($level = 2 AND regime = 'CMMC' AND category_type='Level 2') OR
    ($level = 3 AND regime = 'CMMC' AND category_type='Level 3')
    );
   

  SELECT 'html' AS component,
    '</div></details>' AS html;

  -- Policy Audit Prompt Accordion
  SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">' AS html;

  SELECT 'card' as component, 1 as columns;
  SELECT
    '\n' || p.body_text AS description_md
    FROM ai_ctxe_compliance_prompt p
    WHERE p.control_id = $code AND p.documentType = 'Audit Prompt' AND p.fii_id=$fiiid AND
   ( 
    ($level = 1 AND regime = 'CMMC' AND category_type='Level 1') OR
    ($level = 2 AND regime = 'CMMC' AND category_type='Level 2') OR
    ($level = 3 AND regime = 'CMMC' AND category_type='Level 3')
    );

  SELECT 'html' AS component,
    '</div></details>' AS html;

  -- Generated Policies Accordion
  SELECT 'html' AS component,
  '<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">' AS html;

  SELECT 'card' as component, 1 as columns;
  SELECT
    '\n' || p.body_text AS description_md
    FROM ai_ctxe_policy p
    WHERE p.control_id = $code AND p.fii_id=$fiiid
    
    AND 
    (($level = 1 AND regimeType = 'CMMC' AND category_type='Level 1') OR
    ($level = 2 AND regimeType = 'CMMC' AND category_type='Level 2') OR
    ($level = 3 AND regimeType = 'CMMC' AND category_type='Level 3')
    );

  SELECT 'html' AS component,
    '</div></details>' AS html;

  -- CSS Styles
  SELECT 'html' as component,
  '<style>
      tr.actualClass-passed td.State {
          color: green !important;
      }
       tr.actualClass-failed td.State {
          color: red !important;
      }
        tr.actualClass-passed td.Statealign-middle {
          color: green !important;
      }
        tr.actualClass-failed td.Statealign-middle {
          color: red !important;
      }
      
      .btn-list {
      display: flex;
      justify-content: flex-end;
      }
     h2.accordion-header button {
      font-weight: 700;
    }

    /* Test Detail Outer Accordion Styles */
    .test-detail-outer-accordion {
      border: 1px solid #ddd;
      border-radius: 8px;
      margin: 20px 0;
      overflow: hidden;
    }

    .test-detail-outer-summary {
      background-color: #f5f5f5;
      padding: 15px 20px;
      cursor: pointer;
      font-weight: 600;
      color: #333;
      border: none;
      outline: none;
      user-select: none;
      list-style: none;
      position: relative;
      transition: background-color 0.2s;
    }

    .test-detail-outer-summary::-webkit-details-marker {
      display: none;
    }

    .test-detail-outer-summary::after {
      content: "+";
      position: absolute;
      right: 20px;
      top: 50%;
      transform: translateY(-50%);
      font-size: 18px;
      font-weight: bold;
      color: #666;
    }

    .test-detail-outer-accordion[open] .test-detail-outer-summary::after {
      content: "−";
    }

    .test-detail-outer-summary:hover {
      background-color: #ebebeb;
    }

    .test-detail-outer-content {
      padding: 20px;
      background-color: white;
      border-top: 1px solid #ddd;
    }
  </style>' as html;

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

/**
 * Generate the SQL notebook pages for the "Compliance Explorer" pattern.
 *
 * This asynchronous helper delegates to spn.TypicalSqlPageNotebook.spry, constructing
 * the shell and pattern-specific page providers:
 * - a ShellSqlPages instance initialized with SQE_TITLE, SQE_LOGO, and SQE_FAV_ICON
 * - a ComplianceExplorerSqlPages instance for pattern-specific pages
 *
 * @param srcDir - The root source directory used when generating the SQL pages; typically
 *                 the workspace or repository path containing pattern assets.
 * @returns A promise that resolves with the value returned by
 *          spn.TypicalSqlPageNotebook.spry. The resolved value depends on the underlying
 *          TypicalSqlPageNotebook implementation.
 * @throws Will reject if the underlying TypicalSqlPageNotebook.spry call fails (e.g.,
 *         file system errors, invalid input, or generation failures).
 */
export async function spry(srcDir: string) {
  return await spn.TypicalSqlPageNotebook.spry(
    srcDir,
    new sh.ShellSqlPages(SQE_TITLE, SQE_LOGO, SQE_FAV_ICON),
    new ComplianceExplorerSqlPages(),
  );
}
// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await controlSQL()).join("\n"));
  await spry("src");
}
