import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { DB } from "https://deno.land/x/sqlite@v3.9.1/mod.ts";
import {
  assertEquals,
  assertExists,
} from "https://deno.land/std@0.187.0/testing/asserts.ts";

const E2E_TEST_DIR = path.fromFileUrl(
  import.meta.resolve(`./`),
);
const RSSD_PATH = path.join(E2E_TEST_DIR, "surveilr-doctor-e2e.db");

// Deno.test("surveilr doctor", async (t) => {
//     await t.step("add surveilr capexec file to PATH", () => {
//         const testFixturesDir = path.join(E2E_TEST_DIR, "test-fixtures");
//         // add testFixturesDir to the PATH env
//     });

//     await t.step("add surveilr_doctor view to the RSSD", () => {
//         // add a view and make the name start with surveilr_doctor_* to the RSDD_PATH.
//         // add data to the view too.
//     });

//     await t.step("execute surveilr doctor", async () => {
//         const result = await $`surveilr doctor -d ${RSSD_PATH} --json`;
//         assertEquals(
//             result.code,
//             0,
//             `❌ Error: Failed to execute surveilr doctor with RSSD: ${RSSD_PATH}`,
//         );
//     });

//     await t.step("verify surveilr doctor results", () => {
//         // the above step will print JSON like this to the console
//         // 1. verify that versions object is present and that the deno version is at least 2.0.0
//         // 2. verfiy that the view created in the ste above is present, then verify that the column names match
//         // {
//         //     "versions": {
//         //       "deno": "deno 2.0.4 (stable, release, x86_64-unknown-linux-gnu)",
//         //       "rustc": "rustc 1.82.0 (f6e511eec 2024-10-15)",
//         //       "sqlite3": "3.45.2 2024-03-12 11:06:23 d8cd6d49b46a395b13955387d05e9e1a2a47e54fb99f3c9b59835bbefad6af77 (64-bit)"
//         //     },
//         //     "extensions": [
//         //       "math.so",
//         //       "stats.so",
//         //       "uuid.so",
//         //       "text.so",
//         //       "math.so",
//         //       "regexp.so",
//         //       "define.so",
//         //       "fileio.so",
//         //       "sqlean.so",
//         //       "ipaddr.so",
//         //       "vsv.so",
//         //       "fuzzy.so",
//         //       "crypto.so",
//         //       "time.so",
//         //       "unicode.so",
//         //       "text.so",
//         //       "path0.so"
//         //     ],
//         //     "views": [
//         //       {
//         //         "view_name": "surveilr_doctor_sql_cell_migratable_version",
//         //         "columns": [
//         //           "code_notebook_cell_id",
//         //           "notebook_name",
//         //           "cell_name",
//         //           "interpretable_code_hash",
//         //           "is_idempotent",
//         //           "version_timestamp"
//         //         ],
//         //         "rows": [
//         //           [
//         //             "01JEPPJJKFSJAY38T68FP8W747",
//         //             "ConstructionSqlNotebook",
//         //             "session_ephemeral_table",
//         //             "b739acd000cf37091bbb365085506f975345351d",
//         //             "NULL",
//         //             "2024-12-09 21:53:47"
//         //           ],
//         //           [
//         //             "01JEPPJJKF4BGFVARGBEHBBKAN",
//         //             "ConstructionSqlNotebook",
//         //             "v001_once_initialDDL",
//         //             "c2c0ebe93c6799d6f1570841d13bbc0fc06ea224",
//         //             "NULL",
//         //             "2024-12-09 21:53:47"
//         //           ],
//         //           [
//         //             "01JEPPJJKFQWMDB69QR7Y2CBK2",
//         //             "ConstructionSqlNotebook",
//         //             "v001_seedDML",
//         //             "7d8f175c6d1e0dd76fb695437d35d4e49e1101b8",
//         //             "NULL",
//         //             "2024-12-09 21:53:47"
//         //           ]
//         //         ]
//         //       }
//         //     ]
//         //   }
//     })
// });

Deno.test("surveilr doctor", async (t) => {
  await t.step("add surveilr capexec file to PATH", () => {
    const testFixturesDir = path.join(E2E_TEST_DIR, "test-fixtures");
    const currentPath = Deno.env.get("PATH") || "";
    Deno.env.set("PATH", `${testFixturesDir}:${currentPath}`);
  });

  await t.step("add surveilr_doctor view to the RSSD", () => {
    const db = new DB(RSSD_PATH);

    db.execute(`
            CREATE VIEW surveilr_doctor_test_view AS
            SELECT
                "test_id" AS id,
                "test_name" AS name,
                "test_value" AS value;
        `);

    const views = [
      ...db.query(
        `SELECT name FROM sqlite_master WHERE type='view' AND name LIKE 'surveilr_doctor_%'`,
      ),
    ];
    assertExists(
      views.find((view) => view[0] === "surveilr_doctor_test_view"),
      "View surveilr_doctor_test_view was not created",
    );

    db.close();
  });

  await t.step("execute surveilr doctor", async () => {
    const result = await $`surveilr doctor -d ${RSSD_PATH} --json`
      .noThrow().stdout("piped");
    assertEquals(
      result.code,
      0,
      `❌ Error: Failed to execute surveilr doctor with RSSD: ${RSSD_PATH}`,
    );

    const output = JSON.parse(result.stdout);

    Deno.env.set("SURVEILR_DOCTOR_OUTPUT", JSON.stringify(output));
  });

  await t.step("verify surveilr doctor results", () => {
    const output = JSON.parse(
      Deno.env.get("SURVEILR_DOCTOR_OUTPUT") || "{}",
    );

    assertExists(output.versions, "❌ Missing 'versions' in output");
    assertExists(
      output.versions.deno,
      "❌ Missing 'deno' version in output",
    );
    assertExists(
      output.versions.rustc,
      "❌ Missing 'rustc' version in output",
    );
    assertExists(
      output.versions.sqlite3,
      "❌ Missing 'sqlite3' version in output",
    );

    const denoVersion = output.versions.deno.match(/deno (\d+\.\d+\.\d+)/);
    assertExists(denoVersion, "❌ Deno version string is invalid");
    const [_, denoVersionNumber] = denoVersion;
    assertEquals(
      denoVersionNumber >= "2.0.0",
      true,
      `❌ Deno version must be at least 2.0.0, found: ${denoVersionNumber}`,
    );

    assertExists(output.extensions, "❌ Missing 'extensions' in output");
    assertEquals(
      Array.isArray(output.extensions),
      true,
      "❌ 'extensions' should be an array",
    );

    assertExists(output.views, "❌ Missing 'views' in output");
    const testView = output.views.find((view: { view_name: string }) =>
      view.view_name === "surveilr_doctor_test_view"
    );
    assertExists(
      testView,
      "❌ 'surveilr_doctor_test_view' not found in views",
    );

    assertEquals(
      testView.columns,
      ["id", "name", "value"],
      "❌ Columns of 'surveilr_doctor_test_view' do not match",
    );
    assertEquals(
      testView.rows.length > 0,
      true,
      "❌ No rows found in 'surveilr_doctor_test_view'",
    );

    console.log("✅ All verifications passed");
  });

  await t.step("cleanup RSSD file", async () => {
    try {
      await Deno.remove(RSSD_PATH);
      console.log(`🧹 Successfully cleaned up RSSD file at ${RSSD_PATH}`);
    } catch (error) {
      console.error(
        `❌ Failed to delete RSSD file at ${RSSD_PATH}:`,
        error,
      );
      throw error;
    }
  });
});
