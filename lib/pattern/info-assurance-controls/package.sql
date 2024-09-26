-- code provenance: `TypicalSqlPageNotebook.commonDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/notebook/sqlpage.ts)
-- idempotently create location where SQLPage looks for its content
CREATE TABLE IF NOT EXISTS "sqlpage_files" (
  "path" VARCHAR PRIMARY KEY NOT NULL,
  "contents" TEXT NOT NULL,
  "last_modified" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
-- --------------------------------------------------------------------------------
-- Script to prepare convenience views to access uniform_resource.content column
-- as CCDA content, ensuring only valid JSON is processed.
-- --------------------------------------------------------------------------------

-- TODO: will this help performance?
-- CREATE INDEX IF NOT EXISTS idx_resource_type ON uniform_resource ((content ->> '$.resourceType'));
-- CREATE INDEX IF NOT EXISTS idx_bundle_entry ON uniform_resource ((json_type(content -> '$.entry')));

-- CCDA Discovery and Enumeration Views  
-- --------------------------------------------------------------------------------

-- Summary of the uniform_resource table
-- Provides a count of total rows, valid JSON rows, invalid JSON rows,
-- and potential CCDA v4 candidates and bundles based on JSON structure.

DROP VIEW IF EXISTS uniform_resource_summary;
CREATE VIEW uniform_resource_summary AS
    SELECT
        COUNT(*) AS total_rows,
        SUM(CASE WHEN json_valid(content) THEN 1 ELSE 0 END) AS valid_json_rows,
        SUM(CASE WHEN json_valid(content) THEN 0 ELSE 1 END) AS invalid_json_rows,
        SUM(CASE WHEN json_valid(content) AND content ->> '$.resourceType' IS NOT NULL THEN 1 ELSE 0 END) AS ccda_v4_candidates,
        SUM(CASE WHEN json_valid(content) AND json_type(content -> '$.entry') = 'array' THEN 1 ELSE 0 END) AS ccda_v4_bundle_candidates
    FROM
        uniform_resource;

DROP VIEW IF EXISTS control_regimes;
CREATE VIEW IF NOT EXISTS control_regimes AS
              SELECT
                reg.name as control_regime,
                reg.control_regime_id as control_regime_id,
                audit.name as audit_type_name,
                audit.control_regime_id as audit_type_id
              FROM
                  control_regime as audit
              INNER JOIN control_regime as reg ON audit.parent_id = reg.control_regime_id;

DROP VIEW IF EXISTS control_group;
CREATE VIEW IF NOT EXISTS control_group AS 
          SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type I' AND parent_id!="") AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type I' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM
              uniform_resource_aicpa_soc2_controls
            GROUP BY
              "Common Criteria"
              
          UNION ALL

            SELECT
            cast("#" as int)  as display_order,
            ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
            (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type II' AND parent_id!="") AS control_group_id,
            "Common Criteria" AS title,
            (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type II' AND parent_id!="") AS audit_type_id,
            NULL AS parent_id
              FROM uniform_resource_aicpa_soc2_type2_controls
            GROUP BY
              "Common Criteria" 
          
          UNION ALL

            SELECT
            cast("#" as int)  as display_order,
            ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
            (SELECT control_regime_id FROM control_regime WHERE name='HIPAA' AND parent_id!="") AS control_group_id,
            "Common Criteria" AS title,
            (SELECT control_regime_id FROM control_regime WHERE name='HIPAA' AND parent_id!="") AS audit_type_id,
            NULL AS parent_id
              FROM uniform_resource_hipaa_security_rule_safeguards
            GROUP BY
              "Common Criteria"

          UNION ALL

            SELECT
            cast("#" as int)  as display_order,
            ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
            (SELECT control_regime_id FROM control_regime WHERE name='HiTRUST e1 Assessment' AND parent_id!="") AS control_group_id,
            "Common Criteria" AS title,
            (SELECT control_regime_id FROM control_regime WHERE name='HiTRUST e1 Assessment' AND parent_id!="") AS audit_type_id,
            NULL AS parent_id
              FROM uniform_resource_hitrust_e1_assessment
            GROUP BY
              "Common Criteria" 

          UNION ALL

            SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND sub."US CMMC 2.0 Level 1" != "") AS display_order,
              ROW_NUMBER() OVER (ORDER BY cntl."SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 1' AND parent_id!="") AS control_group_id,
              cntl."SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 1' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scf_2024_2 cntl
            WHERE
              cntl."US CMMC 2.0 Level 1" != ""
            GROUP BY
              cntl."SCF Domain"

          UNION ALL

            SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND sub."US CMMC 2.0 Level 2" != "") AS display_order,
              ROW_NUMBER() OVER (ORDER BY cntl."SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 2' AND parent_id!="") AS control_group_id,
              cntl."SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 2' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scf_2024_2 cntl
            WHERE
              cntl."US CMMC 2.0 Level 2" != ""
            GROUP BY
              cntl."SCF Domain"

          UNION ALL

            SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND sub."US CMMC 2.0 Level 3" != "") AS display_order,
              ROW_NUMBER() OVER (ORDER BY "SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 3' AND parent_id!="") AS control_group_id,
              cntl."SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 3' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scf_2024_2 cntl
            WHERE
              cntl."US CMMC 2.0 Level 3" != ""
            GROUP BY
              cntl."SCF Domain"
            
          UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Together.Health Security Assessment (THSA)' AND parent_id!="") AS control_group_id,
              "SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Together.Health Security Assessment (THSA)' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_thsa
            GROUP BY
              "SCF Domain"
          
          UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Code Quality Infrastructure' AND parent_id!="") AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Code Quality Infrastructure' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_code_quality_infrastructure
            GROUP BY
              "Common Criteria"

          UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Database Quality Infrastructure' AND parent_id!="") AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Database Quality Infrastructure' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_database_quality_infrastructure
            GROUP BY
              "Common Criteria"

          UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Scheduled Audit' AND parent_id!="") AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Scheduled Audit' AND parent_id!="") AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scheduled_audit
            GROUP BY
              "Common Criteria";

DROP VIEW IF EXISTS control;
CREATE VIEW IF NOT EXISTS control AS
            WITH control_regime_cte AS (
              SELECT
                reg.name as control_regime,
                reg.control_regime_id as control_regime_id,
                audit.name as audit_type_name,
                audit.control_regime_id as audit_type_id
              FROM
                  control_regime as audit
              INNER JOIN control_regime as reg ON audit.parent_id = reg.control_regime_id
            )
            SELECT
              CAST(cntl."#" AS INTEGER) AS display_order,
              cg.control_group_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."FII Id", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS control_id,
              cntl."Control Identifier" AS control_identifier,
              cntl."Control Identifier" AS control_code,
              cntl."Fii ID" AS fii,
              cntl."Common Criteria" AS common_criteria,
              cntl."Name" AS expected_evidence,
              cntl."Questions Descriptions" AS question,
              (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS control_regime,
              (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS control_regime_id,
              (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS audit_type,
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type I') AS audit_type_id
            FROM
                uniform_resource_aicpa_soc2_controls cntl
            INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
            WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type I')

        UNION ALL

            SELECT
              CAST(cntl."#" AS INTEGER) AS display_order,
              cg.control_group_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
              || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."FII Id", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') as control_id,
              cntl."Control Identifier" AS control_identifier,"Control Identifier" AS control_code, "Fii ID" AS fii,
              cntl."Common Criteria" AS common_criteria,
              cntl."Name" AS expected_evidence,
              cntl."Questions Descriptions" AS question,
              (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') AS control_regime,
              (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') AS control_regime_id,
              (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') AS audit_type,
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type II') AS audit_type_id
            FROM uniform_resource_aicpa_soc2_type2_controls cntl
            INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
            WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='SOC2 Type II')

        UNION ALL

          SELECT
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."HIPAA Security Rule Reference", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."FII Id", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HIPAA') as control_id,
            cntl."HIPAA Security Rule Reference" AS control_identifier,
            cntl."HIPAA Security Rule Reference" AS control_code,
            cntl."FII Id" AS fii,
            cntl."Common Criteria" AS common_criteria,
            "" AS expected_evidence,
            cntl.Safeguard AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='HIPAA') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='HIPAA') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='HIPAA') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HIPAA') AS audit_type_id
          FROM uniform_resource_hipaa_security_rule_safeguards cntl
          INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HIPAA')

        UNION ALL

          SELECT
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Fii ID", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') as control_id,
            cntl."Control Identifier" AS control_identifier,"Control Identifier" AS control_code, "Fii ID" AS fii,
            cntl."Common Criteria" AS common_criteria,
            cntl."Name" AS expected_evidence,
            cntl.Description AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment') AS audit_type_id
          FROM uniform_resource_hitrust_e1_assessment cntl
          INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='HiTRUST e1 Assessment')

        UNION ALL

          SELECT
            (SELECT COUNT(*)
            FROM uniform_resource_scf_2024_2 AS sub
            WHERE sub.ROWID <= cntl.ROWID AND "US CMMC 2.0 Level 1" != "") AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."US CMMC 2.0 Level 1", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' || 
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') as control_id,
            'CMMCLEVEL-' || (ROWID) as control_identifier,
            cntl."US CMMC 2.0 Level 1" AS control_code,
            cntl."SCF #" AS fii,
            cntl."SCF Domain" AS common_criteria,
            "" AS expected_evidence,
            cntl."SCF Control Question" AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS audit_type_id
          FROM
              uniform_resource_scf_2024_2 AS cntl
              INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
          WHERE
              cntl."US CMMC 2.0 Level 1" != "" AND cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1')

        UNION ALL

          SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND "US CMMC 2.0 Level 2" != "") AS display_order,
              cg.control_group_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."US CMMC 2.0 Level 2", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
              || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') as control_id,
              'CMMCLEVEL-' || (ROWID) AS control_identifier,
              cntl."US CMMC 2.0 Level 2" AS control_code,
              cntl."SCF #" AS fii,
              cntl."SCF Domain" AS common_criteria,
              "" AS expected_evidence,
              cntl."SCF Control Question" AS question,
              (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS control_regime,
              (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS control_regime_id,
              (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS audit_type,
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS audit_type_id
          FROM
              uniform_resource_scf_2024_2 cntl
              INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
          WHERE
              "US CMMC 2.0 Level 2" != "" AND cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2')

        UNION ALL

          SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND "US CMMC 2.0 Level 3" != "") AS display_order,
              cg.control_group_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."US CMMC 2.0 Level 3", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
              || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') as control_id,
              'CMMCLEVEL-' || (ROWID) AS control_identifier,
              cntl."US CMMC 2.0 Level 3" AS control_code,
              cntl."SCF #" AS fii,
              cntl."SCF Domain" AS common_criteria,
              "" AS expected_evidence,
              cntl."SCF Control Question" AS question,
              (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS control_regime,
              (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS control_regime_id,
              (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS audit_type,
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS audit_type_id
          FROM
              uniform_resource_scf_2024_2 cntl
              INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
          WHERE
              "US CMMC 2.0 Level 3" != "" AND cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3')

        UNION ALL

          SELECT 
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') as control_id,
            cntl."SCF #" AS control_identifier,
            cntl."SCF #" AS control_code,
            cntl."SCF #" AS fii,
            cntl."SCF Domain" AS common_criteria,
            "" AS expected_evidence, 
            cntl."SCF Control Question" AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)') AS audit_type_id
          FROM uniform_resource_thsa cntl
          INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Together.Health Security Assessment (THSA)')

        UNION ALL

          SELECT 
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') as control_id,
            cntl."Control Identifier" AS control_identifier,
            cntl."Control Identifier" AS control_code,
            cntl."Control Identifier" AS fii,
            cntl."Common Criteria" AS common_criteria,
            cntl."Name" AS expected_evidence,
            cntl."Questions Descriptions" AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure') AS audit_type_id
          FROM uniform_resource_code_quality_infrastructure cntl
          INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Code Quality Infrastructure')

        UNION ALL

          SELECT 
            CAST(cntl."#" AS INTEGER) AS display_order,
            cg.control_group_id,
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
            || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') as control_id,
            cntl."Control Identifier" AS control_identifier,
            cntl."Control Identifier" AS control_code,
            cntl."Control Identifier" AS fii,
            cntl."Common Criteria" AS common_criteria,
            cntl."Name" AS expected_evidence,
            cntl."Questions Descriptions" AS question,
            (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') AS control_regime,
            (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') AS control_regime_id,
            (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') AS audit_type,
            (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure') AS audit_type_id
          FROM uniform_resource_database_quality_infrastructure cntl
          INNER JOIN control_group cg ON cg.title=cntl."Common Criteria" 
          WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Database Quality Infrastructure')

        UNION ALL

        SELECT 
          CAST(cntl."#" AS INTEGER) AS display_order,
          cg.control_group_id,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Control Identifier", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
          || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."Fii ID", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
          (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') as control_id,
          cntl."Control Identifier" AS control_identifier,
          cntl."Control Identifier" AS control_code,
          cntl."Fii ID" AS fii,
          cntl."Common Criteria" AS common_criteria,
          cntl."Name" AS expected_evidence,
          cntl."Questions Descriptions" AS question,
          (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') AS control_regime,
          (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') AS control_regime_id,
          (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') AS audit_type,
          (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Scheduled Audit') AS audit_type_id
        FROM uniform_resource_scheduled_audit cntl
        INNER JOIN control_group cg ON cg.title=cntl."Common Criteria"
        WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Scheduled Audit');



/* 'orchestrateStatefulControlSQL' in '[object Object]' returned type undefined instead of string | string[] | SQLa.SqlTextSupplier */
-- code provenance: `ConsoleSqlPages.infoSchemaDDL` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)

-- console_information_schema_* are convenience views
-- to make it easier to work than pragma_table_info.

DROP VIEW IF EXISTS console_information_schema_table;
CREATE VIEW console_information_schema_table AS
SELECT
    tbl.name AS table_name,
    col.name AS column_name,
    col.type AS data_type,
    CASE WHEN col.pk = 1 THEN 'Yes' ELSE 'No' END AS is_primary_key,
    CASE WHEN col."notnull" = 1 THEN 'Yes' ELSE 'No' END AS is_not_null,
    col.dflt_value AS default_value,
    '/console/info-schema/table.sql?name=' || tbl.name || '&stats=yes' as info_schema_web_ui_path,
    '[Content](/console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || tbl.name || ' (table) Schema](/console/info-schema/table.sql?name=' || tbl.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/table/' || tbl.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content](/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || tbl.name || ' (table) Content](/console/content/table/' || tbl.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
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
    '[Content](/console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_abbrev_md,
    '[' || vw.name || ' (view) Schema](/console/info-schema/view.sql?name=' || vw.name || '&stats=yes)' as info_schema_link_full_md,
    '/console/content/view/' || vw.name || '.sql?stats=yes' as content_web_ui_path,
    '[Content](/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_abbrev_md,
    '[' || vw.name || ' (view) Content](/console/content/view/' || vw.name || '.sql?stats=yes)' as content_web_ui_link_full_md,
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
    -- TODO: figure out why Rusqlite does not allow this but sqlite3 does
    -- CONSTRAINT fk_parent_path FOREIGN KEY (namespace, parent_path) REFERENCES sqlpage_aide_navigation(namespace, path),
    CONSTRAINT unq_ns_path UNIQUE (namespace, parent_path, path)
);
DELETE FROM sqlpage_aide_navigation WHERE path LIKE '/console/%';
DELETE FROM sqlpage_aide_navigation WHERE path LIKE '/';

-- all @navigation decorated entries are automatically added to this.navigation
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description)
VALUES
    ('prime', NULL, 1, '/', '/', 'Home', NULL, 'Resource Surveillance State Database (RSSD)', 'Welcome to Resource Surveillance State Database (RSSD)'),
    ('prime', '/', 999, '/console', '/console/', 'RSSD Console', 'Console', 'Resource Surveillance State Database (RSSD) Console', 'Explore RSSD information schema, code notebooks, and SQLPage files'),
    ('prime', '/console', 1, '/console/info-schema', '/console/info-schema/', 'RSSD Information Schema', 'Info Schema', NULL, 'Explore RSSD tables, columns, views, and other information schema documentation'),
    ('prime', '/console', 3, '/console/sqlpage-files', '/console/sqlpage-files/', 'RSSD SQLPage Files', 'SQLPage Files', NULL, 'Explore RSSD SQLPage Files which govern the content of the web-UI'),
    ('prime', '/console', 3, '/console/sqlpage-files/content.sql', '/console/sqlpage-files/content.sql', 'RSSD Data Tables Content SQLPage Files', 'Content SQLPage Files', NULL, 'Explore auto-generated RSSD SQLPage Files which display content within tables'),
    ('prime', '/console', 3, '/console/sqlpage-nav', '/console/sqlpage-nav/', 'RSSD SQLPage Navigation', 'SQLPage Navigation', NULL, 'See all the navigation entries for the web-UI; TODO: need to improve this to be able to get details for each navigation entry as a table'),
    ('prime', '/console', 2, '/console/notebooks', '/console/notebooks/', 'RSSD Code Notebooks', 'Code Notebooks', NULL, 'Explore RSSD Code Notebooks which contain reusable SQL and other code blocks')
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
              SELECT ''''Home'''' as title, ''''/'''' AS link;
              SELECT ''''Console'''' as title, ''''/console'''' AS link;
              SELECT ''''Content'''' as title, ''''/console/content'''' AS link;
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
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
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
              SELECT ''Home'' as title, ''/'' AS link;
              SELECT ''Console'' as title, ''/console'' AS link;
              SELECT ''Content'' as title, ''/console/content'' AS link;
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
            'SELECT ''redirect'' AS component, ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql'' AS link WHERE $stats IS NULL;
' ||
            'SELECT ''redirect'' AS component, ''/console/content/' || tabular_nature || '/' || tabular_name || '.auto.sql?stats='' || $stats AS link WHERE $stats IS NOT NULL;'
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows
-- delete all /fhir-related entries and recreate them in case routes are changed
DELETE FROM sqlpage_aide_navigation WHERE path like '/fhir%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description)
VALUES
    ('prime', '/', 1, '/ur', '/ur/', 'Uniform Resource', NULL, NULL, 'Explore ingested resources'),
    ('prime', '/ur', 99, '/ur/info-schema.sql', '/ur/info-schema.sql', 'Uniform Resource Tables and Views', NULL, NULL, 'Information Schema documentation for ingested Uniform Resource database objects'),
    ('prime', '/ur', 1, '/ur/uniform-resource-files.sql', '/ur/uniform-resource-files.sql', 'Uniform Resources (Files)', NULL, NULL, 'Files ingested into the `uniform_resource` table')
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
  LEFT JOIN ur_ingest_session_fs_path p ON ur.ingest_fs_path_id = p.ur_ingest_session_fs_path_id
  LEFT JOIN ur_ingest_session_fs_path_entry pe ON ur.uniform_resource_id = pe.uniform_resource_id
  WHERE ur.ingest_fs_path_id IS NOT NULL;
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description)
VALUES
    ('prime', '/', 1, '/orchestration', '/orchestration/', 'Orchestration', NULL, NULL, 'Explore details about all orchestration'),
    ('prime', '/orchestration', 99, '/orchestration/info-schema.sql', '/orchestration/info-schema.sql', 'Orchestration Tables and Views', NULL, NULL, 'Information Schema documentation for orchestrated objects')
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
DELETE FROM sqlpage_aide_navigation WHERE path like '/opsfolio/info/control%';
INSERT INTO sqlpage_aide_navigation (namespace, parent_path, sibling_order, path, url, caption, abbreviated_caption, title, description)
VALUES
    ('prime', '/', 1, '/opsfolio', '/opsfolio/', 'Opsfolio', NULL, NULL, 'Opsfolio'),
    ('prime', '/opsfolio', 2, '/opsfolio/info/control/control_dashboard.sql', '/opsfolio/info/control/control_dashboard.sql', 'Information Assurance Controls', NULL, NULL, 'The Infra Controls is designed to manage and implement controls specific
      to various audit requirements, such as CC1001, CC1002, and others. This project
      provides a platform for defining, applying, and tracking the effectiveness of
      these controls, ensuring that your organization meets the necessary standards
      for audit compliance.'),
    ('prime', '/opsfolio', 3, '/opsfolio/info/control/control.sql', '/opsfolio/info/control/control.sql', 'Control Regimes', NULL, NULL, NULL),
    ('prime', '/opsfolio', 4, '/opsfolio/info/control/control_regime.sql', '/opsfolio/info/control/control_regime.sql', 'Audit Types', NULL, NULL, NULL),
    ('prime', '/opsfolio', 5, '/opsfolio/info/control/controls.sql', '/opsfolio/info/control/controls.sql', 'Control List', NULL, NULL, NULL),
    ('prime', '/opsfolio', 6, '/opsfolio/info/control/control_detail.sql', '/opsfolio/info/control/control_detail.sql', 'Control Details', NULL, NULL, NULL)
ON CONFLICT (namespace, parent_path, path)
DO UPDATE SET title = EXCLUDED.title, abbreviated_caption = EXCLUDED.abbreviated_caption, description = EXCLUDED.description, url = EXCLUDED.url, sibling_order = EXCLUDED.sibling_order;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'shell/shell.json',
      '{
  "component": "shell",
  "title": "Resource Surveillance State Database (RSSD)",
  "icon": "database",
  "layout": "fluid",
  "fixed_top_menu": true,
  "link": "/",
  "menu_item": [
    {
      "link": "/",
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
       ''Resource Surveillance State Database (RSSD)'' AS title,
       ''database'' AS icon,
       ''fluid'' AS layout,
       true AS fixed_top_menu,
       ''/'' AS link,
       ''{"link":"/","title":"Home"}'' AS menu_item,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/sql.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/handlebars.min.js'' AS javascript,
       ''https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/languages/json.min.js'' AS javascript,
       json_object(
              ''link'', ''/ur'',
              ''title'', ''Uniform Resource'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/ur''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', ''/console'',
              ''title'', ''Console'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/console''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       json_object(
              ''link'', ''/orchestration'',
              ''title'', ''Orchestration'',
              ''submenu'', (
                  SELECT json_group_array(
                      json_object(
                          ''title'', title,
                          ''link'', link,
                          ''description'', description
                      )
                  )
                  FROM (
                      SELECT
                          COALESCE(abbreviated_caption, caption) as title,
                          COALESCE(url, path) as link,
                          description
                      FROM sqlpage_aide_navigation
                      WHERE namespace = ''prime'' AND parent_path = ''/orchestration''
                      ORDER BY sibling_order
                  )
              )
          ) as menu_item,
       ''Resource Surveillance Web UI (v'' || sqlpage.version() || '') '' || ''📄 ['' || substr(sqlpage.path(), 2) || ''](/console/sqlpage-files/sqlpage-file.sql?path='' || substr(sqlpage.path(), 2) || '')'' as footer;',
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
 WHERE namespace = ''prime'' AND parent_path = ''/''
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
    WHERE namespace = ''prime'' AND path = ''/console''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH console_navigation_cte AS (
    SELECT title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path = ''/console''
)
SELECT ''list'' AS component, title, description
  FROM console_navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''/console''
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
    WHERE namespace = ''prime'' AND path = ''/console/info-schema''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
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
    content_web_ui_link_abbrev_md as "Content"
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
    content_web_ui_link_abbrev_md as "Content"
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
    WHERE namespace = ''prime'' AND path = ''/console/info-schema''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
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
    WHERE namespace = ''prime'' AND path = ''/console/info-schema''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
SELECT $name || '' View'' AS title, ''#'' AS link;

SELECT ''title'' AS component, $name AS contents;
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
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-files''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage pages in sqlpage_files table'' AS contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT
  ''[🚀](/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
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
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-files''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
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
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-files/content.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''SQLPage pages generated from tables and views'' AS contents;
SELECT ''text'' AS component, ''
  - `*.auto.sql` pages are auto-generated "default" content pages for each table and view defined in the database.
  - The `*.sql` companions may be auto-generated redirects to their `*.auto.sql` pair or an app/service might override the `*.sql` to not redirect and supply custom content for any table or view.
  - [View regenerate-auto.sql](/console/sqlpage-files/sqlpage-file.sql?path=console/content/action/regenerate-auto.sql)
  '' AS contents_md;

SELECT ''button'' AS component, ''center'' AS justify;
SELECT ''/console/content/action/regenerate-auto.sql'' AS link, ''info'' AS color, ''Regenerate all "default" table/view content pages'' AS title;

SELECT ''title'' AS component, ''Redirected or overriden content pages'' as contents;
SELECT ''table'' AS component,
      ''Path'' as markdown,
      ''Size'' as align_right,
      TRUE as sort,
      TRUE as search;
SELECT
  ''[🚀](/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
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
  ''[🚀](/'' || path || '') [📄 '' || path || ''](sqlpage-file.sql?path='' || path || '')'' AS "Path",
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
              SELECT ''''Home'''' as title, ''''/'''' AS link;
              SELECT ''''Console'''' as title, ''''/console'''' AS link;
              SELECT ''''Content'''' as title, ''''/console/content'''' AS link;
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
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql'''' AS link WHERE $stats IS NULL;
'' ||
            ''SELECT ''''redirect'''' AS component, ''''/console/content/'' || tabular_nature || ''/'' || tabular_name || ''.auto.sql?stats='''' || $stats AS link WHERE $stats IS NOT NULL;''
        FROM console_content_tabular;

      -- TODO: add ${this.upsertNavSQL(...)} if we want each of the above to be navigable through DB rows

-- code provenance: `ConsoleSqlPages.console/content/action/regenerate-auto.sql` (file:///home/runner/work/www.surveilr.com/www.surveilr.com/lib/std/web-ui-content/console.ts)
SELECT ''redirect'' AS component, ''/console/sqlpage-files/content.sql'' as link WHERE $redirect is NULL;
SELECT ''redirect'' AS component, $redirect as link WHERE $redirect is NOT NULL;',
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
    WHERE namespace = ''prime'' AND path = ''/console/sqlpage-nav''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
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
    WHERE namespace = ''prime'' AND path = ''/console/notebooks''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Code Notebooks'' AS contents;
SELECT ''table'' as component, ''Cell'' as markdown, 1 as search, 1 as sort;
SELECT c.notebook_name,
       ''['' || c.cell_name || ''](notebook-cell.sql?notebook='' || replace(c.notebook_name, '' '', ''%20'') || ''&cell='' || replace(c.cell_name, '' '', ''%20'') || '')'' as Cell,
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
    WHERE namespace = ''prime'' AND path = ''/console/notebooks''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
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
    WHERE namespace = ''prime'' AND path = ''/ur''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH navigation_cte AS (
    SELECT COALESCE(title, caption) as title, description
      FROM sqlpage_aide_navigation
     WHERE namespace = ''prime'' AND path = ''/ur''
)
SELECT ''list'' AS component, title, description
  FROM navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
  FROM sqlpage_aide_navigation
 WHERE namespace = ''prime'' AND parent_path = ''/ur''
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
    WHERE namespace = ''prime'' AND path = ''/ur/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Uniform Resource Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
    ''['' || table_name || ''](/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''uniform_resource'' OR table_name like ''ur_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
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
              -- not including breadcrumbs from sqlpage_aide_navigation
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/ur/uniform-resource-files.sql'') as contents;
    ;

-- sets up $limit, $offset, and other variables (use pagination.debugVars() to see values in web-ui)
SET total_rows = (SELECT COUNT(*) FROM uniform_resource_file);
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
    (SELECT CASE WHEN $current_page > 1 THEN ''[Previous](?limit='' || $limit || ''&offset='' || ($offset - $limit) || '')'' ELSE '''' END) || '' '' ||
    ''(Page '' || $current_page || '' of '' || $total_pages || ") " ||
    (SELECT CASE WHEN $current_page < $total_pages THEN ''[Next](?limit='' || $limit || ''&offset='' || ($offset + $limit) || '')'' ELSE '''' END)
    AS contents_md;
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
    WHERE namespace = ''prime'' AND path = ''/orchestration''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              WITH navigation_cte AS (
SELECT COALESCE(title, caption) as title, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND path = ''/orchestration''
)
SELECT ''list'' AS component, title, description
    FROM navigation_cte;
SELECT caption as title, COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
WHERE namespace = ''prime'' AND parent_path = ''/orchestration''
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
    WHERE namespace = ''prime'' AND path = ''/orchestration/info-schema.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT ''title'' AS component, ''Orchestration Tables and Views'' as contents;
SELECT ''table'' AS component,
      ''Name'' AS markdown,
      ''Column Count'' as align_right,
      TRUE as sort,
      TRUE as search;

SELECT
    ''Table'' as "Type",
    ''['' || table_name || ''](/console/info-schema/table.sql?name='' || table_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_table
WHERE table_name = ''orchestration_session'' OR table_name like ''orchestration_%''
GROUP BY table_name

UNION ALL

SELECT
    ''View'' as "Type",
    ''['' || view_name || ''](/console/info-schema/view.sql?name='' || view_name || '')'' AS "Name",
    COUNT(column_name) AS "Column Count"
FROM console_information_schema_view
WHERE view_name like ''orchestration_%''
GROUP BY view_name;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/index.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              select
 ''card''             as component,
 3                 as columns;
  SELECT caption as title, COALESCE(url, path) as link, description
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND parent_path = ''/opsfolio'' AND sibling_order = 2
   ORDER BY sibling_order;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/control/control_dashboard.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/control/control_dashboard.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

                 SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/opsfolio/info/control/control_dashboard.sql'') as contents;
    ;
 SELECT
 ''card''             as component
SELECT DISTINCT
 control_regime  as title,
 ''arrow-big-right''       as icon,
 ''/opsfolio/info/control/control_regime.sql?id='' ||control_regime_id || '''' as link
 FROM
 control_regimes;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/control/control.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/control/control.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

                 SELECT ''title'' AS component, (SELECT COALESCE(title, caption)
    FROM sqlpage_aide_navigation
   WHERE namespace = ''prime'' AND path = ''/opsfolio/info/control/control.sql'') as contents;
    ;
 SELECT
 ''card''             as component
SELECT DISTINCT
 control_regime  as title,
 ''arrow-big-right''       as icon,
 ''/opsfolio/info/control/control_regime.sql?id='' ||control_regime_id || '''' as link
 FROM
 control_regimes;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/control/control_regime.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/control/control_regime.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT
  ''title'' AS component,
  ''Audit Types'' AS contents
  select ''card'' as component
  SELECT audit_type_name  as title,
    ''arrow-big-right''       as icon,
   ''/opsfolio/info/control/controls.sql?id='' ||audit_type_id || '''' as link
    FROM control_regimes WHERE control_regime_id = $id::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/control/controls.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/control/controls.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

              SELECT
''title'' AS component,
''Control List'' AS contents
select ''table'' as component,
''Control code'' AS markdown;
SELECT
''['' || control_code || ''](/opsfolio/info/control/control_detail.sql?id='' || control_id || '')'' AS "Control code",
common_criteria as "Common criteria",
fii as "Fii Id",
question as "Question"
  FROM control WHERE audit_type_id = $id::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
INSERT INTO sqlpage_files (path, contents, last_modified) VALUES (
      'opsfolio/info/control/control_detail.sql',
      '              SELECT ''dynamic'' AS component, sqlpage.run_sql(''shell/shell.sql'') AS properties;
              SELECT ''breadcrumb'' as component;
WITH RECURSIVE breadcrumbs AS (
    SELECT
        COALESCE(abbreviated_caption, caption) AS title,
        COALESCE(url, path) AS link,
        parent_path, 0 AS level,
        namespace
    FROM sqlpage_aide_navigation
    WHERE namespace = ''prime'' AND path = ''/opsfolio/info/control/control_detail.sql''
    UNION ALL
    SELECT
        COALESCE(nav.abbreviated_caption, nav.caption) AS title,
        COALESCE(nav.url, nav.path) AS link,
        nav.parent_path, b.level + 1, nav.namespace
    FROM sqlpage_aide_navigation nav
    INNER JOIN breadcrumbs b ON nav.namespace = b.namespace AND nav.path = b.parent_path
)
SELECT title, link FROM breadcrumbs ORDER BY level DESC;
              -- not including page title from sqlpage_aide_navigation

                 select
  ''card''             as component,
  1               as columns;
  SELECT
    ''title'' AS component,
    common_criteria AS contents
  FROM
    control
  WHERE
    control_id = $id::TEXT
  SELECT
    ''title'' AS component,
    "Control Code" AS contents,
3        as level;
    SELECT
    ''text'' AS component,
    control_code AS contents
    FROM
    control
  WHERE
    control_id = $id::TEXT
    SELECT
    ''title'' AS component,
    "Control Question" AS contents,
    3        as level;
       select
  ''card''             as component,
  1               as columns;
  select question as title
  FROM
    control
  WHERE
    control_id = $id::TEXT
    SELECT
    ''title'' AS component,
    "Expected Evidence" AS contents,
    3         as level;
select
  ''card''             as component,
  1               as columns;
  select expected_evidence as title
  FROM
    control
  WHERE
    control_id = $id::TEXT
       SELECT
    ''title'' AS component,
    "Mapped Requirements" AS contents,
    3       as level;
    SELECT
  ''card''             as component,
  1               as columns
  select fii as title
  FROM
    control
  WHERE
    control_id = $id::TEXT;
            ',
      CURRENT_TIMESTAMP)
  ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP;
