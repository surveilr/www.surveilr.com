import { assertEquals, assertExists } from "jsr:@std/assert@1";
import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";

const DEFAULT_RSSD_PATH = "./resource-surveillance.sqlite.db";

Deno.test("Statefull tables check", async (t) => {
  await t.step("Check database", async () => {
    assertExists(
      await Deno.stat(DEFAULT_RSSD_PATH).catch(() => null),
      `❌ Error: ${DEFAULT_RSSD_PATH} does not exist`,
    );
  });
  const db = new DB(DEFAULT_RSSD_PATH);

  await t.step("Flattened email anchor", () => {
    try {
      db.execute(`DROP TABLE IF EXISTS ur_transform_html_flattened_email_anchor;
            CREATE TABLE ur_transform_html_flattened_email_anchor AS
            SELECT
                uniform_resource_transform_id,
                uniform_resource_id,
                json_extract(json_each.value, '$.attributes.href') AS anchor,
                json_extract(json_each.value, '$.children[0]') AS anchor_text
            FROM
                uniform_resource_transform,
                json_each(content)`);
    } catch (e) {
      console.error(
        `Failed to create table ur_transform_html_flattened_email_anchor: ${e.message}`,
      );
    }
    const result = db.query(
      `SELECT COUNT(*) AS count FROM ur_transform_html_flattened_email_anchor`,
    );
    assertEquals(result.length, 1);
  });

  await t.step("Email anchor subscription filter existence check", () => {
    try {
      const result = db.query(
        `SELECT COUNT(*)
       FROM sqlite_master
       WHERE type='table' AND name='ur_transform_html_email_anchor_subscription_filter';`,
      );

      // Access the count value directly
      const count = result[0][0] || 0;
      assertEquals(count, 1, "Table does not exist.");
    } catch (e) {
      console.error(
        `Failed to verify existence of table ur_transform_html_email_anchor_subscription_filter: ${e.message}`,
      );
    }
  });

  await t.step("Email anchor existence check", () => {
    try {
      const result = db.query(
        `SELECT COUNT(*)
       FROM sqlite_master
       WHERE type='table' AND name='ur_transform_html_email_anchor';`,
      );

      // Access the count value directly
      const count = result[0][0] || 0;
      assertEquals(count, 1, "Table does not exist.");
    } catch (e) {
      console.error(
        `Failed to verify existence of table ur_transform_html_email_anchor: ${e.message}`,
      );
    }
  });

  await t.step("Inbox", () => {
    try {
      db.execute(`DROP VIEW IF EXISTS inbox;
          CREATE VIEW inbox AS
          SELECT
              ur_base.uniform_resource_id AS base_uniform_resource_id,
              ur_imap."from" AS message_from,
              ur_imap."subject" AS message_subject,
              ur_imap."date" AS message_date,
              ur_extended.uniform_resource_id AS extended_uniform_resource_id,
              ur_extended.uri AS extended_uri
          FROM
              ur_ingest_session_imap_acct_folder_message ur_imap
          JOIN
              uniform_resource ur_base
              -- the 'uniform_resource' table is connected to the 'ur_ingest_session_imap_acct_folder_message' table through a foreign key
              ON ur_base.ingest_session_imap_acct_folder_message = ur_imap.ur_ingest_session_imap_acct_folder_message_id
          JOIN
              uniform_resource ur_extended
              ON ur_extended.uri = ur_base.uri || '/html'
          WHERE
        ur_extended.uri LIKE '%/html'`);
    } catch (e) {
      console.error(
        `Failed to create table inbox: ${e.message}`,
      );
    }
    const result = db.query(
      `SELECT COUNT(*) AS count FROM inbox`,
    );
    assertEquals(result.length, 1);
  });

  db.close();
});

Deno.test("Stateless tables check", async (t) => {
  await t.step("Check database", async () => {
    assertExists(
      await Deno.stat(DEFAULT_RSSD_PATH).catch(() => null),
      `❌ Error: ${DEFAULT_RSSD_PATH} does not exist`,
    );
  });
  const db = new DB(DEFAULT_RSSD_PATH);
  db.close();
});
