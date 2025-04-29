#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { fromFileUrl } from "@std/path";
import { codeNB as cnb, RssdInitSqlNotebook } from "./deps.ts";

const osQueryMsNotebookName = "osQuery MS File Carve" as const;

function osQueryMsFileCarverQuery(
  init?: Omit<
    Parameters<typeof cnb.sqlCell>[0],
    "notebook_name" | "cell_governance"
  >,
  targets: string[] = ["macos", "windows", "linux"],
  osqueryMsInterval: number = 3600,
  postProcessCarved: "sqlite" | "capturable-executable" | "log-typical" =
    "sqlite",
  persistCarvedAsUR: boolean = true,
) {
  const cellGovernance = JSON.stringify({
    "osquery-ms-interval": osqueryMsInterval,
    targets,
    postProcessCarved,
    persistCarvedAsUR,
  });

  return cnb.sqlCell<RssdInitSqlNotebook>(
    {
      ...init,
      notebook_name: osQueryMsNotebookName,
      cell_governance: cellGovernance,
    },
    (dc, methodCtx) => {
      methodCtx.addInitializer(function () {
        this.migratableCells.set(String(methodCtx.name), dc);
      });
      return dc;
    },
  );
}

export class SurveilrOsqueryMsCarverQueries extends cnb.TypicalCodeNotebook {
  readonly migratableCells: Map<string, cnb.DecoratedCell<"SQL">> = new Map();

  constructor() {
    super("rssd-init");
  }

  @osQueryMsFileCarverQuery(
    {
      description: "Get etc file system",
    },
    ["linux"],
    60,
    "capturable-executable",
  )
  "/etc/passwd"() {
    return `
#!/bin/bash

# Read from STDIN and echo it so that it gets stored in the database;
# This is useful for testing the capturable executable context.
cat
    `;
  }

  // @osQueryMsFileCarverQuery(
  //   {
  //     description:
  //       "Transform /var/log/auth.log from each osQuery-MS node into a combined type-safe parsed table called osquery_ms_carved_var_log_auth_log",
  //   },
  //   ["linux"],
  //   60,
  //   "capturable-executable",
  // )
  // "/var/log/auth.log"() {
  //   return Deno.readTextFileSync(
  //     fromFileUrl(
  //       import.meta.resolve(
  //         "./carver-cap-exec/var-log-auth.log-transform-tabular.sh",
  //       ),
  //     ),
  //   );
  // }
}

export async function SQL() {
  return await cnb.TypicalCodeNotebook.SQL(
    new SurveilrOsqueryMsCarverQueries(),
  );
}

if (import.meta.main) {
  console.log((await SQL()).join("\n"));
}
