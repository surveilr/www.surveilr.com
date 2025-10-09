-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
DROP VIEW IF EXISTS compliance_regime_control;
CREATE VIEW compliance_regime_control AS
SELECT `SCF Domain` AS scf_domain,
`SCF Control` AS scf_control,
`Secure Controls Framework (SCF) Control Description` AS control_description,
`SCF Control Question` AS control_question,
"SCF #" AS control_code,
`US HIPAA` AS control_id,
'US HIPAA' AS control_type
FROM uniform_resource_scf_2024_2 WHERE `US HIPAA` !=''
UNION
SELECT `SCF Domain` AS scf_domain,
`SCF Control` AS scf_control,
`Secure Controls Framework (SCF) Control Description` AS control_description,
`SCF Control Question` AS control_question,
"SCF #" AS control_code,
`NIST 800-171A rev 3` AS control_id,
'NIST' AS control_type
FROM uniform_resource_scf_2024_2 WHERE `NIST 800-171A rev 3` !='';


DROP VIEW IF EXISTS scf_view;

DROP VIEW IF EXISTS scf_view;

CREATE VIEW scf_view AS
SELECT 
    'SCF-' || ROWID AS control_identifier,
    "SCF Domain" AS scf_domain,
    "SCF Control" AS scf_control,
    "SCF #" AS control_code,
    "Secure Controls Framework (SCF) Control Description" AS control_description,
    "SCF Control Question" AS control_question,
    "US CMMC 2.0 Level 1" AS cmmc_level_1,
    "US CMMC 2.0 Level 2" AS cmmc_level_2,
    "US CMMC 2.0 Level 3" AS cmmc_level_3
FROM uniform_resource_scf_2024_2;

DROP VIEW IF EXISTS ai_ctxe_policy;
CREATE VIEW ai_ctxe_policy AS
SELECT DISTINCT
  ur.uniform_resource_id,
  json_extract(ur.frontmatter, '$.title') AS title,
  json_extract(ur.frontmatter, '$.description') AS description,
  json_extract(ur.frontmatter, '$.publishDate') AS publishDate,
  json_extract(ur.frontmatter, '$.publishBy') AS publishBy,
  json_extract(ur.frontmatter, '$.classification') AS classification,
  json_extract(ur.frontmatter, '$.documentType') AS documentType,
  json_extract(ur.frontmatter, '$.approvedBy') AS approvedBy,
  json_extract(ur.frontmatter, '$.category') AS category,
  json_extract(ur.frontmatter, '$.control-id') AS control_id,
  json_extract(ur.frontmatter, '$.regimeType') AS regimeType,
  json_extract(ur.frontmatter, '$.category[1]') AS category_type,
  json_extract(ur.frontmatter,'$.fiiId') AS fii_id,
 
  TRIM(
    CASE
      WHEN instr(ur.content, '---') = 1
        THEN substr(
          ur.content,
          instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
        )
      ELSE ur.content
    END
  ) AS body_text
FROM
  uniform_resource ur
JOIN
  ur_ingest_session_fs_path_entry fs
    ON fs.uniform_resource_id = ur.uniform_resource_id

WHERE
  fs.file_basename LIKE '%.policy.md';

DROP VIEW IF EXISTS compliance_regime_control_soc2;

CREATE VIEW compliance_regime_control_soc2 AS
SELECT
  "#" AS control_code,
  "Control Identifier" AS control_id,
  "Fii ID" AS fii_id,
  "Common Criteria" AS common_criteria,
  "Common Criteria type" AS criteria_type,
  Name AS control_name,
  "Questions Descriptions" AS control_question,
  'AICPA SOC 2' AS control_type,
  tenant_id,
  tenant_name
FROM uniform_resource_aicpa_soc2_controls
WHERE "Control Identifier" IS NOT NULL AND "Control Identifier" != '';


DROP VIEW IF EXISTS compliance_regime_control_hitrust_e1;

CREATE VIEW compliance_regime_control_hitrust_e1 AS
SELECT
  "#" AS control_code,
  "Control Identifier" AS control_id,
  "Fii ID" AS fii_id,
  "Common Criteria" AS common_criteria,
  NULL AS criteria_type, -- not available in this table
  Name AS control_name,
  Description AS control_question,
  'HITRUST E1' AS control_type,
  tenant_id,
  tenant_name
FROM uniform_resource_hitrust_e1_assessment
WHERE "Control Identifier" IS NOT NULL 
  AND "Control Identifier" != '';

DROP VIEW IF EXISTS compliance_iso_27001_control;

CREATE VIEW compliance_iso_27001_control AS
SELECT 
    `SCF Domain` AS scf_domain,
    `SCF Control` AS scf_control,
    `SCF #` AS control_code,
    `Secure Controls Framework (SCF)
Control Description` AS control_description,
    `SCF Control Question` AS control_question,
    Evidence AS evidence,
    tenant_id,
    tenant_name,
    'ISO 27001 v3' AS control_type
FROM uniform_resource_iso_27001_v3;

DROP VIEW IF EXISTS hipaa_security_rule_safeguards;
CREATE VIEW hipaa_security_rule_safeguards AS
SELECT
    "#" AS id,
    "Common Criteria" AS common_criteria,
    "HIPAA Security Rule Reference" AS hipaa_security_rule_reference,
    Safeguard AS safeguard,
    "Handled by nQ" AS handled_by_nq,
    "FII Id" AS fii_id,
    tenant_id,
    tenant_name
FROM uniform_resource_hipaa_security_rule_safeguards;
 
DROP VIEW IF EXISTS compliance_regime_thsa;
CREATE VIEW compliance_regime_thsa AS
SELECT
   "#" AS id,
  `SCF Domain` AS scf_domain,
  `SCF Control` AS scf_control,
  `SCF Control Question` AS scf_control_question,
  "SCF #" AS scf_code,
  "Your Answer" AS your_answer,
  tenant_id,
  tenant_name
FROM uniform_resource_thsa;


DROP VIEW IF EXISTS aicpa_soc2_type2_controls;
CREATE VIEW aicpa_soc2_type2_controls AS
SELECT
    "#" AS id,
    "Control Identifier" AS control_id,
    "Fii ID" AS fii_id,
    "Common Criteria" AS common_criteria,
    "Common Criteria type" AS criteria_type,
    Name AS control_name,
    "Questions Descriptions" AS control_question,
    tenant_id,
    tenant_name
FROM uniform_resource_aicpa_soc2_type2_controls;

--###view for complaince explorer prompts #####-------

DROP VIEW IF EXISTS ai_ctxe_compliance_prompt;
CREATE VIEW ai_ctxe_compliance_prompt AS
SELECT DISTINCT
  ur.uniform_resource_id,
  json_extract(ur.frontmatter, '$.title') AS title,
  json_extract(ur.frontmatter, '$.description') AS description,
  json_extract(ur.frontmatter, '$.publishDate') AS publishDate,
  json_extract(ur.frontmatter, '$.publishBy') AS publishBy,
  json_extract(ur.frontmatter, '$.classification') AS classification,
  json_extract(ur.frontmatter, '$.documentType') AS documentType,
  json_extract(ur.frontmatter, '$.approvedBy') AS approvedBy,
  json_extract(ur.frontmatter, '$.category') AS category,
  json_extract(ur.frontmatter, '$.control-id') AS control_id,
  json_extract(ur.frontmatter, '$.regimeType') AS regime,
  json_extract(ur.frontmatter, '$.category[1]') AS category_type,
  json_extract(ur.frontmatter,'$.fiiId') AS fii_id,

  TRIM(
    CASE
      WHEN instr(ur.content, '---') = 1
        THEN substr(
          ur.content,
          instr(ur.content, '---') + 3 + instr(substr(ur.content, instr(ur.content, '---') + 3), '---') + 3
        )
      ELSE ur.content
    END
  ) AS body_text
FROM
  uniform_resource ur
JOIN
  ur_ingest_session_fs_path_entry fs
    ON fs.uniform_resource_id = ur.uniform_resource_id

WHERE
  fs.file_basename LIKE '%.prompt.md'
  AND json_extract(ur.frontmatter, '$.regimeType') IS NOT NULL;;



--###view for all controls details complaince explorer #####-------

DROP VIEW IF EXISTS all_control;

CREATE VIEW all_control AS
    SELECT
    (SELECT COUNT(*)
     FROM uniform_resource_scf_2024_2 AS sub
     WHERE sub.ROWID <= cntl.ROWID
       AND "US CMMC 2.0 Level 1" != '') AS display_order,
    'CMMCLEVEL-' || ROWID AS control_identifier,
    cntl."US CMMC 2.0 Level 1" AS control_code,
    cntl."SCF #" AS fii,
    cntl."SCF Domain" AS common_criteria,
    '' AS expected_evidence,
    cntl."SCF Control Question" AS question,
    'CMMC Model 2.0 Level 1' AS control_type,
    12 AS control_type_id,
    6 AS control_compliance_id
FROM uniform_resource_scf_2024_2 AS cntl
WHERE cntl."US CMMC 2.0 Level 1" != ''
 
UNION ALL
SELECT
    (SELECT COUNT(*)
     FROM uniform_resource_scf_2024_2 AS sub
     WHERE sub.ROWID <= cntl.ROWID
       AND "US CMMC 2.0 Level 2" != '') AS display_order,
    'CMMCLEVEL-' || ROWID AS control_identifier,
    cntl."US CMMC 2.0 Level 2" AS control_code,
    cntl."SCF #" AS fii,
    cntl."SCF Domain" AS common_criteria,
    '' AS expected_evidence,
    cntl."SCF Control Question" AS question,
    'CMMC Model 2.0 Level 2' AS control_type,
    13 AS control_type_id,
    7 AS control_compliance_id
FROM uniform_resource_scf_2024_2 AS cntl
WHERE cntl."US CMMC 2.0 Level 2" != ''
 
UNION ALL
SELECT
    (SELECT COUNT(*)
     FROM uniform_resource_scf_2024_2 AS sub
     WHERE sub.ROWID <= cntl.ROWID
       AND "US CMMC 2.0 Level 3" != '') AS display_order,
    'CMMCLEVEL-' || ROWID AS control_identifier,
    cntl."US CMMC 2.0 Level 3" AS control_code,
    cntl."SCF #" AS fii,
    cntl."SCF Domain" AS common_criteria,
    '' AS expected_evidence,
    cntl."SCF Control Question" AS question,
    'CMMC Model 2.0 Level 3' AS control_type,
    14 AS control_type_id,
    8 AS control_compliance_id
FROM uniform_resource_scf_2024_2 AS cntl
WHERE cntl."US CMMC 2.0 Level 3" != ''
 
UNION ALL
 
SELECT
            CAST(cntl."#" AS INTEGER) AS display_order,
            cntl."HIPAA Security Rule Reference" AS control_identifier,
            cntl."HIPAA Security Rule Reference" AS control_code,
            cntl."FII Id" AS fii,
            cntl."Common Criteria" AS common_criteria,
            '' AS expected_evidence,
            cntl.Safeguard AS question,
            'HIPAA' AS control_type,
            0 AS control_type_id,
            1 AS control_compliance_id        
          FROM uniform_resource_hipaa_security_rule_safeguards cntl
          
UNION ALL
SELECT
            CAST(cntl."#" AS INTEGER) AS display_order,
            cntl."Control Identifier" AS control_identifier,
            cntl."Control Identifier" AS control_code,
            cntl."Fii ID" AS fii,
            cntl."Common Criteria" AS common_criteria,
            cntl."Name" AS expected_evidence,
            cntl.Description AS question,
            'HITRUST' AS control_type,
            0 AS control_type_id,
            5 AS control_compliance_id  
          FROM uniform_resource_hitrust_e1_assessment cntl
          
UNION ALL
SELECT
            (SELECT COUNT(*)
            FROM uniform_resource_iso_27001_v3 AS sub
            WHERE sub.ROWID <= cntl.ROWID) AS display_order,
            'ISO-27001-' || (ROWID) as control_identifier,
             cntl."SCF #" AS control_code,
             cntl."SCF #" AS fii,
             cntl."SCF Domain" AS common_criteria,
             Evidence as expected_evidence,
             cntl."SCF Control Question" AS question,
             'ISO 27001:2022' AS control_type,
            0 AS control_type_id,
             9 AS control_compliance_id          
        FROM uniform_resource_iso_27001_v3 as cntl
UNION ALL
SELECT
        CAST(cntl."#" AS INTEGER) AS display_order,
        cntl."Control Identifier" AS control_identifier,
        cntl."Control Identifier" AS control_code,
        cntl."Fii ID" AS fii,
        cntl."Common Criteria" AS common_criteria,
        cntl."Name" AS expected_evidence,
        cntl."Questions Descriptions" AS question,
        'SOC2 Type I' AS control_type,
        2 AS control_type_id,
        3 AS control_compliance_id
    FROM uniform_resource_aicpa_soc2_controls cntl
    UNION ALL
    SELECT
        CAST(cntl."#" AS INTEGER),
        cntl."Control Identifier",
        cntl."Control Identifier",
        cntl."Fii ID",
        cntl."Common Criteria",
        cntl."Name",
        cntl."Questions Descriptions",
        'SOC2 Type II' AS control_type,
        3 AS control_type_id,
        4 AS control_compliance_id  
    FROM uniform_resource_aicpa_soc2_type2_controls cntl;


--###view for cmmc controls details complaince explorer #####-------

DROP VIEW IF EXISTS cmmc_control;

CREATE VIEW cmmc_control AS
    SELECT
    (SELECT COUNT(*)
     FROM uniform_resource_scf_2024_2 AS sub
     WHERE sub.ROWID <= cntl.ROWID
       AND "US CMMC 2.0 Level 1" != '') AS display_order,
    'CMMCLEVEL-' || ROWID AS control_identifier,
    cntl."US CMMC 2.0 Level 1" AS control_code,
    cntl."SCF #" AS fii,
    cntl."SCF Domain" AS common_criteria,
    '' AS expected_evidence,
    cntl."SCF Control Question" AS question,
    'CMMC Model 2.0 Level 1' AS control_type,
    12 AS control_type_id
FROM uniform_resource_scf_2024_2 AS cntl
WHERE cntl."US CMMC 2.0 Level 1" != ''
 
UNION ALL
SELECT
    (SELECT COUNT(*)
     FROM uniform_resource_scf_2024_2 AS sub
     WHERE sub.ROWID <= cntl.ROWID
       AND "US CMMC 2.0 Level 2" != '') AS display_order,
    'CMMCLEVEL-' || ROWID AS control_identifier,
    cntl."US CMMC 2.0 Level 2" AS control_code,
    cntl."SCF #" AS fii,
    cntl."SCF Domain" AS common_criteria,
    '' AS expected_evidence,
    cntl."SCF Control Question" AS question,
    'CMMC Model 2.0 Level 2' AS control_type,
    13 AS control_type_id
FROM uniform_resource_scf_2024_2 AS cntl
WHERE cntl."US CMMC 2.0 Level 2" != ''
 
UNION ALL
SELECT
    (SELECT COUNT(*)
     FROM uniform_resource_scf_2024_2 AS sub
     WHERE sub.ROWID <= cntl.ROWID
       AND "US CMMC 2.0 Level 3" != '') AS display_order,
    'CMMCLEVEL-' || ROWID AS control_identifier,
    cntl."US CMMC 2.0 Level 3" AS control_code,
    cntl."SCF #" AS fii,
    cntl."SCF Domain" AS common_criteria,
    '' AS expected_evidence,
    cntl."SCF Control Question" AS question,
    'CMMC Model 2.0 Level 3' AS control_type,
    14 AS control_type_id
FROM uniform_resource_scf_2024_2 AS cntl
WHERE cntl."US CMMC 2.0 Level 3" != '';


--###view for hipaa controls details complaince explorer #####-------

DROP VIEW IF EXISTS hipaa_control;

CREATE VIEW hipaa_control AS
   SELECT
            CAST(cntl."#" AS INTEGER) AS display_order,
            cntl."HIPAA Security Rule Reference" AS control_identifier,
            cntl."HIPAA Security Rule Reference" AS control_code,
            cntl."FII Id" AS fii,
            cntl."Common Criteria" AS common_criteria,
            '' AS expected_evidence,
            cntl.Safeguard AS question            
          FROM uniform_resource_hipaa_security_rule_safeguards cntl;


--###view for hitrust controls details complaince explorer #####-------

DROP VIEW IF EXISTS hitrust_control;

CREATE VIEW hitrust_control as
SELECT
            CAST(cntl."#" AS INTEGER) AS display_order,
            cntl."Control Identifier" AS control_identifier,
            cntl."Control Identifier" AS control_code,
            cntl."Fii ID" AS fii,
            cntl."Common Criteria" AS common_criteria,
            cntl."Name" AS expected_evidence,
            cntl.Description AS question
          FROM uniform_resource_hitrust_e1_assessment cntl;


--###view for iso27001 controls details complaince explorer #####-------

DROP VIEW IF EXISTS iso27001_control;

CREATE VIEW iso27001_control AS    
SELECT
            (SELECT COUNT(*)
            FROM uniform_resource_iso_27001_v3 AS sub
            WHERE sub.ROWID <= cntl.ROWID) AS display_order,
            'ISO-27001-' || (ROWID) as control_identifier,
             cntl."SCF #" AS control_code,
             cntl."SCF #" AS fii,
             cntl."SCF Domain" AS common_criteria,
             Evidence as expected_evidence,
             cntl."SCF Control Question" AS question            
        FROM uniform_resource_iso_27001_v3 as cntl;


--###view for soc2 controls details complaince explorer #####-------

DROP VIEW IF EXISTS soc2_control;

CREATE VIEW soc2_control AS
    SELECT
        CAST(cntl."#" AS INTEGER) AS display_order,
        cntl."Control Identifier" AS control_identifier,
        cntl."Control Identifier" AS control_code,
        cntl."Fii ID" AS fii,
        cntl."Common Criteria" AS common_criteria,
        cntl."Name" AS expected_evidence,
        cntl."Questions Descriptions" AS question,
        'SOC2 Type I' AS control_type,
        2 AS control_type_id
    FROM uniform_resource_aicpa_soc2_controls cntl
    UNION ALL
    SELECT
        CAST(cntl."#" AS INTEGER),
        cntl."Control Identifier",
        cntl."Control Identifier",
        cntl."Fii ID",
        cntl."Common Criteria",
        cntl."Name",
        cntl."Questions Descriptions",
        'SOC2 Type II' AS control_type,
        3 AS control_type_id
    FROM uniform_resource_aicpa_soc2_type2_controls cntl;       
-- Drop the table if it exists, then create the new table with auto-increment primary key
DROP TABLE IF EXISTS "compliance_regime";
CREATE TABLE "compliance_regime" (
"compliance_regime_id" INTEGER PRIMARY KEY AUTOINCREMENT,
"parent_id" TEXT NOT NULL,
"title" TEXT NOT NULL,
"geography" TEXT,
"source" TEXT,
"description" TEXT,
"logo" TEXT,
"status" TEXT,
"version" TEXT,
"last_reviewed_date" TIMESTAMPTZ,
"authoritative_source" TEXT,
"custom_user_text" TEXT,
"elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
"created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
"created_by" TEXT DEFAULT 'UNKNOWN',
"updated_at" TIMESTAMPTZ,
"updated_by" TEXT,
"deleted_at" TIMESTAMPTZ,
"deleted_by" TEXT,
"activity_log" TEXT
);
-- Insert records into the table
INSERT INTO "compliance_regime" (
"parent_id",    
"title",
"geography",
"source",
"description",
"logo",
"status",
"version",
"last_reviewed_date",
"authoritative_source",
"custom_user_text"
)
VALUES
(
'',
'HIPAA',
'US',
'Federal',
'Health Insurance Portability and Accountability Act',
'',
'active',
'N/A',
'2022-10-20 00:00:00+00',
'Health Insurance Portability and Accountability Act (HIPAA)',
'Below, you will find a complete list of all controls applicable to the US HIPAA framework. These controls are designed ' ||
'to ensure compliance with the Health Insurance Portability and Accountability Act (HIPAA) standards, safeguarding ' ||
'sensitive patient health information'
),
(
'',
'NIST',
'Universal',
'SCF',
'Comprehensive cybersecurity guidance framework',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),
(
'10',
'SOC2 Type I',
'US',
'SCF',
'Report on Controls as a Service Organization. Relevant to Security, Availability, Processing Integrity, Confidentiality, or Privacy.',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'10',
'SOC2 Type II',
'US',
'SCF',
'SOC 2 Type II reports provide lists of Internal controls that are audited by an Independent third-party to show how well those controls are implemented and operating.',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'',
'HITRUST CSF',
'US',
'SCF',
'Achieve HITRUST CSF certification, the most trusted and comprehensive security framework in healthcare.',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'15',
'CMMC Model 2.0 LEVEL 1',
'US',
'SCF',
'Achieve Cybersecurity Maturity Model Certification (CMMC) to bid on Department of Defense contracts',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'15',
'CMMC Model 2.0 LEVEL 2',
'US',
'SCF',
'110 requirements aligned with NIST SP 800-171; Triennial third-party assessment & annual affirmation; Triennial self-assessment & annual affirmation for select programs. A subset of programs with Level 2 requirements do not involve information critical to national security, and associated contractors will be permitted to meet the requirement through self-assessments. Contractors will be required to conduct self-assessment on an annual basis, accompanied by an annual affirmation from a senior company official that the company is meeting requirements. The Department intends to require companies to register self-assessments and affirmations in the Supplier Performance Risk System (SPRS).',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'15',
'CMMC Model 2.0 LEVEL 3',
'US',
'SCF',
'110+ requirements based on NIST SP 800-171 & 800-172; Triennial government-led assessment & annual affirmation. The Department intends for Level 3 cybersecurity requirements to be assessed by government officials. Assessment requirements are currently under development. Level 3 information will likewise be posted as it becomes available.',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'14',
'ISO 27001:2022',
'US',
'SCF',
'Information security management systems standard',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'',
'AICPA',
'US',
'Federal',
'AICPA is the national professional organization for Certified Public Accountants (CPAs) in the United States.',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'5',
'HiTRUST e1 Assessment',
'US',
'Federal',
'HITRUST e1 Essentials Assessment Adds Efficiency and Flexibility to the HITRUST Portfolio.',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'5',
'HiTRUST i1 Assessment',
'US',
'Federal',
'HITRUST i1 Leading Security Practices Assessment Delivers Broad and Reliable Assurances Against Current and Emerging Cyber Threats.',
'',
'inactive',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'5',
'HiTRUST r2 Assessment',
'US',
'Federal',
'HITRUST r2 Expanded Practices Assessment is the Industry-Recognized Gold Standard for Providing the Highest Level of Information Protection and Compliance Assurance.',
'',
'inactive',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'',
'ISO',
'US',
'Federal',
'ISO/IEC refers to a joint collaboration between the International Organization for Standardization (ISO) and the International Electrotechnical Commission (IEC).',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'',
'Cybersecurity Maturity Model Certification (CMMC)',
'US',
'Federal',
'The Cybersecurity Maturity Model Certification (CMMC) program aligns with the information security requirements of the U.S. Department of Defense (DoD) for Defense Industrial Base (DIB) partners',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
),(
'14',
'ISO 42001',
'US',
'SCF',
'ISO/IEC 42001 is the first international management system standard for AI, designed to promote responsible AI development and use by setting requirements for establishing, implementing, maintaining, and continually improving an Artificial Intelligence Management System (AIMS).',
'',
'active',
'2024',
'2024-04-01 00:00:00+00',
'800-53 rev4',
NULL
);

-- delete all /fhir-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like 'ur%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'ur/index.sql', 'ur/index.sql', 'Uniform Resource', NULL, NULL, 'Explore ingested resources', NULL),
    ('prime', 'ur/index.sql', 99, 'ur/info-schema.sql', 'ur/info-schema.sql', 'Uniform Resource Tables and Views', NULL, NULL, 'Information Schema documentation for ingested Uniform Resource database objects', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-files.sql', 'ur/uniform-resource-files.sql', 'Uniform Resources (Files)', NULL, NULL, 'Files ingested into the `uniform_resource` table', NULL),
    ('prime', 'ur/index.sql', 1, 'ur/uniform-resource-imap-account.sql', 'ur/uniform-resource-imap-account.sql', 'Uniform Resources (IMAP)', NULL, NULL, 'Easily access and view your emails with our Uniform Resource (IMAP) system. Ingested from various mail sources, this feature organizes and displays your messages directly in the Web UI, ensuring all your communications are available in one convenient place.', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
DROP VIEW IF EXISTS uniform_resource_file;
CREATE VIEW uniform_resource_file AS
  SELECT ur.uniform_resource_id,
         ur.nature,
         p.root_path AS source_path,
         pe.file_path_rel,
         ur.size_bytes
  FROM uniform_resource ur
  LEFT JOIN uniform_resource_edge ure ON ur.uniform_resource_id = ure.uniform_resource_id AND ure.nature = 'ingest_fs_path'
  LEFT JOIN ur_ingest_session_fs_path p ON ure.node_id = p.ur_ingest_session_fs_path_id
  LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id;

  DROP VIEW IF EXISTS uniform_resource_imap;
  CREATE VIEW uniform_resource_imap AS
  SELECT
      ur.uniform_resource_id,
      graph.name,
      iac.ur_ingest_session_imap_account_id,
      iac.email,
      iac.host,
      iacm.subject,
      iacm."from",
      iacm.message,
      iacm.date,
      iaf.ur_ingest_session_imap_acct_folder_id,
      iaf.ingest_account_id,
      iaf.folder_name,
      ur.size_bytes,
      ur.nature,
      ur.content
  FROM uniform_resource ur
  INNER JOIN uniform_resource_edge edge ON edge.uniform_resource_id=ur.uniform_resource_id
  INNER JOIN uniform_resource_graph graph ON graph.name=edge.graph_name
  INNER JOIN ur_ingest_session_imap_acct_folder_message iacm ON iacm.ur_ingest_session_imap_acct_folder_message_id = edge.node_id
  INNER JOIN ur_ingest_session_imap_acct_folder iaf ON iacm.ingest_imap_acct_folder_id = iaf.ur_ingest_session_imap_acct_folder_id
  LEFT JOIN ur_ingest_session_imap_account iac ON iac.ur_ingest_session_imap_account_id = iaf.ingest_account_id
  WHERE ur.nature = 'text' AND graph.name='imap' AND ur.ingest_session_imap_acct_folder_message IS NOT NULL;

  DROP VIEW IF EXISTS uniform_resource_imap_content;
  CREATE  VIEW uniform_resource_imap_content AS
  SELECT
      uri.uniform_resource_id,
      base_ur.uniform_resource_id baseID,
      ext_ur.uniform_resource_id extID,
      base_ur.uri as base_uri,
      ext_ur.uri as ext_uri,
      base_ur.nature as base_nature,
      ext_ur.nature as ext_nature,
      json_extract(part.value, '$.body.Html') AS html_content
  FROM
      uniform_resource_imap uri
  INNER JOIN uniform_resource base_ur ON base_ur.uniform_resource_id=uri.uniform_resource_id
  INNER JOIN uniform_resource ext_ur ON ext_ur.uri = base_ur.uri ||'/json' AND ext_ur.nature = 'json',
  json_each(ext_ur.content, '$.parts') AS part
  WHERE ext_ur.nature = 'json' AND html_content NOT NULL;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats" AS
    WITH Summary AS (
        SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_fs_path_entry.file_extn, '') AS file_extension,
            ur_ingest_session_fs_path.ur_ingest_session_fs_path_id as ingest_session_fs_path_id,
            ur_ingest_session_fs_path.root_path AS ingest_session_root_fs_path,
            COUNT(ur_ingest_session_fs_path_entry.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_fs_path ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_fs_path.ingest_session_id
        LEFT JOIN
            ur_ingest_session_fs_path_entry ON ur_ingest_session_fs_path.ur_ingest_session_fs_path_id = ur_ingest_session_fs_path_entry.ingest_fs_path_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_fs_path_entry.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_fs_path_entry.file_extn,
            ur_ingest_session_fs_path.root_path
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        file_extension,
        ingest_session_fs_path_id,
        ingest_session_root_fs_path,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        file_extension;
DROP VIEW IF EXISTS "ur_ingest_session_files_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_files_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_files_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats" AS
      WITH Summary AS (
          SELECT
            device.device_id AS device_id,
            ur_ingest_session.ur_ingest_session_id AS ingest_session_id,
            ur_ingest_session.ingest_started_at AS ingest_session_started_at,
            ur_ingest_session.ingest_finished_at AS ingest_session_finished_at,
            COALESCE(ur_ingest_session_task.ur_status, 'Ok') AS ur_status,
            COALESCE(uniform_resource.nature, 'UNKNOWN') AS nature,
            COUNT(ur_ingest_session_task.uniform_resource_id) AS total_file_count,
            SUM(CASE WHEN uniform_resource.content IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_content,
            SUM(CASE WHEN uniform_resource.frontmatter IS NOT NULL THEN 1 ELSE 0 END) AS file_count_with_frontmatter,
            MIN(uniform_resource.size_bytes) AS min_file_size_bytes,
            AVG(uniform_resource.size_bytes) AS average_file_size_bytes,
            MAX(uniform_resource.size_bytes) AS max_file_size_bytes,
            MIN(uniform_resource.last_modified_at) AS oldest_file_last_modified_datetime,
            MAX(uniform_resource.last_modified_at) AS youngest_file_last_modified_datetime
        FROM
            ur_ingest_session
        JOIN
            device ON ur_ingest_session.device_id = device.device_id
        LEFT JOIN
            ur_ingest_session_task ON ur_ingest_session.ur_ingest_session_id = ur_ingest_session_task.ingest_session_id
        LEFT JOIN
            uniform_resource ON ur_ingest_session_task.uniform_resource_id = uniform_resource.uniform_resource_id
        GROUP BY
            device.device_id,
            ur_ingest_session.ur_ingest_session_id,
            ur_ingest_session.ingest_started_at,
            ur_ingest_session.ingest_finished_at,
            ur_ingest_session_task.captured_executable
    )
    SELECT
        device_id,
        ingest_session_id,
        ingest_session_started_at,
        ingest_session_finished_at,
        ur_status,
        nature,
        total_file_count,
        file_count_with_content,
        file_count_with_frontmatter,
        min_file_size_bytes,
        CAST(ROUND(average_file_size_bytes) AS INTEGER) AS average_file_size_bytes,
        max_file_size_bytes,
        oldest_file_last_modified_datetime,
        youngest_file_last_modified_datetime
    FROM
        Summary
    ORDER BY
        device_id,
        ingest_session_finished_at,
        ur_status;
DROP VIEW IF EXISTS "ur_ingest_session_tasks_stats_latest";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_tasks_stats_latest" AS
    SELECT iss.*
      FROM ur_ingest_session_tasks_stats AS iss
      JOIN (  SELECT ur_ingest_session.ur_ingest_session_id AS latest_session_id
                FROM ur_ingest_session
            ORDER BY ur_ingest_session.ingest_finished_at DESC
               LIMIT 1) AS latest
        ON iss.ingest_session_id = latest.latest_session_id;
DROP VIEW IF EXISTS "ur_ingest_session_file_issue";
CREATE VIEW IF NOT EXISTS "ur_ingest_session_file_issue" AS
      SELECT us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics
        FROM ur_ingest_session_fs_path_entry ufs
        JOIN ur_ingest_session_fs_path usp ON ufs.ingest_fs_path_id = usp.ur_ingest_session_fs_path_id
        JOIN ur_ingest_session us ON usp.ingest_session_id = us.ur_ingest_session_id
       WHERE ufs.ur_status IS NOT NULL
    GROUP BY us.device_id,
             us.ur_ingest_session_id,
             usp.ur_ingest_session_fs_path_id,
             usp.root_path,
             ufs.ur_ingest_session_fs_path_entry_id,
             ufs.file_path_abs,
             ufs.ur_status,
             ufs.ur_diagnostics;
-- code provenance: `ConsoleSqlPages.infoSchemaDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

-- console_information_schema_* are convenience views
-- to make it easier to work than pragma_table_info.
-- select 'test' into absolute_url;
DROP VIEW IF EXISTS console_information_schema_table;
CREATE VIEW console_information_schema_table AS

SELECT
    tbl.name AS table_name,
    col.name AS column_name,
    col.type AS data_type,
    CASE WHEN col.pk = 1 THEN 'Yes' ELSE 'No' END AS is_primary_key,
    CASE WHEN col."notnull" = 1 THEN 'Yes' ELSE 'No' END AS is_not_null,
    col.dflt_value AS default_value,
    'console/info-schema/table.sql?name=' || tbl.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || tbl.name || ' (table) Schema](console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_full_md,
    'console/content/table/' || tbl.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || tbl.name || ' (table) Content](console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    tbl.sql as sql_ddl
FROM sqlite_master tbl
JOIN pragma_table_info(tbl.name) col
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with view-specific information
DROP VIEW IF EXISTS console_information_schema_view;
CREATE VIEW console_information_schema_view AS
SELECT
    vw.name AS view_name,
    col.name AS column_name,
    col.type AS data_type,
    '/console/info-schema/view.sql?name=' || vw.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || vw.name || ' (view) Schema](console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/view/' || vw.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content]($SITE_PREFIX_URL/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || vw.name || ' (view) Content](console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
    vw.sql as sql_ddl
FROM sqlite_master vw
JOIN pragma_table_info(vw.name) col
WHERE vw.type = 'view' AND vw.name NOT LIKE 'sqlite_%';

DROP VIEW IF EXISTS console_content_tabular;
CREATE VIEW console_content_tabular AS
  SELECT 'table' as tabular_nature,
         table_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_table
  UNION ALL
  SELECT 'view' as tabular_nature,
         view_name as tabular_name,
         info_schema_web_ui_path,
         info_schema_link_abbrev_md,
         info_schema_link_full_md,
         content_web_ui_path,
         content_web_ui_link_abbrev_md,
         content_web_ui_link_full_md
    FROM console_information_schema_view;

-- Populate the table with table column foreign keys
DROP VIEW IF EXISTS console_information_schema_table_col_fkey;
CREATE VIEW console_information_schema_table_col_fkey AS
SELECT
    tbl.name AS table_name,
    f."from" AS column_name,
    f."from" || ' references ' || f."table" || '.' || f."to" AS foreign_key
FROM sqlite_master tbl
JOIN pragma_foreign_key_list(tbl.name) f
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

-- Populate the table with table column indexes
DROP VIEW IF EXISTS console_information_schema_table_col_index;
CREATE VIEW console_information_schema_table_col_index AS
SELECT
    tbl.name AS table_name,
    pi.name AS column_name,
    idx.name AS index_name
FROM sqlite_master tbl
JOIN pragma_index_list(tbl.name) idx
JOIN pragma_index_info(idx.name) pi
WHERE tbl.type = 'table' AND tbl.name NOT LIKE 'sqlite_%';

DROP VIEW IF EXISTS rssd_statistics_overview;
CREATE VIEW rssd_statistics_overview AS
SELECT 
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024), 2) FROM pragma_page_count(), pragma_page_size()) AS db_size_mb,
    (SELECT ROUND(page_count * page_size / (1024.0 * 1024 * 1024), 4) FROM pragma_page_count(), pragma_page_size()) AS db_size_gb,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'table') AS total_tables,
    (SELECT COUNT(*) FROM sqlite_master WHERE type = 'index') AS total_indexes,
    (SELECT SUM(tbl_rows) FROM (
        SELECT name, 
              (SELECT COUNT(*) FROM sqlite_master sm WHERE sm.type='table' AND sm.name=t.name) AS tbl_rows
        FROM sqlite_master t WHERE type='table'
    )) AS total_rows,
    (SELECT page_size FROM pragma_page_size()) AS page_size,
    (SELECT page_count FROM pragma_page_count()) AS total_pages;

CREATE TABLE IF NOT EXISTS surveilr_table_size (
    table_name TEXT PRIMARY KEY,
    table_size_mb REAL
);
DROP VIEW IF EXISTS rssd_table_statistic;
CREATE VIEW rssd_table_statistic AS
SELECT 
    m.name AS table_name,
    (SELECT COUNT(*) FROM pragma_table_info(m.name)) AS total_columns,
    (SELECT COUNT(*) FROM pragma_index_list(m.name)) AS total_indexes,
    (SELECT COUNT(*) FROM pragma_foreign_key_list(m.name)) AS foreign_keys,
    (SELECT COUNT(*) FROM pragma_table_info(m.name) WHERE pk != 0) AS primary_keys,
    (SELECT table_size_mb FROM surveilr_table_size WHERE table_name = m.name) AS table_size_mb
FROM sqlite_master m
WHERE m.type = 'table';

-- Drop and create the table for storing navigation entries
-- for testing only: DROP TABLE IF EXISTS sqlpage_aide_navigation;
CREATE TABLE IF NOT EXISTS sqlpage_aide_navigation (
    path TEXT NOT NULL, -- the "primary key" within namespace
    caption TEXT NOT NULL, -- for human-friendly general-purpose name
    namespace TEXT NOT NULL, -- if more than one navigation tree is required
    parent_path TEXT, -- for defining hierarchy
    sibling_order INTEGER, -- orders children within their parent(s)
    url TEXT, -- for supplying links, if different from path
    title TEXT, -- for full titles when elaboration is required, default to caption if NULL
    abbreviated_caption TEXT, -- for breadcrumbs and other "short" form, default to caption if NULL
    description TEXT, -- for elaboration or explanation
    elaboration TEXT, -- optional attributes for e.g. { "target": "__blank" }
    -- TODO: figure out why Rusqlite does not allow this but sqlite3 does
    -- CONSTRAINT fk_parent_path FOREIGN KEY (namespace, parent_path) REFERENCES sqlpage_aide_navigation(namespace, path),
    CONSTRAINT unq_ns_path UNIQUE (namespace, parent_path, path)
);
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'console/%';
DELETE FROM sqlpage_aide_navigation WHERE path LIKE 'index.sql';

-- all @navigation decorated entries are automatically added to this.navigation
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', NULL, 1, 'index.sql', 'index.sql', 'Home', NULL, 'Resource Surveillance State Database (RSSD)', 'Welcome to Resource Surveillance State Database (RSSD)', NULL),
    ('prime', 'index.sql', 999, 'console/index.sql', 'console/index.sql', 'RSSD Console', 'Console', 'Resource Surveillance State Database (RSSD) Console', 'Explore RSSD information schema, code notebooks, and SQLPage files', NULL),
    ('prime', 'console/index.sql', 1, 'console/info-schema/index.sql', 'console/info-schema/index.sql', 'RSSD Information Schema', 'Info Schema', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/index.sql', 'console/sqlpage-files/index.sql', 'RSSD SQLPage Files', 'SQLPage Files', NULL, 'Explore RSSD SQLPage Files which govern the content of the web-UI', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-files/content.sql', 'console/sqlpage-files/content.sql', 'RSSD Data Tables Content SQLPage Files', 'Content SQLPage Files', NULL, 'Explore auto-generated RSSD SQLPage Files which display content within tables', NULL),
    ('prime', 'console/index.sql', 3, 'console/sqlpage-nav/index.sql', 'console/sqlpage-nav/index.sql', 'RSSD SQLPage Navigation', 'SQLPage Navigation', NULL, 'See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table', NULL),
    ('prime', 'console/index.sql', 2, 'console/notebooks/index.sql', 'console/notebooks/index.sql', 'RSSD Code Notebooks', 'Code Notebooks', NULL, 'Explore RSSD Code Notebooks which contain reusable SQL and other code blocks', NULL),
    ('prime', 'console/index.sql', 2, 'console/migrations/index.sql', 'console/migrations/index.sql', 'RSSD Lifecycle (migrations)', 'Migrations', NULL, 'Explore RSSD Migrations to determine what was executed and not', NULL),
    ('prime', 'console/index.sql', 2, 'console/about.sql', 'console/about.sql', 'Resource Surveillance Details', 'About', NULL, 'Detailed information about the underlying surveilr binary', NULL),
    ('prime', 'console/index.sql', 1, 'console/statistics/index.sql', 'console/statistics/index.sql', 'RSSD Statistics', 'Statistics', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation', NULL),
    ('prime', 'console/index.sql', 5, 'console/behavior/index.sql', 'console/behavior/index.sql', 'Behavior Configuration', 'Behavior', NULL, 'Explore behavior configurations and presets used to drive application operations at runtime', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;

INSERT OR REPLACE INTO code_notebook_cell (notebook_kernel_id, code_notebook_cell_id, notebook_name, cell_name, interpretable_code, interpretable_code_hash, description) VALUES (
  'SQL',
  'web-ui.auto_generate_console_content_tabular_sqlpage_files',
  'Web UI',
  'auto_generate_console_content_tabular_sqlpage_files',
  '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows',
  'TODO',
  'A series of idempotent INSERT statements which will auto-generate "default" content for all tables and views'
);
      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in '*.auto.sql' with redirects
      DELETE FROM sqlpage_files WHERE path like 'console/content/table/%.auto.sql';
      DELETE FROM sqlpage_files WHERE path like 'console/content/view/%.auto.sql';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql',
            'SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;

              SELECT ''breadcrumb'' AS component;
              SELECT ''Home'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
              SELECT ''Console'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console'' AS link;
              SELECT ''Content'' as title,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content'' AS link;
              SELECT ''' || tabular_name  || ' ' || tabular_nature || ''' as title, ''#'' AS link;

              SELECT ''title'' AS component, ''' || tabular_name || ' (' || tabular_nature || ') Content'' as contents;

              SET total_rows = (SELECT COUNT(*) FROM ' || tabular_name || ');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''text'' AS component, ''' || info_schema_link_full_md || ''' AS contents_md
              SELECT ''text'' AS component,
                ''- Start Row: '' || $offset || ''
'' ||
                ''- Rows per Page: '' || $limit || ''
'' ||
                ''- Total Rows: '' || $total_rows || ''
'' ||
                ''- Current Page: '' || $current_page || ''
'' ||
                ''- Total Pages: '' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''table'' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM ' || tabular_name || '
            LIMIT $limit
            OFFSET $offset;

            SELECT ''text'' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
                ''(Page '' || $current_page || '' of '' || $total_pages || '') '' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
                AS contents_md;'
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            'console/content/' || tabular_nature || '/' || tabular_name || '.sql',
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;
' ||
            'SELECT ''redirect'' AS component,sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'orchestration/index.sql', 'orchestration/index.sql', 'Orchestration', NULL, NULL, 'Explore details about all orchestration', NULL),
    ('prime', 'orchestration/index.sql', 99, 'orchestration/info-schema.sql', 'orchestration/info-schema.sql', 'Orchestration Tables and Views', NULL, NULL, 'Information Schema documentation for orchestrated objects', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
 DROP VIEW IF EXISTS orchestration_session_by_device;
 CREATE VIEW orchestration_session_by_device AS
 SELECT
     d.device_id,
     d.name AS device_name,
     COUNT(*) AS session_count
 FROM orchestration_session os
 JOIN device d ON os.device_id = d.device_id
 GROUP BY d.device_id, d.name;

 DROP VIEW IF EXISTS orchestration_session_duration;
 CREATE VIEW orchestration_session_duration AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     os.orch_started_at,
     os.orch_finished_at,
     (JULIANDAY(os.orch_finished_at) - JULIANDAY(os.orch_started_at)) * 24 * 60 * 60 AS duration_seconds
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 WHERE os.orch_finished_at IS NOT NULL;

 DROP VIEW IF EXISTS orchestration_success_rate;
 CREATE VIEW orchestration_success_rate AS
 SELECT
     onature.nature AS orchestration_nature,
     COUNT(*) AS total_sessions,
     SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS successful_sessions,
     (CAST(SUM(CASE WHEN oss.to_state = 'surveilr_orch_completed' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_state oss ON os.orchestration_session_id = oss.session_id
 WHERE oss.to_state IN ('surveilr_orch_completed', 'surveilr_orch_failed') -- Consider other terminal states if applicable
 GROUP BY onature.nature;

 DROP VIEW IF EXISTS orchestration_session_script;
 CREATE VIEW orchestration_session_script AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     COUNT(*) AS script_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_entry ose ON os.orchestration_session_id = ose.session_id
 GROUP BY os.orchestration_session_id, onature.nature;

 DROP VIEW IF EXISTS orchestration_executions_by_type;
 CREATE VIEW orchestration_executions_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS execution_count
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_execution_success_rate_by_type;
 CREATE VIEW orchestration_execution_success_rate_by_type AS
 SELECT
     exec_nature,
     COUNT(*) AS total_executions,
     SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS successful_executions,
     (CAST(SUM(CASE WHEN exec_status = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS success_rate
 FROM orchestration_session_exec
 GROUP BY exec_nature;

 DROP VIEW IF EXISTS orchestration_session_summary;
 CREATE VIEW orchestration_session_summary AS
 SELECT
     issue_type,
     COUNT(*) AS issue_count
 FROM orchestration_session_issue
 GROUP BY issue_type;

 DROP VIEW IF EXISTS orchestration_issue_remediation;
 CREATE VIEW orchestration_issue_remediation AS
 SELECT
     orchestration_session_issue_id,
     issue_type,
     issue_message,
     remediation
 FROM orchestration_session_issue
 WHERE remediation IS NOT NULL;

DROP VIEW IF EXISTS orchestration_logs_by_session;
 CREATE VIEW orchestration_logs_by_session AS
 SELECT
     os.orchestration_session_id,
     onature.nature AS orchestration_nature,
     osl.category,
     COUNT(*) AS log_count
 FROM orchestration_session os
 JOIN orchestration_nature onature ON os.orchestration_nature_id = onature.orchestration_nature_id
 JOIN orchestration_session_exec ose ON os.orchestration_session_id = ose.session_id
 JOIN orchestration_session_log osl ON ose.orchestration_session_exec_id = osl.parent_exec_id
 GROUP BY os.orchestration_session_id, onature.nature, osl.category;
-- delete all /ip-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like 'ce%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description,elaboration)
VALUES
    ('prime', 'index.sql', 1, 'ce/regime/index.sql', 'ce/regime/index.sql', 'Controls', NULL, NULL, 'SCF (Secure Controls Framework) controls are a set of cybersecurity and privacy requirements designed to help organizations manage and comply with various regulatory, statutory, and contractual frameworks.', NULL),
    ('prime', 'ce/regime/index.sql', 2, 'ce/regime/scf.sql', 'ce/regime/scf.sql', ' ', NULL, NULL, NULL, NULL),
    ('prime', 'ce/regime/index.sql', 2, 'ce/regime/controls.sql', 'ce/regime/controls.sql', ' ', NULL, NULL, NULL, NULL),
    ('prime', 'ce/regime/index.sql', 5, 'ce/regime/hipaa_security_rule.sql', 'ce/regime/hipaa_security_rule.sql', 'HIPAA', NULL, NULL, 'HIPAA and their mapping with SCF and FII IDs.', NULL),
    ('prime', 'ce/regime/index.sql', 6, 'ce/regime/cmmc.sql', 'ce/regime/cmmc.sql', 'CMMC', NULL, NULL, 'Cybersecurity Maturity Model Certification (CMMC) Levels 1-3.', NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "shell",
  "title": "Compliance Explorer",
  "icon": "",
  "favicon": "https://www.surveilr.com/assets/brand/content-assembler.ico",
  "image": "https://www.surveilr.com/assets/brand/compliance-explorer.png",
  "layout": "fluid",
  "fixed_top_menu": true,
  "link": "index.sql",
  "menu_item": [
    {
      "link": "index.sql",
      "title": "Home"
    }
  ],
  "javascript": [
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js",
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js"
  ],
  "footer": "Resource Surveillance Web UI"
};',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.sql',
      'SELECT ''shell'' AS component,
       ''Compliance Explorer'' AS title,
       NULL AS icon,
       ''https://www.surveilr.com/assets/brand/content-assembler.ico'' AS favicon,
       ''https://www.surveilr.com/assets/brand/compliance-explorer.png'' AS image,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''index.sql'' AS link,
       ''{"link":"index.sql","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''/docs/index.sql'',
              ''title'', ''Docs'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/docs/index.sql/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''ur'',
              ''title'', ''Uniform Resource'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''ur/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''console'',
              ''title'', ''Console'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''console/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''''||''orchestration'',
              ''title'', ''Orchestration'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''orchestration/index.sql''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       ''Surveilr ''|| (SELECT json_extract(session_agent, ''$.version'') AS version FROM ur_ingest_session LIMIT 1) || '' Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), LENGTH(sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'')) + 2 ) || '')'' as footer;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
    SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''ur''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''ur''||''/index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, ''Uniform Resource Tables and Views'' as contents;
  SELECT ''table'' AS component,
  ''Name'' AS markdown,
    ''Column Count'' as align_right,
    TRUE as sort,
    TRUE as search;

SELECT
''Table'' as "Type",
  ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
  FROM console_information_schema_table
  WHERE table_name = ''uniform_resource'' OR table_name like ''ur_%''
  GROUP BY table_name

  UNION ALL

SELECT
''View'' as "Type",
  ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
  FROM console_information_schema_view
  WHERE view_name like ''ur_%''
  GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-files.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-files.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-files.sql/index.sql'') as contents;
    ;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_file );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small;
SELECT * FROM uniform_resource_file ORDER BY uniform_resource_id
   LIMIT $limit
  OFFSET $offset;

  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-account.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ur/uniform-resource-imap-account.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ur/uniform-resource-imap-account.sql/index.sql'') as contents;
    ;

select
  ''title''   as component,
  ''Mailbox'' as contents;
-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''email'' AS markdown;
SELECT    
''['' || email || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id || '')'' AS "email"
      FROM uniform_resource_imap
      GROUP BY ur_ingest_session_imap_account_id
      ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-folder.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''breadcrumb'' as component;
SELECT
   ''Home'' as title,
   sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
SELECT
  ''Uniform Resource'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' as link;
SELECT
  ''Folder'' as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || $imap_account_id:: TEXT as link;
SELECT
  ''title'' as component,
  (SELECT email FROM uniform_resource_imap WHERE ur_ingest_session_imap_account_id = $imap_account_id::TEXT) as contents;

--Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''folder'' AS markdown;
  SELECT ''['' || folder_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id || '')'' AS "folder"
    FROM uniform_resource_imap
    WHERE ur_ingest_session_imap_account_id = $imap_account_id:: TEXT
    GROUP BY ur_ingest_session_imap_acct_folder_id
    ORDER BY uniform_resource_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-list.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
''breadcrumb'' AS component;
SELECT
''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''
SELECT
  ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' as link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
  ''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id=''|| ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id = $folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
  ''title''   as component,
  (SELECT email || '' ('' || folder_name || '')''  FROM uniform_resource_imap WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT) as contents;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
  SET total_rows = (SELECT COUNT(*) FROM uniform_resource_imap );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Display uniform_resource table with pagination
  SELECT ''table'' AS component,
  ''Uniform Resources'' AS title,
    "Size (bytes)" as align_right,
    TRUE AS sort,
      TRUE AS search,
        TRUE AS hover,
          TRUE AS striped_rows,
            TRUE AS small,
              ''subject'' AS markdown;;
SELECT
''['' || subject || ''](uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id || '')'' AS "subject"
  , "from",
  CASE
      WHEN ROUND(julianday(''now'') - julianday(date)) = 0 THEN ''Today''
      WHEN ROUND(julianday(''now'') - julianday(date)) = 1 THEN ''1 day ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) BETWEEN 2 AND 6 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) < 30 THEN CAST(ROUND(julianday(''now'') - julianday(date)) AS INT) || '' days ago''
      WHEN ROUND(julianday(''now'') - julianday(date)) < 365 THEN CAST(ROUND((julianday(''now'') - julianday(date)) / 30) AS INT) || '' months ago''
      ELSE CAST(ROUND((julianday(''now'') - julianday(date)) / 365) AS INT) || '' years ago''
  END AS "Relative Time",
  strftime(''%Y-%m-%d'', substr(date, 1, 19)) as date
  FROM uniform_resource_imap
  WHERE ur_ingest_session_imap_acct_folder_id=$folder_id::TEXT
  ORDER BY uniform_resource_id
  LIMIT $limit
  OFFSET $offset;
  SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&folder_id='' || replace($folder_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&folder_id='' || replace($folder_id, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ur/uniform-resource-imap-mail-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
''breadcrumb'' AS component;
SELECT
''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''AS link;
SELECT
 ''Uniform Resource'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/index.sql'' AS link;
SELECT
  ''Uniform Resources (IMAP)'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-account.sql'' AS link;
SELECT
''Folder'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-folder.sql?imap_account_id='' || ur_ingest_session_imap_account_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   folder_name AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id=$resource_id::TEXT GROUP BY ur_ingest_session_imap_acct_folder_id;

SELECT
   subject AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-detail.sql?resource_id='' || uniform_resource_id AS link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Breadcrumb ends-- -

  --- back button-- -
    select ''button'' as component;
select
"<< Back" as title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ur/uniform-resource-imap-mail-list.sql?folder_id='' || ur_ingest_session_imap_acct_folder_id as link
  FROM uniform_resource_imap
  WHERE uniform_resource_id = $resource_id:: TEXT;

--Display uniform_resource table with pagination
  SELECT
''datagrid'' as component;
SELECT
''From'' as title,
  "from" as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''To'' as title,
  email as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;
SELECT
''Subject'' as title,
  subject as "description" FROM uniform_resource_imap where uniform_resource_id=$resource_id::TEXT;

  SELECT ''html'' AS component;
  SELECT html_content AS html FROM uniform_resource_imap_content WHERE uniform_resource_id=$resource_id::TEXT ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''list'' AS component;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH console_navigation_cte AS (
    SELECT title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path =''console''||''/index.sql''
)
SELECT ''list'' AS component, title, description
  FROM console_navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''console''||''/index.sql''
 ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Tables'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || table_name || ''](table.sql?name='' || table_name || '')'' AS "Table",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
FROM console_information_schema_table
GROUP BY table_name;

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;
SELECT
    ''['' || view_name || ''](view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md,''$SITE_PREFIX_URL'',sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') as "Content"
FROM console_information_schema_view
GROUP BY view_name;

SELECT ''title'' AS component, ''Migrations'' as contents;
SELECT ''table'' AS component,
      ''Table'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT from_state, to_state, transition_reason, transitioned_at
FROM code_notebook_state
ORDER BY transitioned_at;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/table.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' Table'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type",
    is_primary_key AS "PK",
    is_not_null AS "Required",
    default_value AS "Default"
FROM console_information_schema_table
WHERE table_name = $name;

SELECT ''title'' AS component, ''Foreign Keys'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    foreign_key AS "Foreign Key"
FROM console_information_schema_table_col_fkey
WHERE table_name = $name;

SELECT ''title'' AS component, ''Indexes'' as contents, 2 as level;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column Name",
    index_name AS "Index Name"
FROM console_information_schema_table_col_index
WHERE table_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_table WHERE table_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/info-schema/view.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/info-schema/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' View'' AS title, ''#'' AS link;

SELECT ''title'' AS component,
$name AS contents;
SELECT ''table'' AS component;
SELECT
    column_name AS "Column",
    data_type AS "Type"
FROM console_information_schema_view
WHERE view_name = $name;

SELECT ''title'' AS component, ''SQL DDL'' as contents, 2 as level;
SELECT ''code'' AS component;
SELECT ''sql'' as language, (SELECT sql_ddl FROM console_information_schema_view WHERE view_name = $name) as contents;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage pages in sqlpage_files table'' AS contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
   SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
   LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/sqlpage-file.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT $path || '' Path'' AS title, ''#'' AS link;

      SELECT ''title'' AS component, $path AS contents;
      SELECT ''text'' AS component,
             ''```sql
'' || (select contents FROM sqlpage_files where path = $path) || ''
```'' as contents_md;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-files/content.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-files/content.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage pages generated from tables and views'' AS contents;
SELECT ''text'' AS component, ''
  - `*.auto.sql` pages are auto-generated "default" content pages for each table and view defined in the database.
  - The `*.sql` companions may be auto-generated redirects to their `*.auto.sql` pair or an app/service might override the `*.sql` to not redirect and supply custom content for any table or view.
  - [View regenerate-auto.sql]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/sqlpage-file.sql?path=console/content/action/regenerate-auto.sql'' || '')
  '' AS contents_md;

SELECT ''button'' AS component, ''center'' AS justify;
SELECT sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/content/action/regenerate-auto.sql'' AS link, ''info'' AS color, ''Regenerate all "default" table/view content pages'' AS title;

SELECT ''title'' AS component, ''Redirected or overriden content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
      SELECT
  ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '')[📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",

  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%''
      AND NOT(path like ''console/content/%.auto.sql'')
      AND NOT(path like ''console/content/action%'')
ORDER BY path;

SELECT ''title'' AS component, ''Auto-generated "default" content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
    SELECT
      ''[🚀]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",

  LENGTH(contents) as "Size", last_modified
FROM sqlpage_files
WHERE path like ''console/content/%.auto.sql''
ORDER BY path;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/content/action/regenerate-auto.sql',
      '      -- code provenance: `ConsoleSqlPages.infoSchemaContentDML` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

      -- the "auto-generated" tables will be in ''*.auto.sql'' with redirects
      DELETE FROM sqlpage_files WHERE path like ''console/content/table/%.auto.sql'';
      DELETE FROM sqlpage_files WHERE path like ''console/content/view/%.auto.sql'';
      INSERT OR REPLACE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'',
            ''SELECT ''''dynamic'''' AS component, sqlpage.run_sql(''''shell/shell.sql'''') AS properties;

              SELECT ''''breadcrumb'''' AS component;
              SELECT ''''Home'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/'''' AS link;
              SELECT ''''Console'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console'''' AS link;
              SELECT ''''Content'''' as title,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content'''' AS link;
              SELECT '''''' || tabular_name  || '' '' || tabular_nature || '''''' as title, ''''#'''' AS link;

              SELECT ''''title'''' AS component, '''''' || tabular_name || '' ('' || tabular_nature || '') Content'''' as contents;

              SET total_rows = (SELECT COUNT(*) FROM '' || tabular_name || '');
              SET limit = COALESCE($limit, 50);
              SET offset = COALESCE($offset, 0);
              SET total_pages = ($total_rows + $limit - 1) / $limit;
              SET current_page = ($offset / $limit) + 1;

              SELECT ''''text'''' AS component, '''''' || info_schema_link_full_md || '''''' AS contents_md
              SELECT ''''text'''' AS component,
                ''''- Start Row: '''' || $offset || ''''
'''' ||
                ''''- Rows per Page: '''' || $limit || ''''
'''' ||
                ''''- Total Rows: '''' || $total_rows || ''''
'''' ||
                ''''- Current Page: '''' || $current_page || ''''
'''' ||
                ''''- Total Pages: '''' || $total_pages as contents_md
              WHERE $stats IS NOT NULL;

              -- Display uniform_resource table with pagination
              SELECT ''''table'''' AS component,
                    TRUE AS sort,
                    TRUE AS search,
                    TRUE AS hover,
                    TRUE AS striped_rows,
                    TRUE AS small;
            SELECT * FROM '' || tabular_name || ''
            LIMIT $limit
            OFFSET $offset;

            SELECT ''''text'''' AS component,
                (SELECT CASE WHEN $current_page > 1 THEN ''''[Previous](?limit='''' || $limit || ''''&offset='''' || ($offset - $limit) || '''')'''' ELSE '''''''' END) || '''' '''' ||
                ''''(Page '''' || $current_page || '''' of '''' || $total_pages || '''') '''' ||
                (SELECT CASE WHEN $current_page < $total_pages THEN ''''[Next](?limit='''' || $limit || ''''&offset='''' || ($offset + $limit) || '''')'''' ELSE '''''''' END)
                AS contents_md;''
        FROM console_content_tabular;

      INSERT OR IGNORE INTO sqlpage_files (path, contents)
        SELECT
            ''console/content/'' || tabular_nature || ''/'' || tabular_name || ''.sql'',
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component,sqlpage.environment_variable(''''SQLPAGE_SITE_PREFIX'''') || ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows

-- code provenance: `ConsoleSqlPages.console/content/action/regenerate-auto.sql` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/sqlpage-files/content.sql'' as link WHERE $redirect is NULL;
SELECT ''redirect'' AS component, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || $redirect as link WHERE $redirect is NOT NULL;',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/sqlpage-nav/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/sqlpage-nav/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''SQLPage navigation in sqlpage_aide_navigation table'' AS contents;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT path, caption, description FROM sqlpage_aide_navigation ORDER BY namespace, parent_path, path, sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Code Notebooks'' AS contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT c.notebook_name,
    ''['' || c.cell_name || '']('' ||
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' ||
    replace(c.notebook_name, '' '', ''%20'') ||
    ''&cell='' ||
    replace(c.cell_name, '' '', ''%20'') ||
    '')'' AS "Cell",
     c.description,
       k.kernel_name as kernel
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/notebooks/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/notebooks/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/migrations/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
    ''foldable'' as component;
SELECT
    ''RSSD Lifecycle(Migration) Documentation'' as title,
    ''
This document provides an organized and comprehensive overview of ``surveilr``''''s RSSD migration process starting from ``v 1.0.0``, breaking down each component and the steps followed to ensure smooth and efficient migrations. It covers the creation of key tables and views, the handling of migration cells, and the sequence for executing migration scripts.

---

## Session and State Initialization

To manage temporary session data and track user state, we use the ``session_state_ephemeral`` table, which stores essential session information like the current user. This table is temporary, meaning it only persists data for the duration of the session, and it''''s especially useful for identifying the user responsible for specific actions during the migration.

Each time the migration process runs, we initialize session data in this table, ensuring all necessary information is available without affecting the core database tables. This initialization prepares the system for more advanced operations that rely on knowing the user executing each action.

---

## Assurance Schema Table

The ``assurance_schema`` table is designed to store various schema-related details, including the type of schema assurance, associated codes, and related governance data. This table is central to defining the structure of assurance records, which are useful for validating data, tracking governance requirements, and recording creation timestamps. All updates to the schema are logged to track when they were last modified and by whom.

---

## Code Notebook Kernel, Cell, and State Tables

``surveilr`` uses a structured system of code notebooks to store and execute SQL commands. These commands, or “cells,” are grouped into notebooks, and each notebook is associated with a kernel, which provides metadata about the notebook''''s language and structure. The main tables involved here are:

- **``code_notebook_kernel``**: Stores information about different kernels, each representing a unique execution environment or language.
- **``code_notebook_cell``**: Holds individual code cells within each notebook, along with their associated metadata and execution history.
- **``code_notebook_state``**: Tracks each cell''''s state changes, such as when it was last executed and any errors encountered.

By organizing migration scripts into cells and notebooks, ``surveilr`` can maintain detailed control over execution order and track the state of each cell individually. This tracking is essential for handling updates, as it allows us to execute migrations only when necessary.

---

## Views for Managing Cell Versions and Migrations

Several views are defined to simplify and organize the migration process by managing different versions of code cells and identifying migration candidates. These views help filter, sort, and retrieve the cells that need execution.

### Key Views

- **``code_notebook_cell_versions``**: Lists all available versions of each cell, allowing the migration tool to retrieve older versions if needed for rollback or auditing.
- **``code_notebook_cell_latest``**: Shows only the latest version of each cell, simplifying the migration by focusing on the most recent updates.
- **``code_notebook_sql_cell_migratable``**: Filters cells to include only those that are eligible for migration, ensuring that non-executable cells are ignored.

---

## Migration-Oriented Views and Dynamic Migration Scripts

To streamline the migration process, several migration-oriented views organize the data by listing cells that require execution or are ready for re-execution. By grouping these cells in specific views, ``surveilr`` dynamically generates a script that executes only the necessary cells.

### Key Views

- **``code_notebook_sql_cell_migratable_not_executed``**: Lists migratable cells that haven’t yet been executed.
- **``code_notebook_sql_cell_migratable_state``**: Shows the latest migratable cells, along with their current state transitions.

---

## How Migrations Are Executed

When it''''s time to apply changes to the database, this section explains the process in detail, focusing on how ``surveilr`` prepares the environment, identifies which cells to migrate, executes the appropriate SQL code, and ensures data integrity throughout.

---

### 1. Initialization

The first step in the migration process involves setting up the essential database tables and seeding initial values. This lays the foundation for the migration process, making sure that all tables, views, and temporary values needed are in place.

- **Check for Core Tables**: ``surveilr`` first verifies whether the required tables, such as ``code_notebook_cell``, ``code_notebook_state``, and others starting with ``code_notebook%``, are already set up in the database.
- **Setup**: If these tables do not yet exist, ``surveilr`` automatically initiates the setup by running the initial SQL script, known as ``bootstrap.sql``. This script contains SQL commands that create all the essential tables and views discussed in previous sections.
- **Seeding**: During the execution of ``bootstrap.sql``, essential data, such as temporary values in the ``session_state_ephemeral`` table (e.g., information about the current user), is also added to ensure that the migration session has the data it needs to proceed smoothly.

---

### 2. Migration Preparation and Identification of Cells to Execute

Once the environment is ready, ``surveilr`` examines which specific cells (code blocks in the migration notebook) need to be executed to bring the database up to the latest version.

- **Listing Eligible Cells**: ``surveilr`` begins by consulting views such as ``code_notebook_sql_cell_migratable_not_executed``. This view is a pre-filtered list of cells that are eligible for migration but haven’t yet been executed.
- **Idempotent vs. Non-Idempotent Cells**: ``surveilr`` then checks whether each cell is marked as “idempotent” or “non-idempotent.”
   - **Idempotent Cells** can be executed multiple times without adverse effects. If they have been run before, they can safely be run again without impacting data integrity.
   - **Non-Idempotent Cells**, identified by names containing ``_once_``, should only be executed once. If these cells have been executed previously, they are skipped in the migration process to prevent unintentional re-runs.

---

### 3. Dynamic Script Generation and Execution

``surveilr`` then assembles a custom SQL script that includes only the cells identified as eligible for execution. This script is crafted carefully to ensure each cell''''s SQL code is executed in the correct order and with the right contextual information.

- **Script Creation**: We start by generating a dynamic script in a single transaction block. Transactions are a way of grouping a series of commands so that they are either all applied or none are, which protects data integrity.
- **Inclusion of Cells Based on Eligibility**:
   - For each cell, ``surveilr`` checks its eligibility status. If it''''s non-idempotent and already executed, it''''s marked with a comment noting that it''''s excluded from the script due to previous execution.
   - If the cell is idempotent or eligible for re-execution, its SQL code is added to the script, along with additional details such as comments about the cell''''s last execution date.
- **State Transition Records**: After each cell''''s SQL code, additional commands are added to record the cell''''s transition state. This step inserts information into ``code_notebook_state``, logging details such as the cell ID, transition state (from “Pending” to “Executed”), and the reason for the transition (“Migration” or “Reapplication”). These logs are invaluable for auditing purposes.

---

### 4. Execution in a Transactional Block

With the script prepared, ``surveilr`` then executes the entire batch of SQL commands within a transactional block.

- **BEGIN TRANSACTION**: The script begins with a transaction, ensuring that all changes are applied as a single, atomic unit.
- **Running Cell Code**: Within this transaction, each cell''''s SQL code is executed in the order it appears in the script.
- **Error Handling**: If any step in the transaction fails, all changes are rolled back. This prevents partial updates from occurring, ensuring that the database remains in a consistent state.
- **COMMIT**: If the script executes successfully without errors, the transaction is committed, finalizing the changes. The ``COMMIT`` command signifies the end of the migration session, making all updates permanent.

---

### 5. Finalizing Migration and Recording Results

After a successful migration session, ``surveilr`` concludes by recording details about the migration process.

- **Final Updates to ``code_notebook_state``**: Any cells marked as “Executed” are updated in ``code_notebook_state`` with the latest timestamp, indicating their successful migration.
- **Logging Completion**: Activity logs are updated with relevant details, ensuring a clear record of the migration.
- **Cleanup of Temporary Data**: Finally, temporary data is cleared, such as entries in ``session_state_ephemeral``, since these values were only needed during the migration process.
    '' as description_md;


SELECT ''title'' AS component, ''Pending Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_not_executed lists all cells eligible for migration but not yet executed.
    If migrations have been completed successfully, this list will be empty,
    indicating that all migratable cells have been processed and marked as executed.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp
FROM
    code_notebook_sql_cell_migratable_not_executed AS c
ORDER BY
    c.cell_name;

-- State of Executed Migrations
SELECT ''title'' AS component, ''State of Executed Migrations'' AS contents;
SELECT ''text'' AS component, ''code_notebook_sql_cell_migratable_state displays all cells that have been successfully executed as part of the migration process,
    showing the latest version of each migratable cell.
    For each cell, it provides details on its transition states,
    the reason and result of the migration, and the timestamp of when the migration occurred.'' as contents;

SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
    c.code_notebook_cell_id,
    c.notebook_name,
    c.cell_name,
    c.is_idempotent,
    c.version_timestamp,
    c.from_state,
    c.to_state,
    c.transition_reason,
    c.transition_result,
    c.transitioned_at
FROM
    code_notebook_sql_cell_migratable_state AS c
ORDER BY
    c.cell_name;


-- Executable Migrations
SELECT ''title'' AS component, ''Executable Migrations'' AS contents;
SELECT ''text'' AS component, ''All cells that are candidates for migration (including duplicates)'' as contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT
        c.code_notebook_cell_id,
        c.notebook_name,
        c.cell_name,
        ''['' || c.cell_name || ''](''||sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks/notebook-cell.sql?notebook='' || replace(c.notebook_name, '' '', ''%20'') || ''&cell='' || replace(c.cell_name, '' '', ''%20'') || '')'' as Cell,
        c.interpretable_code_hash,
        c.is_idempotent,
        c.version_timestamp
    FROM
        code_notebook_sql_cell_migratable_version AS c
    ORDER BY
        c.cell_name;

-- All Migrations
SELECT ''button'' as component;
SELECT
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/notebooks'' as link,
    ''See all notebook entries'' as title;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/migrations/notebook-cell.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/migrations/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
SELECT ''Notebook '' || $notebook || '' Cell'' || $cell AS title, ''#'' AS link;

SELECT ''code'' as component;
SELECT $notebook || ''.'' || $cell || '' ('' || k.kernel_name ||'')'' as title,
       COALESCE(c.cell_governance -> ''$.language'', ''sql'') as language,
       c.interpretable_code as contents
  FROM code_notebook_kernel k, code_notebook_cell c
 WHERE c.notebook_name = $notebook
   AND c.cell_name = $cell
   AND k.code_notebook_kernel_id = c.notebook_kernel_id;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/about.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/about.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                 -- Title Component
    SELECT
    ''text'' AS component,
    (''Resource Surveillance v'' || replace(sqlpage.exec(''surveilr'', ''--version''), ''surveilr '', '''')) AS title;

    -- Description Component
      SELECT
          ''text'' AS component,
          ''A detailed description of what is incorporated into surveilr. It informs of critical dependencies like rusqlite, sqlpage, pgwire, e.t.c, ensuring they are present and meet version requirements. Additionally, it scans for and executes capturable executables in the PATH and evaluates surveilr_doctor_* database views for more insights.''
          AS contents_md;

      -- Section: Dependencies
      SELECT
          ''title'' AS component,
          ''Internal Dependencies'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          "Dependency",
          "Version"
      FROM (
          SELECT
              ''SQLPage'' AS "Dependency",
              json_extract(json_data, ''$.versions.sqlpage'') AS "Version"
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Pgwire'',
              json_extract(json_data, ''$.versions.pgwire'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
          UNION ALL
          SELECT
              ''Rusqlite'',
              json_extract(json_data, ''$.versions.rusqlite'')
          FROM (SELECT sqlpage.exec(''surveilr'', ''doctor'', ''--json'') AS json_data)
      );

      -- Section: Static Extensions
      SELECT
          ''title'' AS component,
          ''Statically Linked Extensions'' AS contents,
          2 AS level;
      SELECT
          ''table'' AS component,
          TRUE AS sort;
      SELECT
          json_extract(value, ''$.name'') AS "Extension Name",
          json_extract(value, ''$.url'') AS "URL",
          json_extract(value, ''$.version'') AS "Version"
      FROM json_each(
          json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.static_extensions'')
      );

    -- Section: Dynamic Extensions
    SELECT
        ''title'' AS component,
        ''Dynamically Linked Extensions'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Extension Name",
        json_extract(value, ''$.path'') AS "Path"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.dynamic_extensions'')
    );

    -- Section: Environment Variables
    SELECT
        ''title'' AS component,
        ''Environment Variables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Variable",
        json_extract(value, ''$.value'') AS "Value"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.env_vars'')
    );

    -- Section: Capturable Executables
    SELECT
        ''title'' AS component,
        ''Capturable Executables'' AS contents,
        2 AS level;
    SELECT
        ''table'' AS component,
        TRUE AS sort;
    SELECT
        json_extract(value, ''$.name'') AS "Executable Name",
        json_extract(value, ''$.output'') AS "Output"
    FROM json_each(
        json_extract(sqlpage.exec(''surveilr'', ''doctor'', ''--json''), ''$.capturable_executables'')
    );

SELECT ''title'' AS component, ''Views'' as contents;
SELECT ''table'' AS component,
      ''View'' AS markdown,
      ''Column Count'' as align_right,
      ''Content'' as markdown,
      TRUE as sort,
      TRUE as search;

SELECT
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "View",
    COUNT(column_name) AS "Column Count",
    REPLACE(content_web_ui_link_abbrev_md, ''$SITE_PREFIX_URL'', sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || '''') AS "Content"
FROM console_information_schema_view
WHERE view_name LIKE ''surveilr_doctor%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/statistics/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/statistics/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''datagrid'' as component;
SELECT ''Size'' as title, "db_size_mb" || '' MB'' as description FROM rssd_statistics_overview;
SELECT ''Tables'' as title, "total_tables" as description FROM rssd_statistics_overview;
SELECT ''Indexes'' as title, "total_indexes" as description FROM rssd_statistics_overview;
SELECT ''Rows'' as title, "total_rows" as description FROM rssd_statistics_overview;
SELECT ''Page Size'' as title, "page_size" as description FROM rssd_statistics_overview;
SELECT ''Total Pages'' as title, "total_pages" as description FROM rssd_statistics_overview;

select ''text'' as component, ''Tables'' as title;
SELECT ''table'' AS component, TRUE as sort, TRUE as search;
SELECT * FROM rssd_table_statistic ORDER BY table_size_mb DESC;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/behavior/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''console/behavior/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Behavior Configuration'' AS contents;

SELECT ''text'' AS component,
  ''Behaviors are configuration presets that drive application operations at runtime, including ingest behaviors, file scanning configurations, and device-specific settings.'' AS contents;

-- Summary cards
SELECT ''card'' AS component, 3 AS columns;
SELECT
    ''Total Behaviors'' AS title,
    COUNT(*) AS description,
    ''blue'' AS color
FROM behavior
WHERE deleted_at IS NULL;

SELECT
    ''Active Devices'' AS title,
    COUNT(DISTINCT device_id) AS description,
    ''green'' AS color
FROM behavior
WHERE deleted_at IS NULL;

SELECT
    ''Unique Behavior Types'' AS title,
    COUNT(DISTINCT behavior_name) AS description,
    ''orange'' AS color
FROM behavior
WHERE deleted_at IS NULL;

-- Initialize pagination
SET total_rows = (SELECT COUNT(*) FROM behavior );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

-- Behavior table with pagination
SELECT ''title'' AS component, ''Behavior Configurations'' AS contents, 2 AS level;
SELECT ''table'' AS component,
       ''Behavior Name'' as markdown,
       ''Device'' as markdown,
       TRUE as sort,
       TRUE as search;
SELECT
    ''['' || b.behavior_name || ''](behavior-detail.sql?behavior_id='' || b.behavior_id || '')'' AS "Behavior Name",
    ''['' || d.name || ''](/console/info-schema/table.sql?name=device)'' AS "Device",
    CASE
        WHEN LENGTH(b.behavior_conf_json) > 100
        THEN SUBSTR(b.behavior_conf_json, 1, 100) || ''...''
        ELSE b.behavior_conf_json
    END AS "Configuration Preview",
    b.created_at AS "Created",
    CASE
        WHEN b.updated_at IS NOT NULL THEN b.updated_at
        ELSE b.created_at
    END AS "Last Modified"
FROM behavior b
LEFT JOIN device d ON b.device_id = d.device_id
WHERE b.deleted_at IS NULL
ORDER BY b.created_at DESC
LIMIT $limit
OFFSET $offset;

-- Pagination controls
SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'console/behavior/behavior-detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              -- Breadcrumbs
SELECT ''breadcrumb'' as component;
SELECT ''Home'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' as link;
SELECT ''Console'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/index.sql'' as link;
SELECT ''Behavior'' as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/behavior/index.sql'' as link;
SELECT behavior_name as title FROM behavior WHERE behavior_id = $behavior_id;

SELECT ''title'' AS component,
       (SELECT behavior_name FROM behavior WHERE behavior_id = $behavior_id) AS contents;

SELECT ''text'' AS component,
  ''Detailed view of behavior configuration including JSON configuration, governance settings, and associated device information.'' AS contents;

-- Behavior details card
SELECT ''card'' AS component, 2 AS columns;
SELECT
    ''Behavior ID'' AS title,
    behavior_id AS description,
    ''blue'' AS color
FROM behavior
WHERE behavior_id = $behavior_id;

SELECT
    ''Device'' AS title,
    (SELECT name FROM device WHERE device_id = b.device_id) AS description,
    ''green'' AS color
FROM behavior b
WHERE behavior_id = $behavior_id;

-- Configuration details
SELECT ''title'' AS component, ''Configuration Details'' AS contents, 2 AS level;
SELECT ''table'' AS component;
SELECT
    ''Behavior Name'' AS "Property",
    behavior_name AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Device ID'' AS "Property",
    device_id AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Created At'' AS "Property",
    created_at AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Created By'' AS "Property",
    created_by AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Updated At'' AS "Property",
    COALESCE(updated_at, ''Never'') AS "Value"
FROM behavior WHERE behavior_id = $behavior_id
UNION ALL
SELECT
    ''Updated By'' AS "Property",
    COALESCE(updated_by, ''N/A'') AS "Value"
FROM behavior WHERE behavior_id = $behavior_id;

-- JSON Configuration
SELECT ''title'' AS component, ''JSON Configuration'' AS contents, 2 AS level;
SELECT ''code'' AS component;
SELECT
    ''json'' as language,
    behavior_conf_json as contents
FROM behavior
WHERE behavior_id = $behavior_id;

-- Governance (if available)
SELECT ''title'' AS component, ''Governance'' AS contents, 2 AS level
WHERE EXISTS (SELECT 1 FROM behavior WHERE behavior_id = $behavior_id AND governance IS NOT NULL);

SELECT ''code'' AS component
WHERE EXISTS (SELECT 1 FROM behavior WHERE behavior_id = $behavior_id AND governance IS NOT NULL);

SELECT
    ''json'' as language,
    governance as contents
FROM behavior
WHERE behavior_id = $behavior_id AND governance IS NOT NULL;

-- Show message if no governance
SELECT ''text'' AS component,
       ''No governance configuration available for this behavior.'' AS contents
WHERE NOT EXISTS (SELECT 1 FROM behavior WHERE behavior_id = $behavior_id AND governance IS NOT NULL);
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''orchestration/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''orchestration''||''/index.sql''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' || COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path =  ''orchestration''||''/index.sql''
ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'orchestration/info-schema.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''orchestration/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, ''Orchestration Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
     ''['' || table_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''orchestration_session'' OR table_name like ''orchestration_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
     ''['' || view_name || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''orchestration_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ce/regime/index.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT
  ''text'' AS component,
  ''Compliance Explorer'' AS title;

SELECT
  ''The compliance explorer covers a wide range of standards and guidelines across different areas of cybersecurity and data protection. They include industry-specific standards, privacy regulations, and cybersecurity frameworks. Complying with these frameworks supports a strong cybersecurity stance and alignment with data protection laws.'' AS contents;

SELECT
  ''card'' AS component,
  '''' AS title,
  2 AS columns;

SELECT
  ''CMMC'' AS title,
  ''**Geography**: US 

  **Source**: Department of Defense (DoD) 

  **Version**: 2.0 

  **Published/Last Reviewed Date/Year**: 2021-11-04 00:00:00+00'' AS description_md,      
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/cmmc.sql'' as link
UNION
SELECT
  ''AICPA'' AS title,
  ''**Geography**: US 

  **Source**: American Institute of Certified Public Accountants (AICPA) 

  **Version**: N/A 

  **Published/Last Reviewed Date/Year**: 2023-10-01 00:00:00+00'' AS description_md,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/aicpa.sql'' as link
UNION
SELECT
  ''HiTRUST e1 Assessment'' AS title,
  ''**Geography**: US 

  **Source**: HITRUST Alliance 

  **HITRUST Essentials, 1-Year (e1) Assessment** 

  **Version**: e1 

  **Published/Last Reviewed Date/Year**: 2021-09-13 00:00:00+00'' AS description_md,      
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/hitrust.sql'' as link
UNION
SELECT
  ''ISO 27001:2022'' AS title,
  ''**Geography**: International 

  **Source**: International Organization for Standardization (ISO) 

  **Version**: 2022 

  **Published/Last Reviewed Date/Year**: 2022-10-25 00:00:00+00'' AS description_md,      
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/iso-27001.sql'' as link
UNION
SELECT
  ''HIPAA'' AS title,
  ''**Geography**: US 

  **Source**: Federal 

  **Health Insurance Portability and Accountability Act (HIPAA)** 

  **Version**: N/A 

  **Published/Last Reviewed Date/Year**: 2024-01-06 00:00:00+00'' AS description_md,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/hipaa_security_rule.sql'' AS link
UNION
SELECT
  ''Together.Health Security Assessment (THSA)'' AS title,
  ''**Geography**: US 

  **Source**: Together.Health (health innovation collaborative) 

  **Together.Health Security Assessment (THSA)** 

  **Version**: v2019.1 

  **Published/Last Reviewed Date/Year**: 2019-10-26 00:00:00+00'' AS description_md,      
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/thsa.sql'' AS link;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/scf.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ce/regime/scf.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              
      SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/scf.sql/index.sql'') as contents;
    ;
      SELECT
    ''text'' AS component,
    ''Compliance Explorer '' AS title;
    SELECT
    ''The compliance explorer cover a wide range of standards and guidelines across different areas of cybersecurity and data protection. They include industry-specific standards, privacy regulations, and cybersecurity frameworks. Complying with these frameworks supports a strong cybersecurity stance and alignment with data protection laws.'' as contents;
    SELECT
    ''card'' AS component,
    '''' AS title,
    2 AS columns;
    SELECT
      title,
      ''**Geography:** '' || geography || ''  
'' ||
      ''**Source:** '' || source || ''  
'' ||
      ''**Health Insurance Portability and Accountability Act (HIPAA)**'' || ''  
'' ||
      ''**Version:** '' || version || ''  
'' ||
      ''**Published/Last Reviewed Date/Year:** '' || last_reviewed_date || ''  
'' ||
      ''[**Detail View**]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/controls.sql?regimeType=US%20HIPAA''|| '')'' AS description_md
    FROM compliance_regime
    WHERE title = ''US HIPAA'';

    SELECT
      title,
      ''**Geography:** '' || geography || ''  
'' ||
      ''**Source:** '' || source || ''  
'' ||
      ''**Standard 800-53 rev4**'' || ''  
'' ||
      ''**Version:** '' || version || ''  
'' ||
      ''**Published/Last Reviewed Date/Year:** '' || last_reviewed_date || ''  
'' ||
      ''[**Detail View**]('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/controls.sql?regimeType=NIST'' || '')'' AS description_md
    FROM compliance_regime
    WHERE title = ''NIST'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/aicpa.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              --- Display breadcrumb
SELECT
  ''breadcrumb'' AS component;
SELECT
  ''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
SELECT
  ''Controls'' AS title,
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
SELECT
  ''AICPA'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/aicpa.sql'' AS link;
 
SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/aicpa.sql/index.sql'') as contents;
    ;
 
SELECT
  ''text'' AS component,
  ''AICPA'' AS title;
 
SELECT
  ''The American Institute of Certified Public Accountants (AICPA) is the national professional organization for Certified Public Accountants (CPAs) in the United States. Established in 1887, the AICPA sets ethical standards for the profession and U.S. auditing standards for private companies, nonprofit organizations, federal, state, and local governments. It also develops and grades the Uniform CPA Examination and offers specialty credentials for CPAs who concentrate on personal financial planning; forensic accounting; business valuation; and information technology.'' AS contents;
 
-- Cards for SOC 2 Type I & Type II
SELECT
  ''card'' AS component,
    2 AS columns;
 
SELECT
  ''SOC 2 Type I'' AS title,
  ''Report on Controls as a Service Organization. Relevant to Security, Availability, Processing Integrity, Confidentiality, or Privacy.'' AS description,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/soc2_type1.sql'' AS link
UNION ALL
SELECT
  ''SOC 2 Type II'' AS title,
  ''SOC 2 Type II reports provide lists of Internal controls that are audited by an Independent third-party to show how well those controls are implemented and operating.'' AS description,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/soc2_type2.sql'' AS link;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/soc2_type1.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              --- Display breadcrumb
SELECT
  ''breadcrumb'' AS component;
SELECT
  ''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
SELECT
  ''Controls'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
SELECT
  ''AICPA'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/aicpa.sql'' AS link;
SELECT
  ''SOC 2 Type I'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/soc2_type1.sql'' AS link;
 
SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/soc2_type1.sql/index.sql'') as contents;
    ;
 
SELECT
  ''text'' AS component,
  ''SOC 2 Type I Controls'' AS title;
 
SELECT
    ''The SOC 2 controls are based on the AICPA Trust Services Criteria, focusing on security, availability, processing integrity, confidentiality, and privacy.'' AS contents;
 
SELECT
  ''table'' AS component,
  "Control Code" AS markdown,
  TRUE AS sort,
  TRUE AS search;
 
-- Pagination Controls (Top)
SET total_rows = (SELECT COUNT(*) FROM compliance_regime_control_soc2 );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
 
SELECT
  ''['' || control_id || '']('' ||
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/soc2_detail.sql?type=soc2-type1&id='' || control_id || '')'' AS "Control Code",
    control_name AS "Control Name",
    common_criteria AS "Common Criteria",
    criteria_type AS "Criteria Type",
    control_question AS "Control Question"
FROM compliance_regime_control_soc2
LIMIT $limit OFFSET $offset;
 
-- Pagination Controls (Bottom)
SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/soc2_type2.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              --- Display breadcrumb
SELECT
  ''breadcrumb'' AS component;
SELECT
  ''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
SELECT
  ''Controls'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
SELECT
  ''AICPA'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/aicpa.sql'' AS link;
SELECT
  ''SOC 2 Type II'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/soc2_type2.sql'' AS link;
 
--- Display page title
SELECT
  ''title'' AS component,
  ''SOC 2 Type II Controls'' AS contents;
 
--- Display description
SELECT
  ''text'' AS component,
  ''SOC 2 Type II reports evaluate not just the design, but also the operating effectiveness of controls over a defined review period.'' AS contents;
 
--- Table
SELECT
  ''table'' AS component,
  "Control Code" AS markdown,
  TRUE AS sort,
  TRUE AS search;
 
-- Pagination Controls (Top)
SET total_rows = (SELECT COUNT(*) FROM aicpa_soc2_type2_controls );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
 
SELECT
  ''['' || control_id || '']('' ||
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/soc2_detail.sql?type=soc2-type2&id='' || control_id || '')'' AS "Control Code",
  fii_id AS "FII ID",
  common_criteria AS "Common Criteria",
  criteria_type AS "Criteria Type",
  control_name AS "Control Name",
  control_question AS "Control Question"
FROM aicpa_soc2_type2_controls
LIMIT $limit OFFSET $offset;
 
-- Pagination Controls (Bottom)
SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/soc2_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    -- Breadcrumbs
    SELECT ''breadcrumb'' AS component;
    SELECT ''Home'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT ''Controls'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
    SELECT ''AICPA'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/aicpa.sql'' AS link;
 
    -- SOC 2 Type breadcrumb
    SELECT
      CASE
        WHEN $type = ''soc2-type1'' THEN ''SOC 2 Type I''
        WHEN $type = ''soc2-type2'' THEN ''SOC 2 Type II''
        ELSE ''SOC 2''
      END AS title,
      CASE
        WHEN $type = ''soc2-type1'' THEN sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/soc2_type1.sql''
        WHEN $type = ''soc2-type2'' THEN sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/soc2_type2.sql''
        ELSE sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/aicpa.sql''
      END AS link;
 
    -- Last breadcrumb (dynamic control_id, non-clickable)
    SELECT
      control_id AS title, ''#'' AS link
    FROM (
      SELECT control_id
      FROM compliance_regime_control_soc2
      WHERE $type = ''soc2-type1'' AND control_id = $id::TEXT
      UNION ALL
      SELECT control_id
      FROM aicpa_soc2_type2_controls
      WHERE $type = ''soc2-type2'' AND control_id = $id::TEXT
    ) t
    LIMIT 1;
 
    -- Card Header
    SELECT ''card'' AS component,
           CASE
             WHEN $type = ''soc2-type1'' THEN ''SOC 2 Type I Control Detail''
             WHEN $type = ''soc2-type2'' THEN ''SOC 2 Type II Control Detail''
             ELSE ''SOC 2 Control Detail''
           END AS title,
           1 AS columns;
 
    -- Detail Section (aligned UNION)
    SELECT
      common_criteria AS title,
      ''**Control Code:** '' || control_id || ''  

'' ||
      ''**Control Name:** '' || control_name || ''  

'' ||
      (CASE WHEN $type = ''soc2-type2'' THEN ''**FII ID:** '' || COALESCE(fii_id,'''') || ''  

'' ELSE '''' END) ||
      ''**Control Question:** '' || COALESCE(control_question,'''') || ''  

''
      AS description_md
    FROM (
      -- Type I controls (with SCF reference)
      SELECT control_id, control_name, fii_id, common_criteria, control_question
      FROM compliance_regime_control_soc2
      WHERE $type = ''soc2-type1'' AND control_id = $id::TEXT
     
      UNION ALL
     
      -- Type II controls (no SCF reference → add NULL for column alignment)
      SELECT control_id, control_name, fii_id, common_criteria, control_question
      FROM aicpa_soc2_type2_controls
      WHERE $type = ''soc2-type2'' AND control_id = $id::TEXT
    );
    -- TODO Placeholder Card
    SELECT
      ''card'' AS component,
      1 AS columns;
 
 
   -----accordion start
   SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: '' || $id || ''</b> &mdash; <b>FII ID: '' || fii_id || ''</b>.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM (SELECT control_id, fii_id
    FROM compliance_regime_control_soc2
    WHERE $type = ''soc2-type1'' AND control_id = $id::TEXT
    
    UNION ALL
    
    SELECT control_id, fii_id
    FROM aicpa_soc2_type2_controls
    WHERE $type = ''soc2-type2'' AND control_id = $id::TEXT
)

     
    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = ''Author Prompt'' AND (
    ($type = ''soc2-type1'' AND regime = ''SOC2-TypeI'') OR
    ($type = ''soc2-type2'' AND regime = ''SOC2-TypeII'')
  );
      

    
    SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      --accordion for audit prompt

SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM (SELECT control_id, fii_id
    FROM compliance_regime_control_soc2
    WHERE $type = ''soc2-type1'' AND control_id = $id::TEXT
    
    UNION ALL
    
    SELECT control_id, fii_id
    FROM aicpa_soc2_type2_controls
    WHERE $type = ''soc2-type2'' AND control_id = $id::TEXT
)

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = ''Audit Prompt'' AND (
    ($type = ''soc2-type1'' AND regime = ''SOC2-TypeI'') OR
    ($type = ''soc2-type2'' AND regime = ''SOC2-TypeII'')
  );
      
 SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      
SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM (SELECT control_id, fii_id
    FROM compliance_regime_control_soc2
    WHERE $type = ''soc2-type1'' AND control_id = $id::TEXT
    
    UNION ALL
    
    SELECT control_id, fii_id
    FROM aicpa_soc2_type2_controls
    WHERE $type = ''soc2-type2'' AND control_id = $id::TEXT
)

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $id AND (
    ($type = ''soc2-type1'' AND regimeType = ''SOC2-TypeI'') OR
    ($type = ''soc2-type2'' AND regimeType = ''SOC2-TypeII'')
  );
   SELECT ''html'' AS component,
      ''</div></details>'' AS html;
      SELECT ''html'' as component,
    ''<style>
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

    '' as html;


          -- end
   
   
   
   
   
   
   --------------accordion end;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/controls.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ce/regime/controls.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

                SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/controls.sql/index.sql'') as contents;
    ;
  SELECT
  ''text'' AS component,
  ''''|| $regimeType ||'' Controls'' AS title;
  SELECT
  description as contents FROM compliance_regime WHERE title = $regimeType::TEXT;
  SELECT
  ''table'' AS component,
  TRUE AS sort,
  TRUE AS search,
  "Control Code" AS markdown;
  SELECT ''['' || control_code || ''](''|| sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/control/control_detail.sql?id='' || control_code || ''&regimeType=''|| replace($regimeType,
" ", "%20")||'')'' AS "Control Code",
  scf_control AS "Title",
  scf_domain AS "Domain",
  control_description AS "Control Description",
  control_id AS "Requirements"
  FROM compliance_regime_control WHERE control_type=$regimeType::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/hitrust.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/hitrust.sql/index.sql'') as contents;
    ;

--- Breadcrumbs
SELECT ''breadcrumb'' AS component;
SELECT ''Home'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
SELECT ''Controls'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
SELECT ''HiTRUST e1 Assessment'' AS title, ''#'' AS link;

--- Description text
SELECT ''text'' AS component,
      ''The HiTRUST e1 Assessment controls provide a comprehensive set of security and privacy requirements to support compliance with various standards and regulations.'' AS contents;

--- Pagination Controls (Top)
SET total_rows = (SELECT COUNT(*) FROM compliance_regime_control_hitrust_e1 );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

--- Table (markdown column)
SELECT ''table'' AS component, TRUE AS sort, TRUE AS search, "Control Code" AS markdown;

--- Table data
SELECT
  ''['' || control_id || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/hitrust_detail.sql?code='' || replace(control_id, '' '', ''%20'') || '')'' AS "Control Code",
  fii_id AS "Fii ID",
  common_criteria AS "Common Criteria",
  control_name AS "Control Name",
  control_question AS "Control Description"
FROM compliance_regime_control_hitrust_e1
ORDER BY control_code ASC
LIMIT $limit OFFSET $offset;

--- Pagination Controls (Bottom)
SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/hitrust_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    --- Breadcrumbs
    SELECT ''breadcrumb'' AS component;
    SELECT ''Home'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT ''Controls'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
    SELECT ''HiTRUST e1 Assessment'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/hitrust.sql'' AS link;
    SELECT COALESCE($code, '''') AS title, ''#'' AS link;

    --- Primary details card
    SELECT ''card'' AS component, ''HiTRUST Control Details'' AS title, 1 AS columns;
    SELECT
        COALESCE(control_id, ''(unknown)'') AS title,
        ''**Common Criteria:** '' || COALESCE(common_criteria,'''') || ''  

'' ||
        ''**Control Name:** '' || COALESCE(control_name,'''') || ''  

'' ||
        ''**Control Description:** '' || COALESCE(control_question,'''') || ''  

'' ||
        ''**FII ID:** '' || COALESCE(fii_id,'''') AS description_md
    FROM compliance_regime_control_hitrust_e1
    WHERE control_id = $code
    LIMIT 1;

    -- TODO Placeholder Card
    SELECT
      ''card'' AS component,
      1 AS columns;

      SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: '' || control_id || ''</b> &mdash; <b>FII ID: '' || fii_id || ''</b>.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM compliance_regime_control_hitrust_e1
WHERE control_id = $code::TEXT;

     
    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $code AND p.documentType = ''Author Prompt'' and regime = ''HiTRUST''
      ;

    
    SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      --accordion for audit prompt

SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM compliance_regime_control_hitrust_e1
WHERE control_id = $code::TEXT;

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $code AND p.documentType = ''Audit Prompt'' and regime = ''HiTRUST''
      ;
 SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      
SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM compliance_regime_control_hitrust_e1
WHERE control_id = $code::TEXT;

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $code and regimeType = ''HiTRUST'';
   SELECT ''html'' AS component,
      ''</div></details>'' AS html;
      SELECT ''html'' as component,
    ''<style>
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

    '' as html;


          -- end



 
 
    

    --- Fallback if no exact match
    SELECT ''text'' AS component,
          ''No exact control found for code: '' || COALESCE($code,''(empty)'') AS contents
    WHERE NOT EXISTS (
      SELECT 1 FROM compliance_regime_control_hitrust_e1 WHERE control_id = $code
    );
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/iso-27001.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/iso-27001.sql/index.sql'') as contents;
    ;

--- Breadcrumbs
SELECT ''breadcrumb'' AS component;
SELECT ''Home''     AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''          AS link;
SELECT ''Controls'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql''  AS link;
SELECT ''ISO 27001 v3'' AS title, ''#''                               AS link;

--- Description text
SELECT
  ''text'' AS component,
  ''The ISO 27001 v3 controls are aligned with the Secure Controls Framework (SCF) to provide a comprehensive mapping of security requirements.'' AS contents;

--- Pagination Controls (Top)
SET total_rows = (SELECT COUNT(*) FROM compliance_iso_27001_control );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

--- Table (markdown column for detail links)
SELECT
  ''table'' AS component,
  TRUE    AS sort,
  TRUE    AS search,
  "Control Code" AS markdown;

--- Table data
SELECT
  ''['' || control_code || '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/iso-27001_detail.sql?code='' || replace(control_code, '' '', ''%20'') || '')'' AS "Control Code",
  scf_domain        AS "SCF Domain",
  scf_control       AS "SCF Control",
  control_description AS "Control Description",
  control_question  AS "Control Question",
  evidence          AS "Evidence"
FROM compliance_iso_27001_control
ORDER BY control_code ASC
LIMIT $limit OFFSET $offset;

--- Pagination Controls (Bottom)
SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/iso-27001_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    --- Breadcrumbs
    SELECT ''breadcrumb'' AS component;
    SELECT ''Home'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT ''Controls'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
    SELECT ''ISO 27001 v3'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/iso-27001.sql'' AS link;
    SELECT COALESCE($code, '''') AS title, ''#'' AS link;

    --- Primary details card
    SELECT ''card'' AS component, ''ISO 27001 v3 Control Details'' AS title, 1 AS columns;
    SELECT
        COALESCE(control_code, ''(unknown)'') AS title,
        ''**SCF Domain:** '' || COALESCE(scf_domain,'''') || ''  

'' ||
        ''**SCF Control:** '' || COALESCE(scf_control,'''') || ''  

'' ||
        ''**Control Description:** '' || COALESCE(control_description,'''') || ''  

'' ||
        ''**Control Question:** '' || COALESCE(control_question,'''') || ''  

'' ||
        ''**Evidence:** '' || COALESCE(evidence,'''') AS description_md
    FROM compliance_iso_27001_control
    WHERE control_code = $code
    LIMIT 1;

    -- TODO Placeholder Card
    SELECT
      ''card'' AS component,
      1 AS columns;
 
      ---accordion start
      SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: '' || $code || ''</b> &mdash;.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM compliance_iso_27001_control
WHERE control_code = $code::TEXT;

     
    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $code AND p.documentType = ''Author Prompt'' and regime = ''ISO''
      ;

    
    SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      --accordion for audit prompt

SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM compliance_iso_27001_control
WHERE control_code = $code::TEXT;

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $code AND p.documentType = ''Audit Prompt'' and regime = ''ISO''
      ;
 SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      
SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM compliance_iso_27001_control
WHERE control_code = $code::TEXT;

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $code and regimeType = ''ISO'';
   SELECT ''html'' AS component,
      ''</div></details>'' AS html;
      SELECT ''html'' as component,
    ''<style>
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

    '' as html;


          -- end
    
     

    --- Fallback if no exact match
    SELECT ''text'' AS component,
          ''No exact control found for code: '' || COALESCE($code,''(empty)'') AS contents
    WHERE NOT EXISTS (
      SELECT 1 FROM compliance_iso_27001_control WHERE control_code = $code
    );
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/hipaa_security_rule.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ce/regime/hipaa_security_rule.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/hipaa_security_rule.sql/index.sql'') as contents;
    ;
 
SELECT
  ''text'' AS component,
  ''HIPAA'' AS title;
 
SELECT
  ''The HIPAA define administrative, physical, and technical measures required to ensure the confidentiality, integrity, and availability of electronic protected health information (ePHI).'' AS contents;
 
-- Pagination controls (top)
SET total_rows = (SELECT COUNT(*) FROM hipaa_security_rule_safeguards );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
 
SELECT
  ''table'' AS component,
  TRUE AS sort,
  TRUE AS search,
  "Control Code" AS markdown;
 
SELECT
  ''['' || hipaa_security_rule_reference || '']('' ||
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/hipaa_security_rule_detail.sql?id='' || hipaa_security_rule_reference || '')'' AS "Control Code",
  common_criteria AS "Common Criteria",
  safeguard AS "Control Question",
  handled_by_nq AS "Handled by nQ",
  fii_id AS "FII ID"
FROM hipaa_security_rule_safeguards
ORDER BY hipaa_security_rule_reference
LIMIT $limit OFFSET $offset;
 
-- Pagination controls (bottom)
SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/hipaa_security_rule_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
      SELECT
        ''breadcrumb'' AS component;
  
      SELECT
        ''Home'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
  
      SELECT
        ''Controls'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
  
      SELECT
        ''HIPAA'' AS title,
        sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/hipaa_security_rule.sql'' AS link;
 
      -- Dynamic last breadcrumb using the reference from the DB
      SELECT
        hipaa_security_rule_reference AS title,
        ''#'' AS link
      FROM hipaa_security_rule_safeguards
      WHERE hipaa_security_rule_reference = $id::TEXT;
  
      SELECT
        ''card'' AS component,
        ''HIPAA Security Rule Detail'' AS title,
        1 AS columns;
  
      SELECT
        common_criteria AS title,
        ''**Control Code:** '' || hipaa_security_rule_reference || ''  

'' ||
        ''**Control Question:** '' || safeguard || ''  

'' ||
        ''**FII ID:** '' || fii_id || ''  

''  AS description_md
      FROM hipaa_security_rule_safeguards
      WHERE hipaa_security_rule_reference = $id::TEXT;

      -- TODO Placeholder Card
    SELECT
      ''card'' AS component,
      1 AS columns;
 
          -- accordion for policy generator, audit prompt, and generated policies

              
   SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: '' || hipaa_security_rule_reference || ''</b> &mdash; <b>FII ID: '' || fii_id || ''</b>.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM hipaa_security_rule_safeguards
WHERE hipaa_security_rule_reference = $id::TEXT;

     
    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = ''Author Prompt''
      ;

    
    SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      --accordion for audit prompt

SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM hipaa_security_rule_safeguards
WHERE hipaa_security_rule_reference = $id::TEXT;

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = ''Audit Prompt''
      ;
 SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      
SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM hipaa_security_rule_safeguards
WHERE hipaa_security_rule_reference = $id::TEXT;

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $id;
   SELECT ''html'' AS component,
      ''</div></details>'' AS html;
      SELECT ''html'' as component,
    ''<style>
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

    '' as html;


          -- end;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/thsa.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/thsa.sql/index.sql'') as contents;
    ;
  
-- Breadcrumbs
SELECT ''breadcrumb'' AS component;
  
SELECT
  ''Home'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
  
SELECT
  ''Controls'' AS title,
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
  
SELECT
  ''Together.Health Security Assessment (THSA)'' AS title,
  ''#'' AS link;  
  
-- Page Heading
SELECT
  ''text'' AS component,
  ''Together.Health Security Assessment (THSA)'' AS title;
  
SELECT
  ''The THSA controls provide compliance requirements for health services, mapped against the Secure Controls Framework (SCF).'' AS contents;
  
-- Pagination controls (top)
SET total_rows = (SELECT COUNT(*) FROM compliance_regime_thsa );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;
  
-- Table
SELECT
  ''table'' AS component,
  TRUE AS sort,
  TRUE AS search,
  "Control Code" AS markdown;
  
SELECT
  ''['' || scf_code || '']('' ||
    sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/thsa_detail.sql?id='' || scf_code || '')'' AS "Control Code",
  scf_domain AS "Domain",
  scf_control AS "Control",
  scf_control_question AS "Control Question"
FROM compliance_regime_thsa
ORDER BY scf_code
LIMIT $limit OFFSET $offset;
  
-- Pagination controls (bottom)
SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/thsa_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    SELECT
      ''breadcrumb'' AS component;
 
    SELECT
      ''Home'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
 
    SELECT
      ''Controls'' AS title,
       sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
 
    SELECT
      ''Together.Health Security Assessment (THSA)'' AS title,
      sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/thsa.sql'' AS link;
 
    -- Dynamic last breadcrumb using the reference from the DB
    SELECT
      scf_code AS title,
      ''#'' AS link
    FROM compliance_regime_thsa
    WHERE scf_code = $id::TEXT;
 
    -- Main Control Detail Card
    SELECT
      ''card'' AS component,
      ''Together.Health Security Assessment (THSA) Detail'' AS title,
      1 AS columns;
 
    SELECT
      scf_domain AS title,
      ''**Control Code:** '' || scf_code || ''  

'' ||
      ''**Control Question:** '' || scf_control_question || ''  

''  AS description_md
    FROM compliance_regime_thsa
    WHERE scf_code = $id::TEXT;
 
    -- TODO Placeholder Card
    SELECT
      ''card'' AS component,
      1 AS columns;
 
 SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: '' || $id || ''</b> &mdash;.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM compliance_regime_thsa
WHERE scf_code = $id::TEXT;

     
    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = ''Author Prompt'' and regime = ''THSA''
      ;

    
    SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      --accordion for audit prompt

SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM compliance_regime_thsa
WHERE scf_code = $id::TEXT;

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_compliance_prompt p
      WHERE p.control_id = $id AND p.documentType = ''Audit Prompt'' and regime = ''THSA''
      ;
 SELECT ''html'' AS component,
      ''</div></details>'' AS html;

      
SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">'' AS html
FROM compliance_regime_thsa
WHERE scf_code = $id::TEXT;

    SELECT ''card'' as component, 1 as columns;
    SELECT
      ''
'' || p.body_text AS description_md
      FROM ai_ctxe_policy p
      WHERE p.control_id = $id and regimeType = ''THSA'';
   SELECT ''html'' AS component,
      ''</div></details>'' AS html;
      SELECT ''html'' as component,
    ''<style>
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

    '' as html;


          -- end;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/cmmc.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path=''ce/regime/cmmc.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title ,      
sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/''||link as link        
FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation
              

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/cmmc.sql/index.sql'') as contents;
    ;
SELECT ''text'' AS component, ''Cybersecurity Maturity Model Certification (CMMC)'' AS title;

SELECT
  "The Cybersecurity Maturity Model Certification (CMMC) program aligns with the information security requirements of the U.S. Department of Defense (DoD) for Defense Industrial Base (DIB) partners. The DoD has mandated that all organizations engaged in business with them, irrespective of size, industry, or level of involvement, undergo a cybersecurity maturity assessment based on the CMMC framework. This initiative aims to ensure the protection of sensitive unclassified information shared between the Department and its contractors and subcontractors. The program enhances the Department''s confidence that contractors and subcontractors adhere to cybersecurity requirements applicable to acquisition programs and systems handling controlled unclassified information" AS contents;

SELECT ''card'' AS component, '''' AS title, 3 AS columns;

SELECT
  ''CMMC Model 2.0 LEVEL 1'' AS title,
  ''**Geography**: US 

  **Source**: Department of Defense (DoD) 

  **Cybersecurity Maturity Model Certification (CMMC) - Level 1 (Foundational)** 

  **Version**: 2.0 

  **Published/Last Reviewed Date/Year**: 2021-11-04 00:00:00+00'' AS description_md, 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/cmmc_level.sql?level=1'' AS link
UNION
SELECT
  ''CMMC Model 2.0 LEVEL 2'' AS title,
  ''**Geography**: US 

  **Source**: Department of Defense (DoD) 

  **Cybersecurity Maturity Model Certification (CMMC) - Level 2 (Advanced)** 

  **Version**: 2.0 

  **Published/Last Reviewed Date/Year**: 2021-11-04 00:00:00+00'' AS description_md, 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/cmmc_level.sql?level=2''
UNION
SELECT
  ''CMMC Model 2.0 LEVEL 3'' AS title,
  ''**Geography**: US 

  **Source**: Department of Defense (DoD) 

  **Cybersecurity Maturity Model Certification (CMMC) - Level 3 (Expert)** 

  **Version**: 2.0 

  **Published/Last Reviewed Date/Year**: 2021-11-04 00:00:00+00'' AS description_md, 
  sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/cmmc_level.sql?level=3'';
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/cmmc_level.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/cmmc_level.sql/index.sql'') as contents;
    ;

    --- Breadcrumbs
    SELECT ''breadcrumb'' AS component;
    SELECT ''Home'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
    SELECT ''Controls'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
    SELECT ''CMMC'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/cmmc.sql'' AS link;
    SELECT ''CMMC Level '' || COALESCE(@level::TEXT,'''') AS title, ''#'' AS link;

    --- Description text
    SELECT ''text'' AS component,
       "The Cybersecurity Maturity Model Certification (CMMC) program aligns with the information security requirements of the U.S. Department of Defense (DoD) for Defense Industrial Base (DIB) partners. The DoD has mandated that all organizations engaged in business with them, irrespective of size, industry, or level of involvement, undergo a cybersecurity maturity assessment based on the CMMC framework. This initiative aims to ensure the protection of sensitive unclassified information shared between the Department and its contractors and subcontractors. The program enhances the Department''s confidence that contractors and subcontractors adhere to cybersecurity requirements applicable to acquisition programs and systems handling controlled unclassified information" AS contents;


    --- Table (markdown column)
    SELECT ''table'' AS component, TRUE AS sort, TRUE AS search, "Control Code" AS markdown;

    -- Pagination Controls (Top)
    SET total_rows = (SELECT COUNT(*) FROM scf_view 
      WHERE 
        (@level = 1 AND cmmc_level_1 IS NOT NULL AND cmmc_level_1 != '''')
     OR (@level = 2 AND cmmc_level_2 IS NOT NULL AND cmmc_level_2 != '''')
     OR (@level = 3 AND cmmc_level_3 IS NOT NULL AND cmmc_level_3 != '''')
    );
SET limit = COALESCE($limit, 50);
SET offset = COALESCE($offset, 0);
SET total_pages = ($total_rows + $limit - 1) / $limit;
SET current_page = ($offset / $limit) + 1;

    --- Table data
    SELECT
      ''['' || replace(replace(
          CASE 
            WHEN @level = 1 THEN cmmc_level_1
            WHEN @level = 2 THEN cmmc_level_2
            ELSE cmmc_level_3
          END,
          ''
'', '' ''),
          '''', '' '')
|| '']('' || sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/cmmc_detail.sql?code='' 
|| replace(replace( 
    CASE  
      WHEN @level = 1 THEN cmmc_level_1 
      WHEN @level = 2 THEN cmmc_level_2 
      ELSE cmmc_level_3 
    END, 
    ''
'', '' ''), '' '', ''%20'') 
|| ''&fiiid='' || replace(control_code, '' '', ''%20'')
|| ''&level='' || @level
|| '')'' AS "Control Code",

      scf_domain       AS "Domain",
      scf_control      AS "Title",
      control_code     AS "FII ID",
      control_description AS "Control Description",
      control_question AS "Question"

    FROM scf_view
    WHERE 
          (@level = 1 AND cmmc_level_1 IS NOT NULL AND cmmc_level_1 != '''')
      OR (@level = 2 AND cmmc_level_2 IS NOT NULL AND cmmc_level_2 != '''')
      OR (@level = 3 AND cmmc_level_3 IS NOT NULL AND cmmc_level_3 != '''')
    ORDER BY control_code
    LIMIT $limit OFFSET $offset;

    -- Pagination Controls (Bottom)
    SELECT ''text'' AS component,
    (SELECT CASE WHEN CAST($current_page AS INTEGER) > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || COALESCE(''&level='' || replace($level, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    || '' ''
    || ''(Page '' || $current_page || '' of '' || $total_pages || ") "
    || (SELECT CASE WHEN CAST($current_page AS INTEGER) < CAST($total_pages AS INTEGER) THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || COALESCE(''&level='' || replace($level, '' '', ''%20''), '''') || '')'' ELSE '''' END)
    AS contents_md
;
        ;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/cmmc_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
  SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''ce/regime/cmmc_detail.sql/index.sql'') as contents;
    ;
  --- Breadcrumbs
  SELECT ''breadcrumb'' AS component;
  SELECT ''Home'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/'' AS link;
  SELECT ''Controls'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/index.sql'' AS link;
  SELECT ''CMMC'' AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/cmmc.sql'' AS link;
  SELECT ''CMMC Level '' || COALESCE($level::TEXT, '''') AS title, sqlpage.environment_variable(''SQLPAGE_SITE_PREFIX'') || ''/ce/regime/cmmc_level.sql?level='' || COALESCE($level::TEXT,''1'') AS link;
  SELECT COALESCE($code, '''') AS title, ''#'' AS link;

  

  --- Primary details card
  SELECT ''card'' AS component, ''CMMC Control Details'' AS title, 1 AS columns;
  SELECT
      COALESCE($code, ''(unknown)'') AS title,
      ''**Control Question:** '' || COALESCE(control_question, '''') || ''  

'' ||
      ''**Control Description:** '' || COALESCE(control_description, '''') || ''  

'' ||
      ''**SCF Domain:** '' || COALESCE(scf_domain, '''') || ''  

'' ||
      ''**SCF Control:** '' || COALESCE(scf_control, '''') || ''  

'' ||
      ''**FII IDs:** '' || COALESCE($fiiid, '''') AS description_md
      
  FROM scf_view
  WHERE
       ( ($level = 1 AND replace(replace(cmmc_level_1,''
'','' ''),''\r'','''') = $code)
    OR ($level = 2 AND replace(replace(cmmc_level_2,''
'','' ''),''\r'','''') = $code)
    OR ($level = 3 AND replace(replace(cmmc_level_3,''
'','' ''),''\r'','''') = $code))
    AND control_code = $fiiid
  LIMIT 1;

  -- TODO Placeholder Card
  SELECT
    ''card'' AS component,
    1 AS columns;

  -- Policy Generator Prompt Accordion
  SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Generator Prompt 
  <br>
  Create tailored policies directly for <b>Control Code: '' || $code || ''</b> &mdash; <b>Level: '' || $level || ''</b>.
  The "Policy Generator Prompt" lets you transform abstract requirements into actionable, 
  written policies. Simply provide the relevant control or framework element, and the prompt
  will guide you in producing a policy that aligns with best practices, regulatory standards, 
  and organizational needs. This makes policy creation faster, consistent, and accessible—even 
  for teams without dedicated compliance writers.
    </summary>
    <div class="test-detail-outer-content">'' AS html;

  SELECT ''card'' as component, 1 as columns;
  SELECT
    ''
'' || p.body_text AS description_md
    FROM ai_ctxe_compliance_prompt p
   
    WHERE p.control_id = $code AND  p.documentType = ''Author Prompt'' AND p.fii_id=$fiiid
    AND (
    ($level = 1 AND regime = ''CMMC'' AND category_type=''Level 1'') OR
    ($level = 2 AND regime = ''CMMC'' AND category_type=''Level 2'') OR
    ($level = 3 AND regime = ''CMMC'' AND category_type=''Level 3'')
    );
   

  SELECT ''html'' AS component,
    ''</div></details>'' AS html;

  -- Policy Audit Prompt Accordion
  SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Policy Audit Prompt 
      <br>
      Ensure your policies stay effective and compliant with the "Policy Audit Prompt". These prompts are designed to help users critically evaluate existing policies against standards, frameworks, and internal expectations. By running an audit prompt, you can identify gaps, inconsistencies, or outdated language, and quickly adjust policies to remain audit-ready and regulator-approved. This gives your team a reliable tool for continuous policy improvement and compliance assurance.
    </summary>
    <div class="test-detail-outer-content">'' AS html;

  SELECT ''card'' as component, 1 as columns;
  SELECT
    ''
'' || p.body_text AS description_md
    FROM ai_ctxe_compliance_prompt p
    WHERE p.control_id = $code AND p.documentType = ''Audit Prompt'' AND p.fii_id=$fiiid AND
   ( 
    ($level = 1 AND regime = ''CMMC'' AND category_type=''Level 1'') OR
    ($level = 2 AND regime = ''CMMC'' AND category_type=''Level 2'') OR
    ($level = 3 AND regime = ''CMMC'' AND category_type=''Level 3'')
    );

  SELECT ''html'' AS component,
    ''</div></details>'' AS html;

  -- Generated Policies Accordion
  SELECT ''html'' AS component,
  ''<details class="test-detail-outer-accordion" open>
    <summary class="test-detail-outer-summary">
      Generated Policies
      <br>
      The Generated Policies section showcases real examples of policies created using the "Policy Generator Prompt". These samples illustrate how high-level controls are translated into concrete, practical policy documents. Each generated policy highlights structure, clarity, and compliance alignment—making it easier for users to adapt and deploy them within their own organizations. Think of this as a living library of ready-to-use policy templates derived directly from controls.
    </summary>
    <div class="test-detail-outer-content">'' AS html;

  SELECT ''card'' as component, 1 as columns;
  SELECT
    ''
'' || p.body_text AS description_md
    FROM ai_ctxe_policy p
    WHERE p.control_id = $code AND p.fii_id=$fiiid
    
    AND 
    (($level = 1 AND regimeType = ''CMMC'' AND category_type=''Level 1'') OR
    ($level = 2 AND regimeType = ''CMMC'' AND category_type=''Level 2'') OR
    ($level = 3 AND regimeType = ''CMMC'' AND category_type=''Level 3'')
    );

  SELECT ''html'' AS component,
    ''</div></details>'' AS html;

  -- CSS Styles
  SELECT ''html'' as component,
  ''<style>
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
  </style>'' as html;

  --- Fallback if no exact match
  SELECT ''text'' AS component,
        ''No exact control found for code: '' || COALESCE($code,''(empty)'') || ''. Showing a fallback example for Level '' || COALESCE($level::TEXT,''1'') || ''.'' AS contents
  WHERE NOT EXISTS (
      SELECT 1 FROM scf_view
      WHERE
            ($level = 1 AND replace(replace(cmmc_level_1,''
'','' ''),''\r'','''') = $code)
        OR ($level = 2 AND replace(replace(cmmc_level_2,''
'','' ''),''\r'','''') = $code)
        OR ($level = 3 AND replace(replace(cmmc_level_3,''
'','' ''),''\r'','''') = $code)
  );

  --- Example fallback card (optional)
  SELECT ''card'' AS component, ''Fallback control'' AS title, 1 AS columns
  WHERE NOT EXISTS (
      SELECT 1 FROM scf_view
      WHERE
            ($level = 1 AND replace(replace(cmmc_level_1,''
'','' ''),''\r'','''') = $code)
        OR ($level = 2 AND replace(replace(cmmc_level_2,''
'','' ''),''\r'','''') = $code)
        OR ($level = 3 AND replace(replace(cmmc_level_3,''
'','' ''),''\r'','''') = $code)
  );
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'ce/regime/control/control_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation
              

              
    SELECT
    ''card'' AS component,
    ''Control Details'' AS title,
    1 AS columns;
    SELECT
      control_code AS title,
      ''**Control Question:** '' || REPLACE(REPLACE(control_question, ''▪'', ''-''), ''
'', ''  
'') || ''  

'' ||
      ''**Control Description:** '' || REPLACE(REPLACE(control_description, ''▪'', ''-''), ''
'', ''  
'') || ''  

'' ||
      ''**Control Id:** '' || control_id || ''  

'' ||
      ''**Control Domain:** '' || scf_domain || ''  

'' ||
      ''**SCF Control:** '' || scf_control AS description_md
    FROM compliance_regime_control
    WHERE control_code = $id::TEXT AND control_type = $regimeType::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
