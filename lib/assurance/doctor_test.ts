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
