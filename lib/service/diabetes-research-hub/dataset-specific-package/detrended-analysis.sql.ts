#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";
import {
  generateDetrendedDSCombinedCGMViewSQL,generateMealFitnessandMetadataJson,
  generateMealFitnessJson,
  saveDFAJsonCgm,
} from "../study-specific-stateless/generate-cgm-combined-sql.ts";

export class detrendedSqlPages extends spn.TypicalSqlPageNotebook {
  savecgmDDL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const jsonstmts = saveDFAJsonCgm(dbFilePath);
    return jsonstmts;
  }

  savemealDDL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const jsonstmts = generateMealFitnessandMetadataJson(dbFilePath);
    return jsonstmts;
  }

  detrendedViewDDL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const sqlStatements = generateDetrendedDSCombinedCGMViewSQL(dbFilePath);
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

export async function detrendedSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async detrendedDDL() {
        // stateless SQL for CTR3 Anderson (2016) Dataset
        //return await super.combinedViewDDL(),
      }

      async statelessDetrendedColasSQL() {
        // stateless SQL for Colas 2019 detrended Dataset
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/detrended-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new detrendedSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await detrendedSQL()).join("\n"));
}
