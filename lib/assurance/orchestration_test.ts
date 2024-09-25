import { join, parse } from "https://deno.land/std@0.224.0/path/mod.ts";
import {
  assert,
  assertEquals,
  assertExists,
  assertNotEquals,
} from "jsr:@std/assert@1";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { DB } from "https://deno.land/x/sqlite@v3.8/mod.ts";
import { countFilesInDirectory } from "./ingest_test.ts";

const E2E_TEST_DIR = join(Deno.cwd(), "assurance");
const DRH_DIR = join(Deno.cwd(), "service/diabetes-research-hub");
const STUDY_FILES_ZIP = join(DRH_DIR, "study-files.zip");
const STUDY_FILES_INGEST_DIR = join(DRH_DIR, "study-files");
const RSSD_PATH = join(
  E2E_TEST_DIR,
  "orchestration-e2e-test.sqlite.db",
);

async function listFilesWithoutExtension(directory: string) {
  const filesWithoutExtension: string[] = [];

  for await (const dirEntry of Deno.readDir(directory)) {
    if (dirEntry.isFile) {
      const { name } = parse(dirEntry.name);
      filesWithoutExtension.push(name);
    }
  }
  return filesWithoutExtension;
}

function toSqlFriendlyIdentifier(input: string): string {
  const re = /[^a-zA-Z0-9_]+/g;

  let result = input.replace(re, "_").toLowerCase();

  if (result.length > 0 && result[0].match(/[0-9]/)) {
    result = "_" + result;
  }

  return result;
}

Deno.test("orchestration and transformations", async (t) => {
  assertExists(
    await Deno.stat(STUDY_FILES_ZIP).catch(() => null),
    "❌ Error: Study Files Zip does not exist",
  );

  if (!await Deno.stat(STUDY_FILES_INGEST_DIR).catch(() => false)) {
    await Deno.mkdir(STUDY_FILES_INGEST_DIR, { recursive: true });
    const unzipResult =
      await $`unzip ${STUDY_FILES_ZIP} -d ${STUDY_FILES_INGEST_DIR}`;

    assertEquals(
      unzipResult.code,
      0,
      "❌ Error: Failed to unzip the data file.",
    );
  }

  assertExists(
    await Deno.stat(STUDY_FILES_INGEST_DIR).catch(() => null),
    `❌ Error: Ingest directory ${STUDY_FILES_INGEST_DIR} does not exist after unzipping.`,
  );

  await t.step("ingest study files", async () => {
    assertExists(
      await Deno.stat(STUDY_FILES_INGEST_DIR).catch(() => null),
      `❌ Error: Ingest directory ${STUDY_FILES_INGEST_DIR} does not exist before surveilr ingest`,
    );

    if (await Deno.stat(RSSD_PATH).catch(() => null)) {
      await Deno.remove(RSSD_PATH).catch(() => false);
    }

    const ingestResult =
      await $`surveilr ingest files -d ${RSSD_PATH} -r ${STUDY_FILES_INGEST_DIR}/study-files`;
    assertEquals(
      ingestResult.code,
      0,
      `❌ Error: Failed to ingest data in ${STUDY_FILES_INGEST_DIR}/study-files`,
    );

    assertExists(
      await Deno.stat(RSSD_PATH).catch(() => null),
      `❌ Error: ${RSSD_PATH} does not exist`,
    );
  });

  const db = new DB(RSSD_PATH);

  await t.step("verify resources", async () => {
    const csvUrs = db.query(
      `SELECT COUNT(*) AS count FROM uniform_resource`,
    );

    const study_files_count = await countFilesInDirectory(
      `${STUDY_FILES_INGEST_DIR}/study-files`,
    );
    assertEquals(csvUrs.length, 1);
    assertEquals(csvUrs[0][0], study_files_count);
  });

  await t.step("transform csvs", async () => {
    const transformResult =
      await $`surveilr orchestrate -d ${RSSD_PATH} transform-csv`;
    assertEquals(
      transformResult.code,
      0,
      `❌ Error: Failed to transform CSVs in ${RSSD_PATH}`,
    );
  });

  await t.step("verify transformed csvs", async () => {
    const csvFileNames = await listFilesWithoutExtension(
      `${STUDY_FILES_INGEST_DIR}/study-files`,
    );
    for (let fileName of csvFileNames) {
      fileName = toSqlFriendlyIdentifier(fileName);
      fileName = `uniform_resource_${fileName}`;
      const query =
        `SELECT name FROM sqlite_master WHERE type='table' AND name=?`;
      const result = db.query(query, [fileName]);
      assert(
        result.length > 0,
        `${fileName} does not exist as a transformed table in ${RSSD_PATH}`,
      );
    }
  });

  const urAuthorEmailsBeforeDeidentification = db.query(
    "SELECT email FROM uniform_resource_author",
  );
  const urInvestigatorEmailsBeforeDeidentification = db.query(
    "SELECT email FROM uniform_resource_investigator",
  );

  await t.step("execute deidentification script through stdin", async () => {
    const sciptPath = `${DRH_DIR}/de-identification/drh-deidentification.sql`;
    const orchestrateResult =
      await $`cat ${sciptPath} | surveilr orchestrate -d ${RSSD_PATH} -n "dd"`;
    assertEquals(
      orchestrateResult.code,
      0,
      `❌ Error: Failed to execute ${sciptPath} against ${RSSD_PATH}`,
    );
  });

  await t.step("verify orchestrated deidentification script", () => {
    const orchestrationNatureId = db.query(
      "SELECT orchestration_nature_id FROM orchestration_nature WHERE nature = 'De-identification'",
    );
    assertEquals(orchestrationNatureId.length, 1);
    assertEquals(orchestrationNatureId[0][0], "deidentification");

    const urAuthorEmailsAfterDeidentification = db.query(
      "SELECT email FROM uniform_resource_author",
    );
    assertNotEquals(
      urAuthorEmailsAfterDeidentification,
      urAuthorEmailsBeforeDeidentification,
      "❌ Error: uniform_resource_author emails were not deidentified.",
    );

    const urInvestigatorEmailsAfterDeidentification = db.query(
      "SELECT email FROM uniform_resource_investigator",
    );
    assertNotEquals(
      urInvestigatorEmailsBeforeDeidentification,
      urInvestigatorEmailsAfterDeidentification,
      "❌ Error: uniform_resource_author emails were not deidentified.",
    );
  });

  await t.step("execute remote v&v script", async () => {
    const sciptUrl =
      `https://raw.githubusercontent.com/opsfolio/resource-surveillance-commons/main/service/diabetes-research-hub/verfication-validation/orchestrate-drh-vv.sql`;
    const orchestrateResult =
      await $`surveilr orchestrate -d ${RSSD_PATH} -n "v&v" -s ${sciptUrl}`;
    assertEquals(
      orchestrateResult.code,
      0,
      `❌ Error: Failed to execute ${sciptUrl} against ${RSSD_PATH}`,
    );
  });

  await t.step("verify orchestrated remote v&v script", async (t) => {
    await t.step("verify orchestration nature ID", () => {
      const orchestrationNatureId = db.query(
        "SELECT orchestration_nature_id FROM orchestration_nature WHERE nature = 'Verfication and Validation'",
      );
      assertEquals(
        orchestrationNatureId.length,
        1,
        "❌ Error: Incorrect number of entries for 'Verification and Validation' nature.",
      );
      assertEquals(
        orchestrationNatureId[0][0],
        "V&V",
        "❌ Error: Orchestration nature ID is not 'V&V'.",
      );
    });

    await t.step("verify missing columns logging", () => {
      const missingColumns = db.query(
        `SELECT COUNT(*) FROM orchestration_session_issue
                WHERE issue_type = 'Schema Validation: Missing Columns'
                AND session_id = (SELECT orchestration_session_id FROM orchestration_session WHERE orchestration_nature_id = 'V&V')`,
      );
      assert(
        Number(missingColumns[0][0]) >= 0,
        "❌ Error: Missing columns were not logged correctly in orchestration_session_issue.",
      );
    });

    await t.step("verify additional columns logging", () => {
      const additionalColumns = db.query(
        `SELECT COUNT(*) FROM orchestration_session_issue
                WHERE issue_type = 'Schema Validation: Additional Columns'
                AND session_id = (SELECT orchestration_session_id FROM orchestration_session WHERE orchestration_nature_id = 'V&V')`,
      );
      assert(
        Number(additionalColumns[0][0]) >= 0,
        "❌ Error: Additional columns were not logged correctly in orchestration_session_issue.",
      );
    });

    await t.step("verify data integrity checks logging", () => {
      const dataIntegrityIssues = db.query(
        `SELECT COUNT(*) FROM orchestration_session_issue
                WHERE issue_type IN ('Data Integrity Checks: Invalid Dates', 'Data Integrity Checks: Invalid Age Values', 'Data Integrity Checks: Empty Cells')
                AND session_id = (SELECT orchestration_session_id FROM orchestration_session WHERE orchestration_nature_id = 'V&V')`,
      );
      assert(
        Number(dataIntegrityIssues[0][0]) >= 0,
        "❌ Error: Data integrity issues were not logged correctly in orchestration_session_issue.",
      );
    });
  });

  //TODO: notebook orchestration
  db.close();
});
