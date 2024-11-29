#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "./deps.ts";
import * as pkg from "./drh-basepackage.sql.ts";
import {
  createUVACombinedCGMViewSQL,
} from "./study-specific-stateless/generate-cgm-combined-sql.ts";

export class uvadclp1SqlPages extends spn.TypicalSqlPageNotebook {
  dclp1ViewDDL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const sqlStatements = createUVACombinedCGMViewSQL(dbFilePath);
    return this.SQL`
        ${sqlStatements} 
    `;
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

export async function uvadclp1SQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      // async uvaDDL() {
      //   // DDL for CTR3 Anderson (2016) Dataset
      //   return await super.combinedViewDDL();
      // }

      async statelessDCLP1SQL() {
        // stateless SQL for DCLP1 UVA Dataset
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/dclp1-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new uvadclp1SqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await uvadclp1SQL()).join("\n"));
}
