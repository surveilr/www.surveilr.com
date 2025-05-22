#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";


export class glucdictSqlPages extends spn.TypicalSqlPageNotebook {  
  //metrics static views shall be generated after the combined_cgm_tracing is created.
  /* async statelessMetricsSQL() {
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
  } */
}

export async function glucdictSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelessglucdictSQL() {
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/glucdict-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new glucdictSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await glucdictSQL()).join("\n"));
}


