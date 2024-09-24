import { assert } from "https://deno.land/std@0.224.0/assert/assert.ts";
import * as s from "../lib/universal/spawn.ts";
import { path } from "./deps.ts";
import { rssdNB } from "./notebook/mod.ts";
import * as mod from "./lifecycle.sql.ts";

const inMemSqliteResult = async (
  sqlSupplier: Uint8Array | s.FlexibleTextSupplierSync,
) => {
  return {
    executionID: crypto.randomUUID(),
    ...await s.spawnedResult(
      ["sqlite3", ":memory:"],
      undefined,
      sqlSupplier,
    ),
    sqlScript: () => s.textFromSupplierSync(sqlSupplier),
  };
};

const persistSpawnedResult = async (
  sr: Awaited<ReturnType<typeof inMemSqliteResult>>,
) => {
  // Usually unit tests should emit their errors as part of Deno.test output
  // but SQL could be very long so it's best to store in an file.
  const ssFileName = path.fromFileUrl(import.meta.resolve(
    `${import.meta.filename}-ERROR-${sr.executionID}.sql`,
  ));
  const sqliteStatusFName = path.fromFileUrl(import.meta.resolve(
    `${import.meta.filename}-ERROR-${sr.executionID}.md`,
  ));
  await Deno.writeTextFile(ssFileName, sr.sqlScript());
  await Deno.writeTextFile(
    sqliteStatusFName,
    // deno-fmt-ignore
    rssdNB.unindentedText`
                # STDOUT
                ${sr.stdoutRaw.length > 0 ? `\`\`\`\n${sr.stdout()}\n\`\`\`` : `None`}

                # STDERR
                \`\`\`
                ${sr.stderr()}
                \`\`\`

                # SQL
                \`\`\`sql
                ${sr.sqlScript()}
                \`\`\`
                `,
  );
  return {
    ssFileName,
    sqliteStatusFName,
  };
};

Deno.test("Load RSSD bootstrap.sql into in-memory SQLite database via sqlite3 shell", async () => {
  const sr = await inMemSqliteResult((await mod.SQL()).join("\n"));
  if (sr.success) {
    assert(sr.success, `Invalid SQL (this should never happen)`);
  } else {
    // Usually unit tests should emit their errors as part of Deno.test output
    // but SQL could be very long so it's best to store in an file.
    const { ssFileName, sqliteStatusFName } = await persistSpawnedResult(
      sr,
    );
    assert(
      sr.success,
      `${sr.stderr()}\nSQL: ${ssFileName}\nResults: ${sqliteStatusFName}`,
    );
  }
});

Deno.test("Generate and execute migration script from in-memory SQLite database via sqlite3 shell", async () => {
  const isr = await inMemSqliteResult([
    (await mod.SQL()).join("\n"), // the "init DDL" executed first
    "select migration_sql from code_notebook_migration_sql;", // run code_notebook_migration_sql view and get result
  ]);
  if (isr.success) {
    const migSR = await inMemSqliteResult([
      (await mod.SQL()).join("\n"), // the "init DDL" executed first again since previous in-memory instance is gone
      isr.stdout(), // result of "select migration_sql from code_notebook_migration_sql"
      // TODO: run SQL assurance select statements to check that migrations actually succeeded
      // TODO: check migration state tables, etc.
    ]);
    if (migSR.success) {
      assert(migSR.success, `Invalid SQL (this should never happen)`);
    } else {
      const { ssFileName, sqliteStatusFName } = await persistSpawnedResult(
        migSR,
      );
      assert(
        migSR.success,
        `${migSR.stderr()}\nMigrate SQL: ${ssFileName}\nResults: ${sqliteStatusFName}`,
      );
    }
  } else {
    const { ssFileName, sqliteStatusFName } = await persistSpawnedResult(
      isr,
    );
    assert(
      isr.success,
      `${isr.stderr()}\nInit SQL: ${ssFileName}\nResults: ${sqliteStatusFName}`,
    );
  }
});
