#!/usr/bin/env -S deno run --allow-run --allow-env --allow-net --allow-read --allow-write

import { debounce } from "https://deno.land/std@0.224.0/async/debounce.ts";
import {
  brightGreen,
  brightRed,
  brightWhite,
  brightYellow,
  cyan,
  dim,
  green,
  red,
} from "https://deno.land/std@0.224.0/fmt/colors.ts";
import {
  fromFileUrl,
  isAbsolute,
  join,
  relative,
} from "https://deno.land/std@0.224.0/path/mod.ts";
import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.4/command/mod.ts";
import { spawnedResult } from "../universal/spawn.ts";

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
  stateDbFsPath: string,
  load: string[] | undefined,
  service: {
    readonly stop?: () => Promise<void>;
    readonly start?: () => Promise<void>;
  },
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

    const surveilrRelPath = (path: string) => {
      const result = relative(Deno.cwd(), path);
      return result.startsWith("../") ? result : `./${result}`;
    };

    const spawnedSurveilr = async (...args: string[]) => {
      console.log(dim(`🚀 surveilr shell ${args.join(" ")}`));
      const sr = await spawnedResult([
        "surveilr",
        "shell",
        "--state-db-fs-path",
        stateDbFsPath,
        ...args,
      ]);
      if (sr.code == 0) {
        console.log(dim(`✅`), brightGreen(sr.command.join(" ")), green(`[${sr.code}]`));
      } else {
        // if you change the name of this file, update watchFiles(...) call and gitignore
        console.log(dim(`❌`), brightRed(sr.command.join(" ")), red(`[${sr.code}]`));
      }
      const stdOut = sr.stdout().trim();
      if (stdOut.length) console.log(dim(stdOut));
      const stdErr = sr.stdout().trim();
      if (stdErr.length) console.log(brightRed(stdErr));
      return sr;
    };

    const reload = debounce(async (event: Deno.FsEvent) => {
      for (const path of event.paths) {
        for (const file of files) {
          if (file.test(path)) {
            // deno-fmt-ignore
            console.log(dim(`👀 Watch event (${event.kind}): ${brightWhite(relative(".", path))}`));
            await service.stop?.();
            if (load?.length) {
              // instead of the file that's being modified we want to load a
              // different (set) of files (usually package.sql.ts)
              await spawnedSurveilr(
                ...load.map((l) =>
                  surveilrRelPath(isAbsolute(l) ? l : join(Deno.cwd(), l))
                ),
              );
            } else {
              // no custom loaders passed in, just reload the file that was modified
              await spawnedSurveilr(surveilrRelPath(path));
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
      console.log(
        brightRed(`watchFiles issue: ${error} (${files}, ${stateDbFsPath})`),
      );
    }
  }
}

async function webServerDevAction(options: {
  readonly stateDbFsPath: string;
  readonly port: number;
  readonly watch?: string[];
  readonly watchRecurse: boolean;
  readonly load?: string[];
  readonly externalSqlpage?: string;
  readonly externalSqlite3?: string;
  readonly restartWebServerOnChange: true;
}) {
  const {
    stateDbFsPath,
    port,
    load,
    externalSqlpage,
    restartWebServerOnChange,
  } = options;

  console.log(dim(
    `Using ${
      cyan((await spawnedResult(["surveilr", "--version"])).stdout())
    } RSSD ${cyan(stateDbFsPath)}`,
  ));

  // Determine the command and arguments
  const serverCommand = externalSqlpage
    ? ["sqlpage"]
    : ["surveilr", "web-ui", "--port", String(port)];
  const serverEnv = externalSqlpage
    ? {
      SQLPAGE_PORT: String(port),
      SQLPAGE_DATABASE_URL: `sqlite://${stateDbFsPath}`,
    }
    : undefined;
  const serverFriendlyName = externalSqlpage ? `SQLPage` : `surveilr web-ui`;

  // Start the server process
  if (externalSqlpage) {
    console.log(cyan(`Starting standlone SQLPage server on port ${port}...`));
    console.log(
      brightYellow(`SQLPage server running with database: ${stateDbFsPath}`),
    );
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
    stateDbFsPath,
    load ?? ["package.sql.ts"],
    webServerService,
  );

  webServerService.start();
}

const DEV_DEFAULT_PORT = 9000;
const DEV_DEFAULT_DB = Deno.env.get("SURVEILR_STATEDB_FS_PATH") ??
  "resource-surveillance.sqlite.db";

// deno-fmt-ignore so that commands defn is clearer
await new Command()
  .name("surveilrctl")
  .version("1.0.0")
  .description("Resource Surveillance (surveilr) controller")
  .command("dev", "Developer lifecycle and experience")
    .option("-d, --state-db-fs-path <rssd:string>", "target SQLite database [env: SURVEILR_STATEDB_FS_PATH=]", { default: DEV_DEFAULT_DB})
    .option("-p, --port <port:number>", "Port to run web server on", { default: DEV_DEFAULT_PORT })
    .option("-w, --watch <path:string>", "watch path(s)", { collect: true })
    .option("-R, --watch-recurse", "Watch subdirectories too", { default: false })
    .option("-l, --load <path:string>", "Load these whenever watched files modified (instead of watched files themselves), defaults to `package.sql.ts`", { collect: true })
    .option("--external-sqlpage <sqlpage-binary:string>", "Run standalone SQLPage instead of surveilr embedded")
    .option("--restart-web-server-on-change", "Restart the web server on each change, needed for surveir & SQLite", { default: true })
    .action(webServerDevAction)
  .parse(Deno.args ?? ["dev"]);
