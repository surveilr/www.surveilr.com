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


