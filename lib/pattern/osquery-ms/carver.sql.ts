#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-import
import { fromFileUrl } from "https://deno.land/std@0.224.0/path/mod.ts";
import { codeNB as cnb, RssdInitSqlNotebook } from "https://surveilr.com/lib/pattern/osquery-ms/deps.ts";

const osQueryMsNotebookName = "osQuery MS File Carve" as const;

function osQueryMsFileCarverQuery(
  init?: Omit<
    Parameters<typeof cnb.sqlCell>[0],
    "notebook_name" | "cell_governance"
  >,
  targets: string[] = ["darwin", "windows", "linux"],
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
  );
}

export class SurveilrOsqueryMsCarverQueries extends cnb.TypicalCodeNotebook {
  constructor() {
    super("rssd-init");
  }

  @osQueryMsFileCarverQuery(
    {
      description: "Get etc file system",
    },
    ["linux"],
    86400,
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