#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-sys --allow-ffi
import { sqlPageNB as spn } from "./deps.ts";
import * as pkg from "./drh-basepackage.sql.ts";
import {
  checkAndConvertToVsp,
  createCommonCombinedCGMViewSQL,
  saveJsonCgm,
} from "./study-specific-stateless/generate-cgm-combined-sql.ts";

// Class to manage SQL page with dbFilePath as a constructor parameter
export class uvadclp1SqlPages extends spn.TypicalSqlPageNotebook {
  private dbFilePath: string;

  // Constructor to accept dbFilePath
  constructor(dbFilePath: string) {
    super(); // Call the parent class constructor
    this.dbFilePath = dbFilePath; // Store dbFilePath as a class member
  }

  async statelessvsvSQL() {
    // console.error(`The database path is  "${this.dbFilePath}"`);
    const sqlStatements = checkAndConvertToVsp(this.dbFilePath);
    return await sqlStatements;
  }
  async savecgmSQL() {
    const sqlStatements = saveJsonCgm(this.dbFilePath);
    return await sqlStatements;
  }
  // Method to generate DDL view using the dbFilePath
  dclp1ViewDDL() {
    console.error(`The database path is  "${this.dbFilePath}"`);

    // Use the dbFilePath in the SQL function
    const sqlStatements = createCommonCombinedCGMViewSQL(this.dbFilePath);

    // Return the SQL with the dynamic content
    return this.SQL`
      ${sqlStatements}
    `;
  }

  // Metrics static views will be generated after the combined_cgm_tracing is created.
  async statelessMetricsSQL() {
    return await spn.TypicalSqlPageNotebook.fetchText(
      import.meta.resolve("./drh-metrics.sql"),
    );
  }

  async statelessMetricsExplanationSQL() {
    return await spn.TypicalSqlPageNotebook.fetchText(
      import.meta.resolve("./metrics-explanation-dml.sql"),
    );
  }
}

// Update the uvadclp1SQL function to accept the dbFilePath as a parameter
export async function uvadclp1SQL(dbFilePath: string) {
  return await spn.TypicalSqlPageNotebook.SQL(
    new class extends pkg.DRHSqlPages {
      async statelessDCLP1SQL() {
        return await spn.TypicalSqlPageNotebook.fetchText(
          import.meta.resolve(
            "./study-specific-stateless/illinois-stateless.sql",
          ),
        );
      }
    }(),
    ...(await pkg.drhNotebooks()),
    new uvadclp1SqlPages(dbFilePath), // Create an instance of the page class with the dbFilePath
  );
}

// This will be used by any callers who want to serve it as a CLI with STDOUT
if (import.meta.main) {
  const dbFilePath = Deno.args[0] || "./resource-surveillance.sqlite.db"; // Get db path from command line args or default path

  // Check if the provided file exists
  if (!await Deno.stat(dbFilePath).catch(() => false)) {
    console.error("The specified DB file does not exist.");
    Deno.exit(1);
  }

  // Output the SQL result
  console.log((await uvadclp1SQL(dbFilePath)).join("\n"));
}
