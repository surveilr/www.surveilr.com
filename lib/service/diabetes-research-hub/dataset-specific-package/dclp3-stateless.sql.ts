#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "../deps.ts";
import * as pkg from "../drh-basepackage.sql.ts";

export class dclp3SingleCGMSqlPages extends spn.TypicalSqlPageNotebook {
}

export async function dclp3SingleCGMSQL() {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelessDCLP3SQL() {
        // stateless SQL for DCLP3 Single CGM UVA Dataset
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "../study-specific-stateless/dclp3-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new dclp3SingleCGMSqlPages(),
  );
}

// this will be used by any callers who want to serve it as a CLI with SDTOUT
if (import.meta.main) {
  console.log((await dclp3SingleCGMSQL()).join("\n"));
}
