import { join } from "https://deno.land/std@0.224.0/path/mod.ts";
import { assertEquals } from "jsr:@std/assert@1";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";

const E2E_TEST_DIR = join(Deno.cwd(), "lib/assurance");
const RSSD_PATH = join(
  E2E_TEST_DIR,
  "imap-e2e-test.sqlite.db",
);

Deno.test("imap ingestion", async (t) => {
  await t.step("gmail imap ingestion", async () => {
    if (await Deno.stat(RSSD_PATH).catch(() => null)) {
      await Deno.remove(RSSD_PATH).catch(() => false);
    }

    const email = `surveilrregression@gmail.com`;
    const host = `imap.gmail.com`;
    const password = `ingq hidi atao zrka`;
    const imapIngestResult =
      await $`surveilr ingest imap -d ${RSSD_PATH} -u ${email} -p ${password} -a ${host} -b 20 -s all`;
    assertEquals(
      imapIngestResult.code,
      0,
      `❌ Error: Failed to ingest email from ${email} box`,
    );
  });
});
