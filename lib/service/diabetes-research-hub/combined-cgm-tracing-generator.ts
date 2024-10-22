import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts";

// Function to create the combined CGM tracing view
export function createCombinedCGMView(dbFilePath: string): void {
  const db = new Database(dbFilePath);

  db.exec(`CREATE TABLE IF NOT EXISTS error_log (
    errorLogId INTEGER PRIMARY KEY AUTOINCREMENT,
    datetime TEXT DEFAULT (datetime('now')),
    error_message TEXT
  );`);

  try {
    db.exec(`DROP VIEW IF EXISTS drh_participant_file_names;`);
    db.exec(`
      CREATE VIEW drh_participant_file_names AS
      SELECT patient_id, GROUP_CONCAT(file_name, ', ') AS file_names
      FROM uniform_resource_cgm_file_metadata
      GROUP BY patient_id;
    `);
    console.log("View 'drh_participant_file_names' created successfully.");
  } catch (error) {
    console.error("Error creating view 'drh_participant_file_names':", error);
    const params = JSON.stringify({ message: error.message });
    db.prepare("INSERT INTO error_log (error_message) VALUES (?);").run(params);
    db.close();
    return;
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
      console.log(`No file names found for participant ${patient_id}.`);
      continue;
    }

    const file_names = file_names_row.file_names; // Access property directly
    if (file_names) {
      const participantTableNames = file_names.split(", ").map((fileName) =>
        `uniform_resource_${fileName}`
      );
      participantTableNames.forEach((tableName) => {
        sqlParts.push(`
          SELECT 
            '${patient_id}' as participant_id, 
            strftime('%Y-%m-%d %H:%M:%S', date_time) as Date_Time, 
            CAST(CGM_Value as REAL) as CGM_Value 
          FROM ${tableName}
        `);
      });
    }
    fileNamesStmt.finalize(); // Clean up
  }

  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(" UNION ALL ");
    const createCombinedViewSql =
      `CREATE VIEW IF NOT EXISTS combined_cgm_tracing AS ${combinedUnionAllQuery};`;

    try {
      db.exec(createCombinedViewSql);
      console.log("Combined view 'combined_cgm_tracing' created successfully.");
    } catch (error) {
      console.error("Error creating combined view:", error);
      const params = JSON.stringify({ message: error.message });
      db.prepare("INSERT INTO error_log (error_message) VALUES (?);").run(
        params,
      );
    }
  } else {
    console.log(
      "No participant tables found, so the combined view will not be created.",
    );
  }

  participantsStmt.finalize(); // Clean up
  db.close();
}

// If the script is being run directly, execute the function
if (import.meta.main) {
  const dbFilePath = "resource-surveillance.sqlite.db";
  createCombinedCGMView(dbFilePath);
}
