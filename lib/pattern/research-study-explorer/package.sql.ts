#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "./deps.ts";
import * as pkg from "./drh-basepackage.sql.ts";

export class dclp1SingleCGMSqlPages extends spn.TypicalSqlPageNotebook {
  // Metrics static views will be generated after the combined_cgm_tracing is created.
  async statelessMetricsSQL() {
    return await spn.TypicalSqlPageNotebook.fetchText(
      import.meta.resolve("./drh-metrics.sql"),
    );
  }

  async statelessMetricsExplanationSQL() {
    return await spn.TypicalSqlPageNotebook.fetchText(
      import.meta.resolve("./metrics-explanation-dml.sql"),
    );
  }
}

export async function dclp1SingleCGMSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelessDCLP1SQL() {
        // stateless SQL for DCLP1 Single CGM UVA Dataset
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "./stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new dclp1SingleCGMSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await dclp1SingleCGMSQL()).join("\n"));
}
