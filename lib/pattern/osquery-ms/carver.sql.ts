#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys
import { fromFileUrl } from "https://deno.land/std@0.224.0/path/mod.ts";
import { codeNB as cnb, RssdInitSqlNotebook } from "https://surveilr.com/lib/pattern/osquery-ms/deps.ts";

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
      // Using arrow function to preserve context
      methodCtx.addInitializer(() => {
        // Get access to the instance via closure instead of thisValue
        // Store in a global registry that can be accessed later
        const methodName = String(methodCtx.name); // Explicit conversion to string
        
        // Access the instance using the global registry approach
        // This is a workaround since we can't directly access the instance
        if (globalRegistry.instance) {
          globalRegistry.instance.migratableCells.set(methodName, dc);
        } else {
          console.error(`Error: No instance available for ${methodName}`);
        }
      });
      // we're not modifying the DecoratedCell
      return dc;
    },
  );
}

// Create a global registry to store the class instance
// This is a workaround for the decorator context limitations
const globalRegistry: { 
  instance: SurveilrOsqueryMsCarverQueries | null 
} = { 
  instance: null 
};

export class SurveilrOsqueryMsCarverQueries extends cnb.TypicalCodeNotebook {
  // Initialize this immediately to avoid undefined issues
  readonly migratableCells: Map<string, cnb.DecoratedCell<"SQL">> = new Map();

  constructor() {
    super("rssd-init");
    // Register this instance in the global registry
    globalRegistry.instance = this;
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