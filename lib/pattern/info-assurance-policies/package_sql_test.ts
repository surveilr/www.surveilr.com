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
    await t.step("Policy Dashboard", () => {
        db.execute(`DROP VIEW IF EXISTS policy_dashboard;
            CREATE VIEW policy_dashboard AS
    WITH RECURSIVE split_uri AS (
        SELECT
            uniform_resource_id,
            uri,
            substr(uri, instr(uri, 'src/') + 4, instr(substr(uri, instr(uri, 'src/') + 4), '/') - 1) AS segment,
            substr(substr(uri, instr(uri, 'src/') + 4), instr(substr(uri, instr(uri, 'src/') + 4), '/') + 1) AS rest,
            1 AS level
        FROM uniform_resource
        WHERE instr(uri, 'src/') > 0 AND  instr(substring(uri,instr(uri, 'src/')),'_')=0
        UNION ALL
        SELECT
            uniform_resource_id,
            uri,
            substr(rest, 1, instr(rest, '/') - 1) AS segment,
            substr(rest, instr(rest, '/') + 1) AS rest,
            level + 1
        FROM split_uri
        WHERE instr(rest, '/') > 0 AND instr(substring(uri,instr(uri, 'src/')),'_')=0
    ),
    final_segment AS (
        SELECT DISTINCT
            uniform_resource_id,
            segment,
            substr(uri, instr(uri, 'src/')) AS url,
            CASE WHEN instr(rest, '/') = 0 THEN 0 ELSE 1 END AS is_folder
        FROM split_uri
        WHERE level = 4 AND instr(rest, '/') = 0
    )
    SELECT
        uniform_resource_id,
        COALESCE(REPLACE(segment, '-', ' '), '') AS title,
        segment,
        url
    FROM final_segment
    WHERE url LIKE '%.md' OR url LIKE '%.mdx'
    GROUP BY segment
    ORDER BY is_folder ASC, segment ASC;`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM policy_dashboard`,
        );
        assertEquals(result.length, 1);
    });
    await t.step("Policy Detail", () => {
        db.execute(`DROP VIEW IF EXISTS policy_detail;
                    CREATE VIEW policy_detail AS
                    SELECT uniform_resource_id,uri,content_fm_body_attrs, content, nature FROM uniform_resource;`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM policy_detail`,
        );
        assertEquals(result.length, 1);
    });
    await t.step("Policy List", () => {
        db.execute(`DROP VIEW IF EXISTS policy_list;
            CREATE VIEW policy_list AS
                WITH RECURSIVE split_uri AS (
                -- Initial split to get the first segment after 'src/'
                SELECT
                    uniform_resource_id,
                    frontmatter->>'title' AS title,
                    uri,
                    last_modified_at,
                    null as parentfolder,
                    substr(uri, instr(uri, 'src/') + 4, instr(substr(uri, instr(uri, 'src/') + 4), '/') - 1) AS segment1,
                    substr(substr(uri, instr(uri, 'src/') + 4), instr(substr(uri, instr(uri, 'src/') + 4), '/') + 1) AS rest,
                    1 AS level
                FROM uniform_resource
                WHERE instr(uri, 'src/') > 0 AND instr(substr(uri, instr(uri, 'src/')), '_') = 0 and  content not LIKE  '%Draft: true%'
                UNION ALL
                SELECT
                uniform_resource_id,
                title,
                    uri,
                    last_modified_at,
                    CASE
                        WHEN level = 4 THEN segment1
                        WHEN level = 5 THEN segment1
                        WHEN level = 6 THEN segment1
                        WHEN level = 7 THEN segment1
                    END AS parentfolder,
                    CASE
                        WHEN level = 1 THEN substr(rest, 1, instr(rest, '/') - 1)
                        WHEN level = 2 THEN substr(rest, 1, instr(rest, '/') - 1)
                        WHEN level = 3 THEN substr(rest, 1, instr(rest, '/') - 1)
                        WHEN level = 4 THEN substr(rest, 1, instr(rest, '/') - 1)
                        WHEN level = 5 THEN substr(rest, 1, instr(rest, '/') - 1)
                        WHEN level = 6 THEN substr(rest, 1, instr(rest, '/') - 1)
                        WHEN level = 7 THEN substr(rest, 1, instr(rest, '/') - 1)
                        WHEN level = 8 THEN substr(rest, 1, instr(rest, '/') - 1)
                        ELSE segment1
                    END AS segment1,
                    CASE
                        WHEN instr(rest, '/') > 0 THEN substr(rest, instr(rest, '/') + 1)
                        ELSE ''
                    END AS rest,
                    level + 1
                FROM split_uri
                WHERE rest != '' AND instr(substr(uri, instr(uri, 'src/')), '_') = 0
            ),
            latest_entries AS (
                        SELECT
                        uri,
                        MAX(last_modified_at) AS latest_last_modified_at
                        FROM
                        uniform_resource
                        GROUP BY
                        uri
                    )
            Select  distinct substr(ss.uri, instr(ss.uri, 'src/')) AS url,ss.title,ss.parentfolder,ss.segment1,ss.rest,ss.last_modified_at,ss.uniform_resource_id
            from split_uri ss
            JOIN
            latest_entries le
                    ON
                    ss.uri = le.uri AND last_modified_at = le.latest_last_modified_at
            where level >4 and level <6
            and  instr(rest,'/')=0
            order by ss.parentfolder,ss.segment1,url;`);
        const result = db.query(
            `SELECT COUNT(*) AS count FROM policy_list`,
        );
        assertEquals(result.length, 1);
    });

    db.close();
});
