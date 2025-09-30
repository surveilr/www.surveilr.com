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

DROP VIEW IF EXISTS ai_ctxe_complaince_prompt;
CREATE VIEW ai_ctxe_complaince_prompt AS
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