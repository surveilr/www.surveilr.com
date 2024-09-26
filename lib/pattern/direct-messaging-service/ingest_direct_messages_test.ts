import { assertEquals, assertExists } from "jsr:@std/assert@1";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { DB } from "https://deno.land/x/sqlite@v3.8/mod.ts";

const E2E_TEST_DIR = path.join(Deno.cwd(), "assurance");
const ZIP_URL =
  "https://github.com/opsfolio/resource-surveillance-commons/raw/main/pattern/direct-messaging-service/ingest.zip";
const ZIP_FILE = path.join(E2E_TEST_DIR, "ingest.zip");
const INGEST_DIR = path.join(E2E_TEST_DIR, "ingest");
const DEFAULT_RSSD_PATH = path.join(
  E2E_TEST_DIR,
  "resource-surveillance-direct-message.e2e.sqlite.db",
);

export async function countFilesInDirectory(
  directoryPath: string,
): Promise<number> {
  let fileCount = 0;

  for await (const dirEntry of Deno.readDir(directoryPath)) {
    if (dirEntry.isFile) {
      fileCount++;
    }
  }

  return fileCount;
}

Deno.test("file ingestion", async (t) => {
  await t.step({
    name: "download-zip",
    fn: async () => {
      if (!await Deno.stat(ZIP_FILE).catch(() => false)) {
        await $`wget -P ${E2E_TEST_DIR} ${ZIP_URL}`;
      }

      assertExists(
        await Deno.stat(ZIP_FILE).catch(() => null),
        "❌ Error: Data file does not exist after download.",
      );

      if (!await Deno.stat(INGEST_DIR).catch(() => false)) {
        const unzipResult = await $`unzip ${ZIP_FILE} -d ${E2E_TEST_DIR}`;

        assertEquals(
          unzipResult.code,
          0,
          "❌ Error: Failed to unzip the data file.",
        );
      }

      assertExists(
        await Deno.stat(INGEST_DIR).catch(() => null),
        `❌ Error: Ingest directory ${INGEST_DIR} does not exist after unzipping.`,
      );
    },
    ignore: false,
  });
  await t.step("surveilr ingest files", async () => {
    assertExists(
      await Deno.stat(INGEST_DIR).catch(() => null),
      `❌ Error: Ingest directory ${INGEST_DIR} before surveilr ingest`,
    );

    if (await Deno.stat(DEFAULT_RSSD_PATH).catch(() => null)) {
      await Deno.remove(DEFAULT_RSSD_PATH).catch(() => false);
    }
    console.log(INGEST_DIR);
    const ingestResult =
      await $`surveilr ingest files -d ${DEFAULT_RSSD_PATH} -r ${INGEST_DIR}`;
    assertEquals(
      ingestResult.code,
      0,
      `❌ Error: Failed to ingest data in ${INGEST_DIR}`,
    );

    assertExists(
      await Deno.stat(DEFAULT_RSSD_PATH).catch(() => null),
      `❌ Error: ${DEFAULT_RSSD_PATH} does not exist`,
    );
  });
  const db = new DB(DEFAULT_RSSD_PATH);
  await t.step("inbox data", () => {
    db.execute(`
            DROP VIEW IF EXISTS mail_content_detail;
            CREATE  VIEW mail_content_detail AS
            SELECT
            json_extract(value, '$.recipient') AS recipient,
            json_extract(value, '$.sender') AS sender,
            -- Remove angle brackets from messageId
            REPLACE(REPLACE(json_extract(value, '$.messageId'), '<', ''), '>', '') AS message_id,
            json_extract(value, '$.messageUId') AS message_uid,
            json_extract(value, '$.content.mimeType') AS content_mime_type,
            json_extract(value, '$.content.length') AS content_length,
            json_extract(value, '$.content.headers.date') AS content_date,
            json_extract(value, '$.content.headers.subject') AS content_subject,
            json_extract(value, '$.content.headers.from') AS content_from,
            json_extract(value, '$.content.headers.to') AS content_to,
            json_extract(value, '$.content.body') AS content_body,
            json_extract(value, '$.status') AS status,
            -- Count the number of attachments
            json_array_length(json_extract(value, '$.attachments')) AS attachment_count
            FROM
            uniform_resource,
            json_each(uniform_resource.content)
            WHERE
            nature = 'json'
            AND uri LIKE '%_content.json';
            DROP VIEW IF EXISTS inbox;
            CREATE VIEW inbox AS
            SELECT
            mcd.message_uid as id,
            mcd.content_from AS "from",
            mcd.recipient AS "to",
            mcd.content_subject AS subject,
            mcd.content_body AS content,
            mcd.content_date AS date,
            attachment_count as attachment_count

            FROM
            mail_content_detail mcd;`);
    const result = db.query(
      `SELECT COUNT(*) AS count FROM inbox`,
    );
    assertEquals(result.length, 1);
  });
  db.close();
});
