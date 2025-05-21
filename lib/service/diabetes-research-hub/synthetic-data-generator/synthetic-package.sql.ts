#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";
import {
  generateMealFitnessandMetadataJson,
  saveJsonCgm,
} from "../study-specific-stateless/generate-cgm-combined-sql.ts";

export class syntheticSqlPages extends spn.TypicalSqlPageNotebook {
  // async savecgmSQL() {
  //     const dbFilePath = "./resource-surveillance.sqlite.db";
  //     const sqlStatements = saveJsonCgm(dbFilePath);
  //     return await sqlStatements;
  //   }

  //   async savemealDDL() {
  //       const dbFilePath = "./resource-surveillance.sqlite.db";
  //       const jsonstmts = generateMealFitnessandMetadataJson(dbFilePath);
  //       return await jsonstmts;
  //     }

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

export async function syntheticSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelessSyntheticSQL() {
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/synthetic-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new syntheticSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await syntheticSQL()).join("\n"));
}
