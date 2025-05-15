#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";
import {
  generateMealFitnessJson,
  saveJsonCgm,
} from "../study-specific-stateless/generate-cgm-combined-sql.ts";

export class HupaSingleCGMSqlPages extends spn.TypicalSqlPageNotebook {
  // async savecgmSQL() {
  //   const dbFilePath = "./resource-surveillance.sqlite.db";
  //   const sqlStatements = saveJsonCgm(dbFilePath);
  //   return await sqlStatements;
  // }

  // savemealDDL() {
  //   const dbFilePath = "./resource-surveillance.sqlite.db";
  //   const jsonstmts = generateMealFitnessJson(dbFilePath);
  //   return jsonstmts;
  // }
}

export async function hupaSingleCGMSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelessHUPASQL() {
        // stateless SQL for HUPA Single CGM Dataset
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/hupa-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new HupaSingleCGMSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await hupaSingleCGMSQL()).join("\n"));
}
