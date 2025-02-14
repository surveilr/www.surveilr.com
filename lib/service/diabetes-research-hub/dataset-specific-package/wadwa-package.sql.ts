#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";
import { saveJsonCgm } from "../study-specific-stateless/generate-cgm-combined-sql.ts";

export class wadaSqlPages extends spn.TypicalSqlPageNotebook {
  async savecgmSQL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const sqlStatements = saveJsonCgm(dbFilePath);
    return await sqlStatements;
  }
  //metrics static views shall be generated after the combined_cgm_tracing is created.
  async statelessMetricsSQL() {
    // stateless SQL for the metrics
    return await spn.TypicalSqlPageNotebook.fetchText(
      import.meta.resolve(
        "../drh-metrics.sql",
      ),
    );
  }

  async statelessMetricsExplanationSQL() {
    // Metrics explanations to be displayed in Hover Menu
    return await spn.TypicalSqlPageNotebook.fetchText(
      import.meta.resolve(
        "../metrics-explanation-dml.sql",
      ),
    );
  }
}

export async function wadwaSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelesswadaSQL() {
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/wadwa-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new wadaSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await wadwaSQL()).join("\n"));
}
