import { assertEquals } from "jsr:@std/assert@1";
import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";

Deno.test("eval function: execute arbitrary SQL and returns the result as string", async (t) => {
  await t.step(
    "basic select",
    async () => {
      const result = await $`surveilr shell --cmd "select eval('select 42')"`
        .stdout("piped");
      assertEquals(
        result.code,
        0,
        "❌ Error: Failed to select basic eval integer.",
      );
      const stdout = result.stdoutJson;
      const value = stdout[0][Object.keys(stdout[0])[0]];
      assertEquals(value, "42");
    },
  );

  await t.step("integer additions", async () => {
    const result = await $`surveilr shell --cmd "select eval('select 10 + 32')"`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to select basic eval integer.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "42");
  });

  await t.step("absolutes", async () => {
    const result =
      await $`surveilr shell --cmd "select eval('select abs(-42)')"`
        .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to select basic eval integer.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "42");
  });

  await t.step("string selections", async () => {
    const result =
      await $`surveilr shell --cmd "select eval('select ''hello''')"`
        .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to select basic eval strings.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "hello");
  });
});

Deno.test("eval function: joins multiple result values", async (t) => {
  await t.step("default separator", async () => {
    const result = await $`surveilr shell --cmd "select eval('select 1, 2, 3')"`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to select basic eval integer.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "1 2 3");
  });

  await t.step("custom separator", async () => {
    const result =
      await $`surveilr shell --cmd "select eval('select 1, 2, 3', '|')"`
        .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to select basic eval integer.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "1|2|3");
  });
});

Deno.test("eval function: Joins multiple result rows into a single string", async (t) => {
  await t.step("default separator", async () => {
    const result =
      await $`surveilr shell --cmd "select eval('select 1; select 2; select 3;')"`
        .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to select basic eval integer.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "1 2 3");
  });

  await t.step("custom separator", async () => {
    const result =
      await $`surveilr shell --cmd "select eval('select 1, 2, 3; select 4, 5, 6; select 7, 8, 9;')"`
        .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to select basic eval integer.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "1 2 3 4 5 6 7 8 9");
  });
});

Deno.test("surveilr specific functions", async (t) => {
  await t.step("surveilr --version", async () => {
    const versionResult = await $`surveilr --version`
      .stdout("piped");
    assertEquals(
      versionResult.code,
      0,
      "❌ Error: Failed to check status.",
    );
    let version = versionResult.stdout;
    version = version.split(" ")[1].trim();

    const result = await $`surveilr shell --cmd "SELECT surveilr_version();"`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr version function.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, version);
  });

  await t.step("mask", async () => {
    const result = await $`surveilr shell --cmd "SELECT mask('1234567890');"`
      .stdout("piped");
    assertEquals(
      result.code,
      0,
      "❌ Error: Failed to execute surveilr mask function.",
    );
    const stdout = result.stdoutJson;
    const value = stdout[0][Object.keys(stdout[0])[0]];
    assertEquals(value, "*********");
  });
});
