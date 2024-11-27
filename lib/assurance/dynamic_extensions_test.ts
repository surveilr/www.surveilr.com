import { assertExists } from "https://deno.land/std@0.187.0/testing/asserts.ts";
import { ensureDir } from "https://deno.land/std@0.213.0/fs/mod.ts";
import * as path from "https://deno.land/std@0.224.0/path/mod.ts";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";
import { assert, assertEquals } from "jsr:@std/assert@1";

const E2E_TEST_DIR = path.fromFileUrl(
  import.meta.resolve(`./`),
);
const extensionsDir = path.join(E2E_TEST_DIR, "extensions");

Deno.test("Setup", async (t) => {
  await t.step("Verify sqlpkg installation", async () => {
    try {
      await $`sqlpkg version`.quiet();
    } catch {
      console.log("sqlpkg is not installed. Installing...");
      if (Deno.build.os === "windows") {
        await $`curl.exe https://webi.ms/sqlpkg | powershell`;
      } else {
        await $`curl -sS https://webi.sh/sqlpkg | sh`;
      }
    }
    const sqlpkgVersionResult = await $`sqlpkg version`.stdout("piped");
    assertEquals(
      sqlpkgVersionResult.code,
      0,
      "❌ Error: Failed to check version of sqlpkg",
    );
    assertEquals(
      sqlpkgVersionResult.stdout,
      "0.2.3\n",
      "❌ sqlpkg version mismatch",
    );
  });

  await t.step("Install nalgeon/text extension", async () => {
    const result = await $`sqlpkg install nalgeon/sqlean`.stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to install the text extension",
    );
    assert(
      result.stdout.includes("installed package nalgeon/sqlean") ||
        result.stdout.includes("already at the latest version"),
      "❌ added ",
    );
  });
});

Deno.test("use sqlpkg defaults", async (t) => {
  await t.step("text_substring", async () => {
    const result =
      await $`surveilr shell --cmd "select text_substring('hello world', 7);" --sqlpkg`
        .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr text_substring function.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "world");
  });

  await t.step("text_substring_end", async () => {
    const result =
      await $`surveilr shell --cmd "select text_substring('hello world', 7, 5);" --sqlpkg`
        .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr text_substring function.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "world");
  });

  await t.step("regexp_like", async () => {
    const result =
      await $`surveilr shell --cmd "select regexp_like('the year is 2021', '[0-9]+');" --sqlpkg`
        .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr regexp_like function.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, 1);
  });

  await t.step("regexp_substr", async () => {
    const result =
      await $`surveilr shell --cmd "select regexp_substr('the year is 2021', '[0-9]+');" --sqlpkg`
        .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr regexp_substr function.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "2021");
  });
});

Deno.test("combine with sqlite-dyn-extn", async (t) => {
  await t.step("install asg017/path extension", async () => {
    try {
      await installSqlitePath();
      if (Deno.build.os === "darwin") {
        assertExists(
          await Deno.stat(`${extensionsDir}/path0.dylib`).catch(() => null),
        );
      } else {
        assertExists(
          await Deno.stat(`${extensionsDir}/path0.so`).catch(() => null),
        );
      }
    } catch (err) {
      assert(false, err as string);
    }
  });

  await t.step("run surveilr", async () => {
    const result =
      await $`surveilr shell --cmd "SELECT text_substring('hello world', 7, 5) AS substring_result, math_sqrt(9) AS sqrt_result, path_parts.type, path_parts.part FROM (SELECT * FROM path_parts('/usr/bin/sqlite3')) AS path_parts;" --sqlpkg --sqlite-dyn-extn ${extensionsDir}/path0.${
        Deno.build.os === "darwin" ? "dylib" : "so"
      }`
        .stdout("piped");

    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute combination of sqlite-dyn-extn function.",
    );

    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "world");
  });
});

async function installSqlitePath() {
  if (await Deno.stat(extensionsDir).catch(() => false)) {
    await Deno.remove(extensionsDir, { recursive: true });
  }
  await ensureDir(extensionsDir);

  const os = Deno.build.os;
  let archiveName: string = "";

  switch (os) {
    case "linux":
      archiveName = "sqlite-path-v0.2.1-loadable-linux-x86_64.tar.gz";
      break;
    case "darwin":
      archiveName = "sqlite-path-v0.2.1-loadable-macos-x86_64.tar.gz";
      break;
    case "windows":
      archiveName = "sqlite-path-v0.2.1-loadable-windows-x86_64.zip";
      break;
    default:
      archiveName = "sqlite-path-v0.2.1-loadable-linux-x86_64.tar.gz";
  }

  const archiveUrl =
    `https://github.com/asg017/sqlite-path/releases/download/v0.2.1/${archiveName}`;
  $.logStep(`Downloading archive from: ${archiveUrl}`);

  const archivePath = path.join(extensionsDir, archiveName);
  await $`curl -L -o ${archivePath} ${archiveUrl}`;
  $.logStep(`Downloaded archive to: ${archivePath}`);

  if (archiveName.endsWith(".tar.gz")) {
    await $`tar -xzf ${archivePath} -C ${extensionsDir}`;
  } else if (archiveName.endsWith(".zip")) {
    await $`unzip -o ${archivePath} -d ${extensionsDir}`;
  } else {
    throw new Error(`Unknown archive format: ${archivePath}`);
  }

  $.logStep(`Extracted archive to: ${extensionsDir}`);
  await Deno.remove(`${archivePath}`);
}
