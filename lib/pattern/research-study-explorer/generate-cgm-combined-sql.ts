#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-net --allowffi

import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts";

// Common function to log errors into the database
function logError(db: Database, errorMessage: string): void {
  db.exec(`CREATE TABLE IF NOT EXISTS error_log (
    errorLogId INTEGER PRIMARY KEY AUTOINCREMENT,
    datetime TEXT DEFAULT (datetime('now')),
    error_message TEXT
  );`);

  const params = JSON.stringify({ message: errorMessage });
  db.prepare("INSERT INTO error_log (error_message) VALUES (?);").run(params);
}

// Function to create the initial view and return SQL for combined CGM tracing view (first dataset)
export function createUVACombinedCGMViewSQL(dbFilePath: string): string {
  const db = new Database(dbFilePath);

  // Check if the required table exists
  const tableName = "uniform_resource_cgm_file_metadata";
  const checkTableStmt = db.prepare(
    `SELECT name FROM sqlite_master WHERE type='table' AND name=?`,
  );
  const tableExists = checkTableStmt.get(tableName);

  if (!tableExists) {
    console.error(
      `The required table "${tableName}" does not exist. Cannot create the combined view.`,
    );
    db.close();
    return "";
  }

  try {
    // Execute the initial view
    db.exec(`DROP VIEW IF EXISTS drh_participant_file_names;`);
    db.exec(`
      CREATE VIEW drh_participant_file_names AS
      SELECT patient_id, GROUP_CONCAT(file_name, ', ') AS file_names
      FROM uniform_resource_cgm_file_metadata
      GROUP BY patient_id;
    `);
    //console.log("View 'drh_participant_file_names' created successfully.");
  } catch (error) {
    //console.error("Error creating view 'drh_participant_file_names':", error);
    logError(db, error.message);
    db.close();
    return "";
  }

  const participantsStmt = db.prepare(
    "SELECT DISTINCT patient_id FROM drh_participant_file_names;",
  );
  const participants = participantsStmt.all();

  const sqlParts: string[] = [];
  for (const { patient_id } of participants) {
    const fileNamesStmt = db.prepare(
      "SELECT file_names FROM drh_participant_file_names WHERE patient_id = ?;",
    );
    const file_names_row = fileNamesStmt.get(patient_id);

    if (!file_names_row) {
      //console.log(`No file names found for participant ${patient_id}.`);
      continue;
    }

    const file_names = file_names_row.file_names;
    if (file_names) {
      const participantTableNames = file_names.split(", ").map((fileName) =>
        `uniform_resource_${fileName}`
      );
      participantTableNames.forEach((tableName) => {
        sqlParts.push(`
          SELECT 
             'UVA001' as tenant_id,
            '${patient_id}' as participant_id, 
            strftime('%Y-%m-%d %H:%M:%S', date_time) as Date_Time, 
            CAST(CGM_Value as REAL) as CGM_Value 
          FROM ${tableName}
        `);
      });
    }
    fileNamesStmt.finalize();
  }

  let combinedViewSQL = "";
  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(" UNION ALL ");
    combinedViewSQL =
      `CREATE VIEW combined_cgm_tracing AS ${combinedUnionAllQuery};`;
  } else {
    //console.log("No participant tables found, so the combined view will not be created.");
  }

  participantsStmt.finalize();
  db.close();

  return combinedViewSQL; // Return the SQL string instead of executing it
}

// Function to generate the combined CGM tracing view SQL for the second dataset
export function generateDetrendedDSCombinedCGMViewSQL(
  dbFilePath: string,
): string {
  const db = new Database(dbFilePath);

  const tablesStmt = db.prepare(
    "SELECT name AS table_name FROM sqlite_master WHERE type = 'table' AND name LIKE 'uniform_resource_case__%'",
  );
  const tables = tablesStmt.all();
  const sqlParts: string[] = [];

  // Fetch the tenant_id from the party table (assuming it returns a single result)
  const tenantStmt = db.prepare(
    "SELECT party_id AS tenant_id FROM party LIMIT 1",
  );
  const tenantResult = tenantStmt.get();
  const tenantId = tenantResult ? tenantResult.tenant_id : "DFA001"; // Default to 'DFA001' if no tenant_id found

  const studyStmt = db.prepare(
    "select study_id from uniform_resource_study limit 1",
  );
  const studyResult = studyStmt.get();
  const studyId = studyResult ? studyResult.studyId : "DFA";

  // Loop through each table and generate the SQL for their CGM data
  for (const { table_name } of tables) {
    const participantId = table_name.split("__").pop(); // Extract participant ID from the table name

    // Generate SQL for each participant's CGM data
    sqlParts.push(`
      SELECT 
        '${tenantId}' as tenant_id,        
        'DFA' as study_id,
        TRIM('DFA-'||'${participantId}') AS participant_id, 
        strftime('%Y-%m-%d %H:%M:%S', hora ) AS Date_Time,
        CAST(glucemia AS REAL) AS CGM_Value 
      FROM ${table_name}
    `);
  }

  let combinedViewSQL = "";
  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(" UNION ALL ");
    combinedViewSQL =
      `CREATE VIEW combined_cgm_tracing AS ${combinedUnionAllQuery};`;
  } else {
    //console.log("No participant tables found, so the combined view will not be created.");
  }

  db.close();

  return combinedViewSQL; // Return the SQL string instead of executing it
}

// If the script is being run directly, execute the functions
if (import.meta.main) {
  const dbFilePath = "resource-surveillance.sqlite.db";

  // Run the first dataset view creation and get the SQL for combined view
  const dclp1combinedCGMViewSQL = createUVACombinedCGMViewSQL(dbFilePath);
  if (dclp1combinedCGMViewSQL) {
    console.log("Generated SQL for DCLP1 Study dataset:");
    console.log(dclp1combinedCGMViewSQL);
  }

  // Generate and log the SQL for the second dataset
  const detrendedDSCombinedCGMViewSQL = generateDetrendedDSCombinedCGMViewSQL(
    dbFilePath,
  );
  if (detrendedDSCombinedCGMViewSQL) {
    console.log("Generated SQL for detrended fluctuation analysis dataset:");
    console.log(detrendedDSCombinedCGMViewSQL);
  }
}
