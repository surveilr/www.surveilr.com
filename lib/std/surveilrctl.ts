#!/usr/bin/env -S deno run --allow-run --allow-env --allow-net --allow-read --allow-write

import { debounce } from "https://deno.land/std@0.224.0/async/debounce.ts";
import {
  brightGreen,
  brightRed,
  brightWhite,
  brightYellow,
  cyan,
  dim,
} from "https://deno.land/std@0.224.0/fmt/colors.ts";
import {
  fromFileUrl,
  isAbsolute,
  join,
  relative,
  resolve,
} from "https://deno.land/std@0.224.0/path/mod.ts";
import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.4/command/mod.ts";
import { spawnedResult } from "../universal/spawn.ts";
import { timeSince } from "../universal/temporal.ts";

// TODO: replace `sqlite3` default with `surveilr shell` allowing optional
// replacement with `sqlite3` if --external-sqlite3 passed in as argument

const DEV_DEFAULT_PORT = 9000;
const DEV_DEFAULT_DB = Deno.env.get("SURVEILR_STATEDB_FS_PATH") ??
  "resource-surveillance.sqlite.db";

async function observeSqlPageFiles(db: string) {
  const dbFileStat = Deno.lstatSync(db);
  const sqliteResult = await spawnedResult(
    ["sqlite3", db, "--json"],
    undefined,
    `SELECT path, length(contents) as contentsSize, last_modified as modifiedAt FROM sqlpage_files;`,
  );
  const stdErr = sqliteResult.stderr().trim();
  if (stdErr.length) console.log(brightRed(stdErr));
  return {
    db: resolve(db),
    dbFileStat,
    ...sqliteResult,
    sqlPageFiles: () =>
      JSON.parse(
        sqliteResult.stdout(),
        (key, value) => key == "modifiedAt" ? new Date(value) : value,
      ) as {
        readonly path: string;
        readonly modifiedAt: Date;
        readonly contentsSize: number;
      }[],
  };
}

/**
 * Executes SQL scripts from a given file on an SQLite database.
 * The file can be a plain SQL file or a TypeScript file. For TypeScript files, the default export
 * must provide the SQL script either directly as a string or via a function that returns a string.
 *
 * @param file - The path to the file containing the SQL script.
 * @param db - The path to the SQLite database file.
 */
async function executeSqlite3(
  file: string,
  db: string,
  showModifiedUrlsOnChange: boolean,
) {
  let sqlScript: string | null = "";

  const stat = Deno.lstatSync(file);
  if (!file.endsWith(".sql") && stat.mode && (stat.mode & 0o111)) {
    const execFileResult = await spawnedResult([file]);
    sqlScript = execFileResult.stdout();
    if (!sqlScript) {
      return; // Exit if there was an error or no script was found
    }
    console.log(
      dim(`⌛ Executing generated ${relative(".", file)} in database ${db}`),
    );
  } else {
    // For .sql files, read the contents directly
    sqlScript = await Deno.readTextFile(file);
    console.log(dim(`⌛ Executing ${relative(".", file)} in database ${db}`));
  }

  const observeBefore = showModifiedUrlsOnChange
    ? await observeSqlPageFiles(db)
    : null;
  const sqlResult = await spawnedResult(["sqlite3", db], undefined, sqlScript);
  if (sqlResult.success) {
    console.log(
      dim(`✅`),
      brightGreen(`cat ${relative(".", file)} | sqlite3 ${db}`),
    );
  } else {
    // if you change the name of this file, update watchFiles(...) call and gitignore
    const errorSqlScriptFName = `ERROR-${crypto.randomUUID()}.sql`;
    Deno.writeTextFile(errorSqlScriptFName, sqlScript);
    console.error(
      dim(`❌`),
      brightRed(
        `Failed to execute ${
          relative(".", file)
        } (${sqlResult.code}) [see ${errorSqlScriptFName}]`,
      ),
    );
    if (!file.endsWith(".sql")) {
      console.error(
        dim(`❗`),
        brightYellow(
          `Reminder: ${
            relative(".", file)
          } must be executable in order to generate SQL.`,
        ),
      );
    }
  }
  const stdOut = sqlResult.stdout().trim();
  if (stdOut.length) console.log(dim(stdOut));
  console.log(brightRed(sqlResult.stderr()));

  const observeAfter = showModifiedUrlsOnChange
    ? await observeSqlPageFiles(db)
    : null;
  return {
    sqlScript,
    sqlResult,
    observeBefore,
    observeAfter,
    sqlPageFilesModified: showModifiedUrlsOnChange
      ? observeAfter?.sqlPageFiles().filter((afterEntry) => {
        const beforeEntry = observeBefore?.sqlPageFiles().find((beforeEntry) =>
          beforeEntry.path === afterEntry.path
        );
        return (
          !beforeEntry ||
          beforeEntry.modifiedAt.getTime() !==
            afterEntry.modifiedAt.getTime() ||
          beforeEntry.contentsSize !== afterEntry.contentsSize
        );
      })
      : null,
  };
}

/**
 * Watches for changes in the specified files and triggers the execution of SQL scripts
 * on the SQLite database whenever a change is detected.
 *
 * @param watch.paths - The list of paths to watch
 * @param watch.recusive - Whether to watch the list of paths recursively
 * @param files - The list of files to watch.
 * @param db - The path to the SQLite database file.
 * @param service
 * @showModifiedUrlsOnChange - Query the database and see what was changed between calls
 */
async function watchFiles(
  watch: { paths: string[]; recursive: boolean },
  files: RegExp[],
  db: string,
  load: string[] | undefined,
  service: {
    readonly stop?: () => Promise<void>;
    readonly start?: () => Promise<void>;
  },
  showModifiedUrlsOnChange: boolean,
) {
  try {
    console.log(
      dim(
        `👀 Watching paths [${watch.paths.join(" ")}] ${
          files.map((f) => f.toString()).join(", ")
        } (${watch.paths.length})`,
      ),
    );
    if (load?.length) {
      for (const l of load) {
        console.log(
          dim(
            `🔃 Loading ${
              relative(Deno.cwd(), isAbsolute(l) ? l : join(Deno.cwd(), l))
            } on change`,
          ),
        );
      }
    }
    const reload = debounce(async (event: Deno.FsEvent) => {
      for (const path of event.paths) {
        for (const file of files) {
          if (file.test(path)) {
            // deno-fmt-ignore
            console.log(dim(`👀 Watch event (${event.kind}): ${brightWhite(relative(".", path))}`));
            await service.stop?.();
            let result: Awaited<ReturnType<typeof executeSqlite3>>;
            if (load?.length) {
              // instead of the file that's being modified we want to load a
              // different (set) of files (usually package.sql.ts)
              for (const l of load) {
                result = await executeSqlite3(
                  isAbsolute(l) ? l : join(Deno.cwd(), l),
                  db,
                  showModifiedUrlsOnChange,
                );
              }
            } else {
              // no custom loaders passed in, just reload the file that was modified
              result = await executeSqlite3(path, db, showModifiedUrlsOnChange);
            }
            if (showModifiedUrlsOnChange) {
              const spFiles = result?.sqlPageFilesModified?.sort((a, b) =>
                b.modifiedAt.getTime() - a.modifiedAt.getTime()
              );
              // deno-fmt-ignore
              console.log(dim(`${relative('.', result?.observeAfter?.db ?? '.')} size ${result?.observeBefore?.dbFileStat.size} -> ${result?.observeAfter?.dbFileStat.size} (${result?.observeBefore?.dbFileStat.mtime} -> ${result?.observeAfter?.dbFileStat.mtime})`));
              if (spFiles) {
                for (const spf of spFiles) {
                  // deno-fmt-ignore
                  console.log(cyan(`http://localhost:9000/${spf.path}`), `[${spf.contentsSize}]`, dim(`(${timeSince(spf.modifiedAt)} ago, ${spf.modifiedAt})`));
                }
              }
            }
            service.start?.();
          }
        }
      }
    }, 200);

    const watcher = Deno.watchFs(watch.paths, { recursive: watch.recursive });
    for await (const event of watcher) {
      if (event.kind === "modify" || event.kind === "create") {
        reload(event);
      }
    }
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      console.log(
        brightRed(`Invalid watch path: ${watch.paths.join(":")} (${error})`),
      );
    } else {
      console.log(brightRed(`watchFiles issue: ${error} (${files}, ${db})`));
    }
  }
}

function webServerDevAction(options: {
  readonly port: number;
  readonly watch?: string[];
  readonly watchRecurse: boolean;
  readonly load?: string[];
  readonly externalSqlpage?: string;
  readonly externalSqlite3?: string;
  readonly restartWebServerOnChange: true;
  readonly showModifiedUrlsOnChange: boolean;
}) {
  const {
    port,
    load,
    externalSqlpage,
    restartWebServerOnChange,
    showModifiedUrlsOnChange,
  } = options;
  const db = DEV_DEFAULT_DB;

  // Determine the command and arguments
  const serverCommand = externalSqlpage
    ? ["sqlpage"]
    : ["surveilr", "web-ui", "--port", String(port)];
  const serverEnv = externalSqlpage
    ? {
      SQLPAGE_PORT: String(port),
      SQLPAGE_DATABASE_URL: `sqlite://${db}`,
    }
    : undefined;
  const serverFriendlyName = externalSqlpage ? `SQLPage` : `surveilr web-ui`;

  // Start the server process
  if (externalSqlpage) {
    console.log(cyan(`Starting standlone SQLPage server on port ${port}...`));
    console.log(brightYellow(`SQLPage server running with database: ${db}`));
  } else {
    console.log(
      cyan(`Starting surveilr web-ui on port ${port}...`),
    );
  }

  const baseUrl = `http://localhost:${port}`;
  console.log(
    dim(
      `Restart ${serverFriendlyName} on each change: ${restartWebServerOnChange}`,
    ),
  );
  console.log(brightYellow(`${baseUrl}/index.sql`));

  let webServerProcess: Deno.ChildProcess | null;
  const webServerService = {
    // deno-lint-ignore require-await
    start: async () => {
      if (webServerProcess) {
        if (!restartWebServerOnChange) return;
        console.log(
          brightRed(
            `⚠️ Unable start new ${serverFriendlyName}, process is already running.`,
          ),
        );
        return;
      }
      const serverCmd = new Deno.Command(serverCommand[0], {
        args: serverCommand.slice(1),
        env: serverEnv,
        stdout: "inherit",
        stderr: "inherit",
      });
      webServerProcess = serverCmd.spawn();
      console.log(
        dim(
          `👍 Started ${serverFriendlyName} process with PID ${webServerProcess.pid}`,
        ),
      );
    },

    stop: async () => {
      if (!restartWebServerOnChange) return;
      if (webServerProcess) {
        const existingPID = webServerProcess?.pid;
        webServerProcess?.kill("SIGINT");
        const { code } = await webServerProcess.status;
        webServerProcess = null;
        console.log(
          dim(
            `⛔ Stopped ${serverFriendlyName} process with PID ${existingPID}: ${code}`,
          ),
        );
      } else {
        console.log(
          brightRed(
            `Unable to stop ${serverFriendlyName} server, no process started.`,
          ),
        );
      }
    },
  };

  // Watch for changes in SQL and TS files and execute surveilr shell or sqlite3 on change
  const fromCwdToStdLib = relative(
    Deno.cwd(),
    fromFileUrl(import.meta.resolve("./")),
  );
  watchFiles(
    {
      paths: [
        // TODO: join(fromCwdToStdLib, "/models"),
        join(fromCwdToStdLib, "/notebook"),
        join(fromCwdToStdLib, "/web-ui-content"),
        join(fromCwdToStdLib, "/package.sql.ts"),
        ...options.watch ?? ["."],
      ],
      recursive: options.watchRecurse,
    },
    [/\.sql\.ts$/, /^(?!ERROR).*\.sql$/],
    db,
    load ?? ["package.sql.ts"],
    webServerService,
    showModifiedUrlsOnChange,
  );

  webServerService.start();
}

// deno-fmt-ignore so that commands defn is clearer
await new Command()
  .name("surveilrctl")
  .version("1.0.0")
  .description("Resource Surveillance (surveilr) controller")
  .command("dev", "Developer lifecycle and experience")
    .option("-p, --port <port:number>", "Port to run web server on", { default: DEV_DEFAULT_PORT })
    .option("-w, --watch <path:string>", "watch path(s)", { collect: true })
    .option("-R, --watch-recurse", "Watch subdirectories too", { default: false })
    .option("-l, --load <path:string>", "Load these whenever watched files modified (instead of watched files themselves), defaults to `package.sql.ts`", { collect: true })
    .option("--external-sqlpage <sqlpage-binary:string>", "Run standalone SQLPage instead of surveilr embedded")
    .option("--external-sqlite3 <sqlite3-binary:string>", "TODO: Run standalone sqlite3 instead of surveilr embedded Rusqlite")
    .option("--restart-web-server-on-change", "Restart the web server on each change, needed for surveir & SQLite", { default: true })
    .option("--show-modified-urls-on-change", "After reloading sqlpage_files, show the recently modified URLs", { default: false })
    .action(webServerDevAction)
  .parse(Deno.args ?? ["dev"]);
