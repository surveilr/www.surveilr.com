#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env --allow-run --allow-net

import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts"; 

// Function to generate the combined CGM tracing view SQL
export function generateCombinedCGMViewSQL(dbFilePath: string): string {
  const db = new Database(dbFilePath);

  // Fetch all participant tables
  const tablesStmt = db.prepare("SELECT name AS table_name  FROM sqlite_master  WHERE type = 'table' AND name LIKE 'uniform_resource_case__%'");
  const tables = tablesStmt.all();
  const sqlParts: string[] = [];

  // Loop through each table and generate the SQL for their CGM data
  for (const { table_name } of tables) {
    const participantId = table_name.split('__').pop(); // Extract participant ID from the table name

    // Generate SQL for each participant's CGM data
    sqlParts.push(`
      SELECT 
        '${participantId}' AS participant_id, 
        strftime('%Y-%m-%d %H:%M:%S', '2012-01-01 ' || hora) AS Date_Time,
        CAST(glucemia AS REAL) AS CGM_Value 
      FROM ${table_name}
    `);
    //providing default date since no date available in hora column within study
  }

  // Combine all parts into a single view SQL
  let combinedViewSQL = '';
  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(' UNION ALL ');
    combinedViewSQL = `CREATE VIEW combined_cgm_tracing AS ${combinedUnionAllQuery};`;
  } else {
    console.log("No participant tables found, so the combined view will not be created.");
  }

  db.close();
  
  return combinedViewSQL; // Return the SQL string instead of executing it
}
