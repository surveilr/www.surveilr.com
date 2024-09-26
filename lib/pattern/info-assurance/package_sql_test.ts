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
    await t.step("Threat Model", () => {
        db.execute(`DROP VIEW IF EXISTS threat_model;
            CREATE VIEW threat_model AS
            WITH json_data AS (
    SELECT
        json_extract(threats.value, '$."a:Value"."b:Id"') AS "id",
        json_extract(threats.value, '$."a:Value"."b:ChangedBy"') AS "changed_by",
        json_extract(threats.value, '$."a:Value"."b:ModifiedAt"') AS "last_modified",
        json_extract(threats.value, '$."a:Value"."b:State"') AS "state",
        json_each.value AS kv_value
    FROM
        uniform_resource_transform,
        json_each(json_extract(content, '$.ThreatModel.ThreatInstances."a:KeyValueOfstringThreatpc_P0_PhOB"')) AS threats,
        json_each(json_extract(threats.value, '$."a:Value"."b:Properties"."a:KeyValueOfstringstring"'))
)
SELECT
    id,
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'Title' THEN json_extract(kv_value, '$."a:Value"') END) AS "title",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'UserThreatCategory' THEN json_extract(kv_value, '$."a:Value"') END) AS "category",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'UserThreatShortDescription' THEN json_extract(kv_value, '$."a:Value"') END) AS "short_description",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'UserThreatDescription' THEN json_extract(kv_value, '$."a:Value"') END) AS "description",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'InteractionString' THEN json_extract(kv_value, '$."a:Value"') END) AS "interaction",
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'Priority' THEN json_extract(kv_value, '$."a:Value"') END) AS "priority",
    state,
    MAX(CASE WHEN json_extract(kv_value, '$."a:Key"') = 'StateInformation' THEN json_extract(kv_value, '$."a:Value"') END) AS "justification",
    "changed_by",
    "last_modified"
FROM
    json_data
GROUP BY
    id, "changed_by", "last_modified", state;`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM threat_model`,
        );
        assertEquals(result.length, 1);
    });

    await t.step("Web Application", () => {
        db.execute(`DROP VIEW IF EXISTS web_application;
            CREATE VIEW web_application AS
            SELECT DISTINCT
                json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') AS Title
            FROM
            uniform_resource_transform,
                json_each(
                    CASE
                        WHEN json_type(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')) = 'array'
                        THEN json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')
                        ELSE json_array(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel'))
                    END
                ) AS drawing_surface,
                json_each(
                    json_extract(drawing_surface.value, '$.Borders."a:KeyValueOfguidanyType"')
                ) AS border
            WHERE  json_extract(border.value, '$."a:Value"."@i:type"') = 'StencilEllipse'
                AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[0]."b:DisplayName"') = 'Web Application';`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM web_application`,
        );
        assertEquals(result.length, 1);
    });

    await t.step("Managed Application", () => {
        db.execute(`DROP VIEW IF EXISTS managed_application;
            CREATE VIEW IF NOT EXISTS managed_application AS
            SELECT DISTINCT
                json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') AS Title
            FROM
                uniform_resource_transform,
                json_each(
                    CASE
                        WHEN json_type(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')) = 'array'
                        THEN json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')
                        ELSE json_array(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel'))
                    END
                ) AS drawing_surface,
                json_each(
                    json_extract(drawing_surface.value, '$.Borders."a:KeyValueOfguidanyType"')
                ) AS border
            WHERE  json_extract(border.value, '$."a:Value"."@i:type"') = 'StencilEllipse'
                AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[0]."b:DisplayName"') = 'Managed Application';`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM managed_application`,
        );
        assertEquals(result.length, 1);
    });

    await t.step("SQL Database", () => {
        db.execute(`DROP VIEW IF EXISTS sql_database;
            CREATE VIEW IF NOT EXISTS sql_database AS
            SELECT DISTINCT
                json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') AS Title
            FROM
            uniform_resource_transform,
                json_each(
                    CASE
                        WHEN json_type(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')) = 'array'
                        THEN json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')
                        ELSE json_array(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel'))
                    END
                ) AS drawing_surface,
                json_each(
                    json_extract(drawing_surface.value, '$.Borders."a:KeyValueOfguidanyType"')
                ) AS border
            WHERE  json_extract(border.value, '$."a:Value"."@i:type"') = 'StencilParallelLines'
                AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[0]."b:DisplayName"') = 'SQL Database';`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM sql_database`,
        );
        assertEquals(result.length, 1);
    });

    await t.step("Boundaries", () => {
        db.execute(`DROP VIEW IF EXISTS boundaries;
            CREATE VIEW IF NOT EXISTS boundaries AS
            SELECT DISTINCT
                json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') AS boundary
                FROM
                uniform_resource_transform,
                json_each(
                    CASE
                        WHEN json_type(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')) = 'array'
                        THEN json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel')
                        ELSE json_array(json_extract(content, '$.ThreatModel.DrawingSurfaceList.DrawingSurfaceModel'))
                    END
                ) AS drawing_surface,
                json_each(
                    json_extract(drawing_surface.value, '$.Borders."a:KeyValueOfguidanyType"')
                ) AS border
                WHERE
                json_extract(border.value, '$."a:Value"."@i:type"') = 'BorderBoundary'
                AND (
                    json_extract(border.value, '$."a:Value".Properties."a:anyType"[0]."b:DisplayName"') IN (
                        'Other Browsers Boundaries',
                        'CorpNet Trust Boundary',
                        'Generic Trust Border Boundary'
                    )
                )
                AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') NOT LIKE '%.%.%.%'
                AND json_extract(border.value, '$."a:Value".Properties."a:anyType"[1]."b:Value"."#text"') LIKE '%Boundar%';`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM boundaries`,
        );
        assertEquals(result.length, 1);
    });

    db.close();
});
