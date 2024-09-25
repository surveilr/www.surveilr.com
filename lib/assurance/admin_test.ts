import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import {
  assertEquals,
  assertExists,
} from "https://deno.land/std@0.187.0/testing/asserts.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { DB } from "https://deno.land/x/sqlite@v3.8/mod.ts";

const E2E_TEST_DIR = path.join(Deno.cwd(), "assurance");

Deno.test("set env variables with credentials command", async () => {
  const microsoftClientId = "client_id";
  const microsoftSecret = "secretkey";

  const setCredentialResult =
    await $`surveilr admin credentials microsoft-365 -i ${microsoftClientId} -s ${microsoftSecret} --env`
      .text();
  const expectedOutput =
    `MICROSOFT_365_CLIENT_ID=${microsoftClientId}\nMICROSOFT_365_CLIENT_SECRET=${microsoftSecret}`;
  assertEquals(setCredentialResult, expectedOutput);
});

Deno.test("initialize empty rssd", async (t) => {
  const emptyRssdPath = path.join(E2E_TEST_DIR, "empty-e2e-test.sqlite.db");

  await t.step("without device", async () => {
    const initResult = await $`surveilr admin init -d ${emptyRssdPath}`;
    assertEquals(
      initResult.code,
      0,
      `❌ Error: Failed to initialize RSSD: ${emptyRssdPath}`,
    );

    assertExists(
      await Deno.stat(emptyRssdPath).catch(() => null),
      `❌ Error: RSSD: ${emptyRssdPath} was not created`,
    );
  });

  await t.step("with device and remove existing RSSD first", async () => {
    const initResult =
      await $`surveilr admin init -d ${emptyRssdPath} -r --with-device`;
    assertEquals(
      initResult.code,
      0,
      `❌ Error: Failed to initialize RSSD: ${emptyRssdPath}`,
    );

    assertExists(
      await Deno.stat(emptyRssdPath).catch(() => null),
      `❌ Error: RSSD: ${emptyRssdPath} was not created`,
    );

    const db = new DB(emptyRssdPath);
    const device = db.query<[string]>("SELECT state FROM device LIMIT 1");
    const state = device[0][0];

    assertEquals(
      state,
      `"SINGLETON"`,
      `❌ Error: device state in RSSD: ${emptyRssdPath} is not singleton`,
    );
    db.close();

    await Deno.remove(emptyRssdPath).catch(() => false);
  });
});

Deno.test("merge RSSDs", async () => {
  const aggregatedRssdPath = path.join(
    E2E_TEST_DIR,
    "resource-surveillance-aggregated.sqlite.db",
  );

  const mergeResult = await $`surveilr admin merge -d ${aggregatedRssdPath}`;
  assertEquals(
    mergeResult.code,
    0,
    `❌ Error: Failed to merge RSSDs`,
  );

  assertExists(
    await Deno.stat(aggregatedRssdPath).catch(() => null),
    `❌ Error: RSSD: ${aggregatedRssdPath} was not created`,
  );
});
