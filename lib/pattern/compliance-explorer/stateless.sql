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


DROP VIEW IF EXISTS ai_ctxe_policy;
CREATE VIEW ai_ctxe_policy AS
SELECT distinct 
  ur.uniform_resource_id,
  json_extract(ur.frontmatter, '$.title') AS title,
  json_extract(ur.frontmatter, '$.description') AS description,
  json_extract(ur.frontmatter, '$.publishDate') AS publishDate,
  json_extract(ur.frontmatter, '$.publishBy') AS publishBy,
  json_extract(ur.frontmatter, '$.classification') AS classification,
  json_extract(ur.frontmatter, '$.documentType') AS documentType,
  json_extract(ur.frontmatter, '$.approvedBy') AS approvedBy,
  json_extract(ur.frontmatter, '$.category') AS category,
  je.value AS satisfies,
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
LEFT JOIN
  json_each(json_extract(ur.frontmatter, '$.satisfies')) je
WHERE
  fs.file_basename LIKE '%.policy.md';
