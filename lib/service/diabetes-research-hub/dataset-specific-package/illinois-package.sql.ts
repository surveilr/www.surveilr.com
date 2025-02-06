#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";
import {
  checkAndConvertToVsp,
  createCommonCombinedCGMViewSQL,
  saveJsonCgm,
} from "../study-specific-stateless/generate-cgm-combined-sql.ts";

export class illinoisSqlPages extends spn.TypicalSqlPageNotebook {
  async statelessvsvSQL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const sqlStatements = checkAndConvertToVsp(dbFilePath);
    return await sqlStatements;
  }
  async savecgmSQL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const sqlStatements = saveJsonCgm(dbFilePath);
    return await sqlStatements;
  }
  commonViewDDL() {
    const dbFilePath = "./resource-surveillance.sqlite.db";
    const sqlStatements = createCommonCombinedCGMViewSQL(dbFilePath);
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

export async function illinoisSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelessillinoisSQL() {
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/illinois-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new illinoisSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await illinoisSQL()).join("\n"));
}
