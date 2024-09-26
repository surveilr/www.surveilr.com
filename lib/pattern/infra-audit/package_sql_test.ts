import { assertEquals, assertExists } from "jsr:@std/assert@1";
import { DB } from "https://deno.land/x/sqlite@v3.8/mod.ts";
const DEFAULT_RSSD_PATH = "./resource-surveillance.sqlite.db";

Deno.test("View Check", async (t) => {
    await t.step("Check database", async () => {
        assertExists(
            await Deno.stat(DEFAULT_RSSD_PATH).catch(() => null),
            `❌ Error: ${DEFAULT_RSSD_PATH} does not exist`,
        );
    });
    const db = new DB(DEFAULT_RSSD_PATH);
    await t.step("Tenant Based Control Regime", () => {
        db.execute(`DROP VIEW IF EXISTS tenant_based_control_regime;
            CREATE VIEW tenant_based_control_regime AS
            SELECT tcr.control_regime_id,
                tcr.tenant_id,
                cr.name,
                cr.parent_id,
                cr.description,
                cr.logo_url,
                cr.status,
                cr.created_at,
                cr.updated_at
            FROM tenant_control_regime tcr
            JOIN control_regime cr on cr.control_regime_id = tcr.control_regime_id;`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM tenant_based_control_regime`,
        );
        assertEquals(result.length, 1);
    });

    await t.step("Audit Session Control", () => {
        db.execute(`DROP VIEW IF EXISTS audit_session_control;
            CREATE VIEW audit_session_control AS
            SELECT c.control_group_id,
                c.control_id,
                c.question,
                c.display_order,
                c.control_code,
                ac.audit_control_id,
                ac.control_audit_status AS status,
                ac.audit_session_id
            FROM audit_control ac
            JOIN control c ON c.control_id = ac.control_id;`);
        const viewExists = db.query(
            `SELECT name FROM sqlite_master WHERE type='view' AND name='audit_session_control';`,
        );

        assertEquals(
            viewExists.length,
            1,
            "View audit_session_control should exist.",
        );
    });

    await t.step("Query Result", () => {
        db.execute(`DROP VIEW IF EXISTS query_result;
            CREATE VIEW query_result AS
            WITH RECURSIVE extract_blocks AS (
            SELECT
              uniform_resource_id,
              uri,
              device_id,
              content_digest,
              nature,
              size_bytes,
              last_modified_at,
              created_at,
              updated_at,
              substr(content, instr(content, '<QueryResult'), instr(content || '</QueryResult>', '</QueryResult>') - instr(content, '<QueryResult') + length('</QueryResult>')) AS query_content,
              substr(content, instr(content, '</QueryResult>') + length('</QueryResult>')) AS remaining_content
            FROM
              uniform_resource
            WHERE
              content LIKE '%<QueryResult%' AND nature='mdx'
            UNION ALL
            SELECT
              uniform_resource_id,
              uri,
              device_id,
              content_digest,
              nature,
              size_bytes,
              last_modified_at,
              created_at,
              updated_at,
              substr(remaining_content, instr(remaining_content, '<QueryResult'), instr(remaining_content || '</QueryResult>', '</QueryResult>') - instr(remaining_content, '<QueryResult') + length('</QueryResult>')) AS query_content,
              substr(remaining_content, instr(remaining_content, '</QueryResult>') + length('</QueryResult>')) AS remaining_content
          FROM
              extract_blocks
            WHERE
              remaining_content LIKE '%<QueryResult%' AND nature='mdx'
        ),
        latest_entries AS (
            SELECT
              uri,
              MAX(last_modified_at) AS latest_last_modified_at
            FROM
              uniform_resource
            WHERE
              nature = 'mdx'
            GROUP BY
              uri
        )
        SELECT
          eb.uniform_resource_id,
          eb.uri,
          eb.device_id,
          eb.content_digest,
          eb.nature,
          eb.size_bytes,
          eb.last_modified_at,
          eb.created_at,
          eb.updated_at,
          eb.query_content
        FROM
          extract_blocks eb
        JOIN
          latest_entries le
        ON
          eb.uri = le.uri AND eb.last_modified_at = le.latest_last_modified_at;`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM query_result`,
        );
        assertEquals(result.length, 1);
    });

    db.close();
});
