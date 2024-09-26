import { assertEquals, assertExists } from "jsr:@std/assert@1";
import { DB } from "https://deno.land/x/sqlite@v3.8/mod.ts";
const DEFAULT_RSSD_PATH = "./resource-surveillance.sqlite.db";

Deno.test("View Check....", async (t) => {
    await t.step("Check database...", async () => {
        assertExists(
            await Deno.stat(DEFAULT_RSSD_PATH).catch(() => null),
            `❌ Error: ${DEFAULT_RSSD_PATH} does not exist`,
        );
    });
    const db = new DB(DEFAULT_RSSD_PATH);

    await t.step("Control Regimes", () => {
        try {
            db.execute(`DROP VIEW IF EXISTS control_regimes;
            CREATE VIEW control_regimes AS
            SELECT
                reg.name as control_regime,
                reg.control_regime_id as control_regime_id,
                audit.name as audit_type_name,
                audit.control_regime_id as audit_type_id
            FROM
                control_regime as audit
            INNER JOIN control_regime as reg ON audit.parent_id = reg.control_regime_id;`);
        } catch (e) {
            console.error(`Failed to create view control_group: ${e.message}`);
        }
        const result = db.query(
            `SELECT COUNT(*) AS count FROM control_regimes`,
        );
        assertEquals(result.length, 1);
    });

    await t.step("Control Group", () => {
        try {
            db.execute(`DROP VIEW IF EXISTS control_group;
            CREATE VIEW control_group AS
            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type I' AND parent_id IS NOT NULL) AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type I' AND parent_id IS NOT NULL) AS audit_type_id,
              NULL AS parent_id
            FROM
              uniform_resource_aicpa_soc2_controls
            GROUP BY "Common Criteria"

            UNION ALL

            SELECT
                cast("#" as int)  as display_order,
                ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
                (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type II' AND parent_id IS NOT NULL) AS control_group_id,
                "Common Criteria" AS title,
                (SELECT control_regime_id FROM control_regime WHERE name='SOC2 Type II' AND parent_id IS NOT NULL) AS audit_type_id,
                NULL AS parent_id
            FROM uniform_resource_aicpa_soc2_type2_controls
            GROUP BY "Common Criteria"

            UNION ALL

            SELECT
                cast("#" as int)  as display_order,
                ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
                (SELECT control_regime_id FROM control_regime WHERE name='HIPAA' AND parent_id IS NOT NULL) AS control_group_id,
                "Common Criteria" AS title,
                (SELECT control_regime_id FROM control_regime WHERE name='HIPAA' AND parent_id IS NOT NULL) AS audit_type_id,
                NULL AS parent_id
            FROM uniform_resource_hipaa_security_rule_safeguards
            GROUP BY "Common Criteria"

            UNION ALL

            SELECT
                cast("#" as int)  as display_order,
                ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
                (SELECT control_regime_id FROM control_regime WHERE name='HiTRUST e1 Assessment' AND parent_id IS NOT NULL) AS control_group_id,
                "Common Criteria" AS title,
                (SELECT control_regime_id FROM control_regime WHERE name='HiTRUST e1 Assessment' AND parent_id IS NOT NULL) AS audit_type_id,
                NULL AS parent_id
            FROM uniform_resource_hitrust_e1_assessment
            GROUP BY "Common Criteria"

            UNION ALL

            SELECT
                (SELECT COUNT(*)
                FROM uniform_resource_scf_2024_2 AS sub
                WHERE sub.ROWID <= cntl.ROWID AND sub."US CMMC 2.0 Level 1" IS NOT NULL) AS display_order,
                ROW_NUMBER() OVER (ORDER BY cntl."SCF Domain")  || '-' ||
                (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 1' AND parent_id IS NOT NULL) AS control_group_id,
                cntl."SCF Domain" AS title,
                (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 1' AND parent_id IS NOT NULL) AS audit_type_id,
                NULL AS parent_id
            FROM  uniform_resource_scf_2024_2 cntl
            WHERE cntl."US CMMC 2.0 Level 1" IS NOT NULL
            GROUP BY cntl."SCF Domain"

            UNION ALL

            SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND sub."US CMMC 2.0 Level 2" IS NOT NULL) AS display_order,
              ROW_NUMBER() OVER (ORDER BY cntl."SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 2' AND parent_id IS NOT NULL) AS control_group_id,
              cntl."SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 2' AND parent_id IS NOT NULL) AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scf_2024_2 cntl
            WHERE
              cntl."US CMMC 2.0 Level 2" IS NOT NULL
            GROUP BY
              cntl."SCF Domain"

            UNION ALL

            SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND sub."US CMMC 2.0 Level 3" IS NOT NULL) AS display_order,
              ROW_NUMBER() OVER (ORDER BY "SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 3' AND parent_id IS NOT NULL) AS control_group_id,
              cntl."SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='CMMC Model 2.0 LEVEL 3' AND parent_id IS NOT NULL) AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scf_2024_2 cntl
            WHERE cntl."US CMMC 2.0 Level 3" IS NOT NULL
            GROUP BY cntl."SCF Domain"

            UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "SCF Domain")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Together.Health Security Assessment (THSA)' AND parent_id IS NOT NULL) AS control_group_id,
              "SCF Domain" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Together.Health Security Assessment (THSA)' AND parent_id IS NOT NULL) AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_thsa
            GROUP BY
              "SCF Domain"

            UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Code Quality Infrastructure' AND parent_id IS NOT NULL) AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Code Quality Infrastructure' AND parent_id IS NOT NULL) AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_code_quality_infrastructure
            GROUP BY
              "Common Criteria"

            UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Database Quality Infrastructure' AND parent_id IS NOT NULL) AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Database Quality Infrastructure' AND parent_id IS NOT NULL) AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_database_quality_infrastructure
            GROUP BY
              "Common Criteria"

            UNION ALL

            SELECT
              cast("#" as int)  as display_order,
              ROW_NUMBER() OVER (ORDER BY "Common Criteria")  || '-' ||
              (SELECT control_regime_id FROM control_regime WHERE name='Scheduled Audit' AND parent_id IS NOT NULL) AS control_group_id,
              "Common Criteria" AS title,
              (SELECT control_regime_id FROM control_regime WHERE name='Scheduled Audit' AND parent_id IS NOT NULL) AS audit_type_id,
              NULL AS parent_id
            FROM  uniform_resource_scheduled_audit
            GROUP BY "Common Criteria";`);
        } catch (e) {
            console.error(`Failed to create view control_group: ${e.message}`);
        }

        const result = db.query(
            `SELECT COUNT(*) AS count FROM control_group`,
        );
        assertEquals(result.length, 1);
    });

    await t.step("Controls", () => {
        db.execute(`DROP VIEW IF EXISTS control;
                    CREATE VIEW control AS
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
                    FROM uniform_resource_aicpa_soc2_controls cntl
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
                    NULL AS expected_evidence,
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
                    WHERE sub.ROWID <= cntl.ROWID AND "US CMMC 2.0 Level 1" IS NOT NULL) AS display_order,
                    cg.control_group_id,
                    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."US CMMC 2.0 Level 1", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
                    || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
                    (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') as control_id,
                    'CMMCLEVEL-' || (ROWID) as control_identifier,
                    cntl."US CMMC 2.0 Level 1" AS control_code,
                    cntl."SCF #" AS fii,
                    cntl."SCF Domain" AS common_criteria,
                    NULL AS expected_evidence,
                    cntl."SCF Control Question" AS question,
                    (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS control_regime,
                    (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS control_regime_id,
                    (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS audit_type,
                    (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1') AS audit_type_id
                FROM
                    uniform_resource_scf_2024_2 AS cntl
                    INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
                WHERE
                    cntl."US CMMC 2.0 Level 1" IS NOT NULL AND cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 1')

            UNION ALL

            SELECT
                (SELECT COUNT(*)
                FROM uniform_resource_scf_2024_2 AS sub
                WHERE sub.ROWID <= cntl.ROWID AND "US CMMC 2.0 Level 2" IS NOT NULL) AS display_order,
                cg.control_group_id,
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."US CMMC 2.0 Level 2", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
                || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
                (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') as control_id,
                'CMMCLEVEL-' || (ROWID) AS control_identifier,
                cntl."US CMMC 2.0 Level 2" AS control_code,
                cntl."SCF #" AS fii,
                cntl."SCF Domain" AS common_criteria,
                NULL AS expected_evidence,
                cntl."SCF Control Question" AS question,
                (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS control_regime,
                (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS control_regime_id,
                (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS audit_type,
                (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2') AS audit_type_id
            FROM
                uniform_resource_scf_2024_2 cntl
                INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
            WHERE
                "US CMMC 2.0 Level 2" IS NOT NULL AND cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 2')

            UNION ALL

            SELECT
              (SELECT COUNT(*)
              FROM uniform_resource_scf_2024_2 AS sub
              WHERE sub.ROWID <= cntl.ROWID AND "US CMMC 2.0 Level 3" IS NOT NULL) AS display_order,
              cg.control_group_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."US CMMC 2.0 Level 3", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', '-'), CHAR(10), '-'), CHAR(13), '-') || '-'
              || REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cntl."SCF #", ' ', ''), ',', '-'), '(', '-'), ')', ''), '.', ''), CHAR(10), '-'), CHAR(13), '-') || '-' ||
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') as control_id,
              'CMMCLEVEL-' || (ROWID) AS control_identifier,
              cntl."US CMMC 2.0 Level 3" AS control_code,
              cntl."SCF #" AS fii,
              cntl."SCF Domain" AS common_criteria,
              NULL AS expected_evidence,
              cntl."SCF Control Question" AS question,
              (SELECT control_regime FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS control_regime,
              (SELECT control_regime_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS control_regime_id,
              (SELECT audit_type_name FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS audit_type,
              (SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3') AS audit_type_id
            FROM
              uniform_resource_scf_2024_2 cntl
              INNER JOIN control_group cg ON cg.title=cntl."SCF Domain"
            WHERE
              "US CMMC 2.0 Level 3" IS NOT NULL AND cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='CMMC Model 2.0 LEVEL 3')

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
            NULL AS expected_evidence,
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
        WHERE cg.audit_type_id=(SELECT audit_type_id FROM control_regime_cte WHERE audit_type_name='Scheduled Audit');`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM control`,
        );
        assertEquals(result.length, 1);
    });

    db.close();
});
