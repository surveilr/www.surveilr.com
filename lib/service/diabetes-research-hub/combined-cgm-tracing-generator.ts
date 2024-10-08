import { DB } from "https://deno.land/x/sqlite/mod.ts";

// Function to create the combined CGM tracing view
export function createCombinedCGMView(dbFilePath: string): void {
  // Open the existing database
  const db = new DB(dbFilePath);
  //console.log(`Opened database: ${dbFilePath}`);

  // Create error log table if it doesn't exist
  db.execute(`
    CREATE TABLE IF NOT EXISTS error_log (
      errorLogId INTEGER PRIMARY KEY AUTOINCREMENT,
      datetime TEXT DEFAULT (datetime('now')),
      error_message TEXT
    );
  `);
  //console.log("Error log table created or already exists.");

  // Drop the view if it exists and create it
  try {
    db.execute(`DROP VIEW IF EXISTS drh_participant_file_names;`);
    db.execute(`
      CREATE VIEW  drh_participant_file_names AS
      SELECT
        patient_id,
        GROUP_CONCAT(file_name, ', ') AS file_names
      FROM
        uniform_resource_cgm_file_metadata
      GROUP BY
        patient_id;
    `);
    console.log("View 'drh_participant_file_names' created successfully.");
  } catch (error) {
    console.error("Error creating view 'drh_participant_file_names':", error);
    const sqlQuery = "INSERT INTO error_log (error_message) VALUES (?);";
    const params = JSON.stringify({ message: error.message });
    db.execute(sqlQuery, [params]);
    db.close();
    return;
  }

  // Get the list of participant IDs from the view
  const participants = db.query("SELECT DISTINCT patient_id FROM drh_participant_file_names;");

  // Array to hold SQL parts for the combined view
  const sqlParts: string[] = [];

  for (const [patient_id_raw] of participants) {
    const patient_id: string = patient_id_raw as string;

    const [file_names_row] = db.query("SELECT file_names FROM drh_participant_file_names WHERE patient_id = ?", [patient_id]);
    if (!file_names_row) {
      console.log(`No file names found for participant ${patient_id}.`);
      continue;
    }

    const file_names = file_names_row[0];
    if (file_names) {
      const participantTableNames = file_names.split(', ').map(fileName => `uniform_resource_${fileName}`);
      participantTableNames.forEach(tableName => {
        sqlParts.push(`
          SELECT 
            '${patient_id}' as participant_id, 
            strftime('%Y-%m-%d %H:%M:%S', date_time) as Date_Time, 
            CAST(CGM_Value as REAL) as CGM_Value 
          FROM ${tableName}
        `);
      });
    }
  }

  if (sqlParts.length > 0) {
    const combinedUnionAllQuery = sqlParts.join(' UNION ALL ');
    const createCombinedViewSql = `CREATE VIEW IF NOT EXISTS combined_cgm_tracing AS ${combinedUnionAllQuery};`;

    db.execute(createCombinedViewSql);
    console.log("Combined view 'combined_cgm_tracing' created successfully.");
  } else {
    console.log("No participant tables found, so the combined view will not be created.");
  }

  db.close();
  //console.log(`Closed database: ${dbFilePath}`);
}

// If the script is being run directly, execute the function
if (import.meta.main) {
  const dbFilePath = "resource-surveillance.sqlite.db"; 
  createCombinedCGMView(dbFilePath);
}
