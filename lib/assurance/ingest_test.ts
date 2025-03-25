import { assert, assertEquals, assertExists } from "jsr:@std/assert@1";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";

// # TODO: automatically upgrade surveilr

const E2E_TEST_DIR = path.join(Deno.cwd(), "lib/assurance");
const ZIP_URL =
  "https://synthetichealth.github.io/synthea-sample-data/downloads/10k_synthea_covid19_csv.zip";
const ZIP_FILE = path.join(E2E_TEST_DIR, "10k_synthea_covid19_csv.zip");
const INGEST_DIR = path.join(E2E_TEST_DIR, "ingest");
const DEFAULT_RSSD_PATH = path.join(
  E2E_TEST_DIR,
  "resource-surveillance.sqlite.db",
);
const TEST_FIXTURES_DIR = path.join(E2E_TEST_DIR, "test-fixtures");

async function countFilesInDirectory(
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

async function countCSVRows(filePath: string): Promise<number> {
  const csvContent = await Deno.readTextFile(filePath);
  const rows = csvContent.split("\n");
  const nonEmptyRows = rows.filter((row) => row.trim() !== "");
  // removes the column definition
  return nonEmptyRows.length - 1;
}

let initialIngestFileCount = 0;

Deno.test("file ingestion", async (t) => {
  await t.step({
    name: "",
    fn: async () => {
      if (!await Deno.stat(ZIP_FILE).catch(() => false)) {
        await $`wget ${ZIP_URL} -P ${E2E_TEST_DIR}`;
      }

      assertExists(
        await Deno.stat(ZIP_FILE).catch(() => null),
        "❌ Error: Data file does not exist after download.",
      );

      if (!await Deno.stat(INGEST_DIR).catch(() => false)) {
        await Deno.mkdir(INGEST_DIR, { recursive: true });
        const unzipResult = await $`unzip ${ZIP_FILE} -d ${INGEST_DIR}`;

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

    const ingestResult =
      await $`surveilr ingest files -d ${DEFAULT_RSSD_PATH} -r ${INGEST_DIR}/10k_synthea_covid19_csv -r ${TEST_FIXTURES_DIR}`;
    assertEquals(
      ingestResult.code,
      0,
      `❌ Error: Failed to ingest data in ${INGEST_DIR}/10k_synthea_covid19_csv`,
    );

    assertExists(
      await Deno.stat(DEFAULT_RSSD_PATH).catch(() => null),
      `❌ Error: ${DEFAULT_RSSD_PATH} does not exist`,
    );
  });

  const db = new DB(DEFAULT_RSSD_PATH);

  await t.step("uniform resource graphs", () => {
    const result = db.query<[number]>(
      `SELECT EXISTS ( SELECT 1 FROM uniform_resource_graph WHERE name = 'filesystem') AS filesystem_exists;`,
    );
    assertEquals(result.length, 1);
    assertEquals(result[0][0], 1);
  });

  await t.step("file change history", async () => {
    db.execute(`
            DROP VIEW IF EXISTS file_change_history;
            CREATE VIEW file_change_history AS
            SELECT
                ur.uniform_resource_id,
                ur.uri,
                COUNT(DISTINCT isfp.ingest_session_id) AS ingest_session_count,
                GROUP_CONCAT(DISTINCT isfp.ingest_session_id) AS ingest_sessions,
                MIN(ing_sess.ingest_started_at) AS first_seen,
                MAX(ing_sess.ingest_started_at) AS last_seen
            FROM uniform_resource ur
            JOIN ur_ingest_session_fs_path_entry isfpe ON ur.uniform_resource_id = isfpe.uniform_resource_id
            JOIN ur_ingest_session_fs_path isfp ON isfpe.ingest_fs_path_id = isfp.ur_ingest_session_fs_path_id
            JOIN ur_ingest_session ing_sess ON isfp.ingest_session_id = ing_sess.ur_ingest_session_id
            GROUP BY ur.uniform_resource_id, ur.uri;
        `);

    const result = db.query<[number]>(
      `SELECT COUNT(*) AS count FROM file_change_history`,
    );
    assertEquals(result.length, 1);

    const filesInDir = await countFilesInDirectory(
      `${INGEST_DIR}/10k_synthea_covid19_csv`,
    ) + (await countFilesInDirectory(TEST_FIXTURES_DIR));

    const files = result[0][0];
    initialIngestFileCount = files;
    assert(filesInDir > files);
  });

  await t.step("user activity summary", () => {
    db.execute(`
            DROP VIEW IF EXISTS user_activity_summary;
            CREATE VIEW user_activity_summary AS
            SELECT
                p.person_id,
                p.person_first_name || ' ' || p.person_last_name AS full_name,
                COUNT(DISTINCT dpr.device_id) AS devices_accessed,
                COUNT(DISTINCT uris.ur_ingest_session_id) AS ingest_sessions,
                COUNT(DISTINCT udi.ur_ingest_session_udi_pgp_sql_id) AS sql_queries_executed
            FROM person p
            LEFT JOIN device_party_relationship dpr ON p.person_id = dpr.party_id
            LEFT JOIN ur_ingest_session uris ON dpr.device_id = uris.device_id
            LEFT JOIN ur_ingest_session_udi_pgp_sql udi ON uris.ur_ingest_session_id = udi.ingest_session_id
            GROUP BY p.person_id, full_name;
        `);

    const result = db.query(
      `SELECT COUNT(*) AS count FROM user_activity_summary`,
    );
    assertEquals(result.length, 1);
    assertEquals(result[0][0], 0);
  });

  await t.step("automatically transformed resources", () => {
    const result = db.query(
      `SELECT COUNT(*) AS row_count FROM uniform_resource_transform;`,
    );
    assertEquals(result.length, 1);
    assertEquals(result[0][0], 3);
  });

  db.close();
});

Deno.test("multitenancy file ingestion", async (t) => {
  const multitenancyRssdPath = path.join(
    E2E_TEST_DIR,
    "resource-surveillance-multitenancy-e2e.sqlite.db",
  );

  if (await Deno.stat(multitenancyRssdPath).catch(() => null)) {
    await Deno.remove(multitenancyRssdPath).catch(() => false);
  }

  const tenantId = "assurance_id";
  const tenantName = "rsc-end-to-end-tester";

  await t.step("ingest files with tenant id and name", async () => {
    const ingestResult =
      await $`surveilr ingest files -d ${multitenancyRssdPath} -r ${INGEST_DIR}/10k_synthea_covid19_csv -r ${TEST_FIXTURES_DIR} --tenant-id=${tenantId} --tenant-name=${tenantName}`;

    assertEquals(
      ingestResult.code,
      0,
      `❌ Error: Failed to ingest data in ${INGEST_DIR}/10k_synthea_covid19_csv`,
    );

    assertExists(
      await Deno.stat(multitenancyRssdPath).catch(() => null),
      `❌ Error: ${multitenancyRssdPath} does not exist`,
    );
  });

  const db = new DB(multitenancyRssdPath);

  const partyTypeId = db.query<[string]>(
    "SELECT party_type_id FROM party_type WHERE value = ?1 LIMIT 1",
    ["Organization"],
  );
  const organizationPartyTypeId = partyTypeId[0][0];

  // select from organization using the tenantId as party_id
  await t.step("verify organization details", () => {
    const result = db.query<[string]>(
      "SELECT name FROM organization WHERE party_id = ?",
      [tenantId],
    );
    const name = result[0][0];
    assertEquals(
      name,
      tenantName,
      `❌ Error: organization details don't match in ${multitenancyRssdPath}`,
    );
  });

  // select from party and the party_id must be the same as the tenantId, party_type_id must be the same as the organizationPartyTypeId, party_name as tenamtName
  await t.step("verify party details", () => {
    const result = db.query<[string, string]>(
      "SELECT party_type_id, party_name FROM party WHERE party_id = ?",
      [tenantId],
    );
    const party_type_id = result[0][0];
    const party_name = result[0][1];
    assertEquals(
      party_type_id,
      organizationPartyTypeId,
      `❌ Error: party details don't match in ${multitenancyRssdPath}`,
    );
    assertEquals(
      party_name,
      tenantName,
      `❌ Error: party details don't match in ${multitenancyRssdPath}`,
    );
  });

  await t.step("verify tenant ID in transformed tables", () => {
    // Check a few tables to ensure tenant ID is correctly populated
    const tableCheckQueries = [
      "SELECT COUNT(*) FROM uniform_resource WHERE tenant_id = ?",
      "SELECT COUNT(*) FROM uniform_resource_transform WHERE tenant_id = ?"
    ];

    tableCheckQueries.forEach(query => {
      const result = db.query<[number]>(query, [tenantId]);
      assert(result[0][0] > 0, `❌ Error: No rows found with tenant ID in table`);
    });
  });

  db.close();
});

Deno.test("csv auto transformation", async (t) => {
  const csvAutoTeansformationRssd = path.join(
    E2E_TEST_DIR,
    "csv-autotransformation.e2e.sqlite.db",
  );

  if (await Deno.stat(csvAutoTeansformationRssd).catch(() => null)) {
    await Deno.remove(csvAutoTeansformationRssd).catch(() => false);
  }

  await t.step("ingest file syncing", async () => {
    const ingestResult =
      await $`surveilr ingest files -d ${csvAutoTeansformationRssd} -r ${TEST_FIXTURES_DIR} --csv-transform-auto`;
    assertEquals(
      ingestResult.code,
      0,
      `❌ Error: Failed to ingest data in ${csvAutoTeansformationRssd}`,
    );
  });

  const db = new DB(csvAutoTeansformationRssd);

  await t.step("confirm duplicate uniform resources", () => {
    db.execute(`
      DROP VIEW IF EXISTS file_change_history;
      CREATE VIEW file_change_history AS
      SELECT
          ur.uniform_resource_id,
          ur.uri,
          COUNT(DISTINCT isfp.ingest_session_id) AS ingest_session_count,
          GROUP_CONCAT(DISTINCT isfp.ingest_session_id) AS ingest_sessions,
          MIN(ing_sess.ingest_started_at) AS first_seen,
          MAX(ing_sess.ingest_started_at) AS last_seen
      FROM uniform_resource ur
      JOIN ur_ingest_session_fs_path_entry isfpe ON ur.uniform_resource_id = isfpe.uniform_resource_id
      JOIN ur_ingest_session_fs_path isfp ON isfpe.ingest_fs_path_id = isfp.ur_ingest_session_fs_path_id
      JOIN ur_ingest_session ing_sess ON isfp.ingest_session_id = ing_sess.ur_ingest_session_id
      GROUP BY ur.uniform_resource_id, ur.uri;
  `);

    const result = db.query<[number]>(
      `SELECT COUNT(*) AS count FROM file_change_history`,
    );
    assertEquals(result.length, 1);

    const files = result[0][0];
    initialIngestFileCount = files;
    assertEquals(files, initialIngestFileCount);
  });

  let initialnumberOfConvertedRecords = 0;

  await t.step("transformed csv tables", async () => {
    const result = db.query<[number]>(
      `SELECT COUNT(*) AS count FROM uniform_resource_allergies`,
    );
    assertEquals(result.length, 1);
    const numberOfConvertedRecords = result[0][0];
    initialnumberOfConvertedRecords = numberOfConvertedRecords;

    const csvRows = await countCSVRows(`${TEST_FIXTURES_DIR}/allergies.csv`);
    assertEquals(numberOfConvertedRecords, csvRows);
  });

  await t.step("re transform csvs without any change", async () => {
    const ingestResult =
      await $`surveilr ingest files -d ${csvAutoTeansformationRssd} -r ${TEST_FIXTURES_DIR} --csv-transform-auto`;
    assertEquals(
      ingestResult.code,
      0,
      `❌ Error: Failed to ingest data in ${TEST_FIXTURES_DIR}`,
    );
  });

  await t.step("handle multiple csv files with same name", async () => {
    // Prepare test files with same name but different content
    const testDir1 = path.join(TEST_FIXTURES_DIR, 'folder1');
    const testDir2 = path.join(TEST_FIXTURES_DIR, 'folder2');
    
    // Ensure test directories exist
    await Deno.mkdir(testDir1, { recursive: true });
    await Deno.mkdir(testDir2, { recursive: true });
  
    // Create two CSV files with same name but different content
    const csv1Path = path.join(testDir1, 'users.csv');
    const csv2Path = path.join(testDir2, 'users.csv');
  
    await Deno.writeTextFile(csv1Path, "id,name\n1,Alice\n2,Bob");
    await Deno.writeTextFile(csv2Path, "id,name\n3,Charlie\n4,David");
  
    const multipleFileRssd = path.join(
      E2E_TEST_DIR,
      "csv-multiple-files.e2e.sqlite.db"
    );
  
    if (await Deno.stat(multipleFileRssd).catch(() => false)) {
      await Deno.remove(multipleFileRssd);
    }
  
    // Ingest files with auto CSV transformation
    const ingestResult = await $`surveilr ingest files -d ${multipleFileRssd} -r ${TEST_FIXTURES_DIR} --csv-transform-auto`;
    assertEquals(
      ingestResult.code,
      0,
      `❌ Error: Failed to ingest data with multiple same-named CSVs`
    );
  
    // Open the database and verify
    const db = new DB(multipleFileRssd);
    
    try {
      const result = db.query<[number]>(
        `SELECT COUNT(*) AS count FROM uniform_resource_users`
      );
      assertEquals(result.length, 1);
      
      // Verify 4 rows are present
      const rowCount = result[0][0];
      assertEquals(rowCount, 4, "Should have 4 rows from both CSV files");
  
      // Optional: You might want to add more specific checks about the data
      const rows = db.query<[number, string]>(
        `SELECT id, name FROM uniform_resource_users ORDER BY id`
      );
      
      assertEquals(rows[0][0], 1);
      assertEquals(rows[0][1], "Alice");
      assertEquals(rows[1][0], 2);
      assertEquals(rows[1][1], "Bob");
      assertEquals(rows[2][0], 3);
      assertEquals(rows[2][1], "Charlie");
      assertEquals(rows[3][0], 4);
      assertEquals(rows[3][1], "David");
    } finally {
      db.close();
    }
  });

  await t.step("retain number of transformed csv records", () => {
    const result = db.query<[number]>(
      `SELECT COUNT(*) AS count FROM uniform_resource_allergies`,
    );
    assertEquals(result.length, 1);
    const numberOfConvertedRecords = result[0][0];

    assertEquals(numberOfConvertedRecords, initialnumberOfConvertedRecords);
  });

  db.close();
});


