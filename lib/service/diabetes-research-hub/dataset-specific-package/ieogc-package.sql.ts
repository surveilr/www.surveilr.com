#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";
import { processIEOGCgm } from "../study-specific-stateless/ieogc-ingest-data-sql.ts";
import {
  generateMealFitnessJson,generateMealFitnessandMetadataJson,
  saveJsonCgm,
} from "../study-specific-stateless/generate-cgm-combined-sql.ts";

export class ieogcSqlPages extends spn.TypicalSqlPageNotebook {
  savecgmDDL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const jsonstmts = processIEOGCgm(dbFilePath);
    return jsonstmts;
  }

  savemealDDL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const jsonstmts = generateMealFitnessandMetadataJson(dbFilePath);
    return jsonstmts;
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

export async function ieogcSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelessieogcSQL() {
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/ieogc-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new ieogcSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await ieogcSQL()).join("\n"));
}
