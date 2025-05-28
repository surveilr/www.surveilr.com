#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";
import {
  generateCombinedRTCCGMSQL,
  generateMealFitnessJson,generateMealFitnessandMetadataJson,
  savertccgmJsonCgm,
} from "../study-specific-stateless/generate-cgm-combined-sql.ts";
import { processCgmFiles } from "../study-specific-stateless/rtccgm-cgm-metadata-generator.ts";

export class rtccgmSqlPages extends spn.TypicalSqlPageNotebook {
  // async generatermetadataDDL() {
  //   const dbFilePath = "./resource-surveillance.sqlite.db";
  //   const result= await processCgmFiles(dbFilePath);
  //   return result;
  // }

  // async savertccgmDDL() {
  //     const dbFilePath = "./resource-surveillance.sqlite.db";
  //     const jsonstmts = await savertccgmJsonCgm(dbFilePath);
  //     return jsonstmts;
  // }

  // savemealDDL() {
  //         const dbFilePath = "./resource-surveillance.sqlite.db";
  //         const jsonstmts = generateMealFitnessandMetadataJson(dbFilePath);
  //         return jsonstmts;
  //       }

  rtccgmViewDDL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const sqlStatements = generateCombinedRTCCGMSQL(dbFilePath);
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

export async function rtccgmSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async rtccgmDDL() {
        // stateless SQL for CTR3 Anderson (2016) Dataset
        //return await super.combinedViewDDL(),
      }

      async statelessRTGCGMSQL() {
        // stateless SQL
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/rtccgm-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new rtccgmSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await rtccgmSQL()).join("\n"));
}
