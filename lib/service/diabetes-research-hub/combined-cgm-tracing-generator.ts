import { DB } from "https://deno.land/x/sqlite/mod.ts";

// Path to your existing SQLite database
const dbFilePath = "resource-surveillance.sqlite.db";

// Open the existing database
const db = new DB(dbFilePath);
console.log(`Opened database: ${dbFilePath}`);

// Create error log table if it doesn't exist
db.execute(`
  CREATE TABLE IF NOT EXISTS error_log (
    errorLogId INTEGER PRIMARY KEY AUTOINCREMENT,
    datetime TEXT DEFAULT (datetime('now')),
    error_message TEXT
  );
`);

console.log("Error log table created or already exists.");

// Get the list of participant IDs from the view
const participants = db.query("SELECT DISTINCT patient_id FROM drh_participant_file_names;");

// Array to hold table names for the combined view
const tableNames: string[] = [];

for (const [patient_id_raw] of participants) {
  // Cast patient_id_raw to a string type
  const patient_id: string = patient_id_raw as string; 

  console.log(`Processing participant: ${patient_id}`);

  // Get the file names associated with the participant
  const [file_names_row] = db.query("SELECT file_names FROM drh_participant_file_names WHERE patient_id = ?", [patient_id]);
  if (!file_names_row) {
    console.log(`No file names found for participant ${patient_id}.`);
    continue;
  }

  const file_names = file_names_row[0];
  console.log(`File names for participant ${patient_id}: ${file_names}`);

  if (file_names) {
    // Construct table names
    const participantTableNames = file_names.split(', ').map(fileName => `uniform_resource_${fileName}`);
    tableNames.push(...participantTableNames); // Add participant's tables to the main array
  } else {
    console.log(`No file names found for participant ${patient_id}.`);
  }
}

// Create the combined view for all participants
if (tableNames.length > 0) {
  const combinedUnionAllQuery = tableNames.map(tableName =>
    `SELECT 
       '${tableName}' as participant_id, 
       strftime('%Y-%m-%d %H:%M:%S', date_time) as Date_Time, 
       CAST(CGM_Value as REAL) as CGM_Value 
     FROM ${tableName}`
  ).join(' UNION ALL ');

  const createCombinedViewSql = `CREATE VIEW IF NOT EXISTS combined_cgm_tracing AS ${combinedUnionAllQuery};`;

  console.log(`Creating combined view with SQL:\n${createCombinedViewSql}`);

  try {
    db.execute(createCombinedViewSql);
    console.log("Combined view 'combined_cgm_tracing' created successfully.");
  } catch (error) {
    console.error("Error creating combined view 'combined_cgm_tracing':", error);
    const sqlQuery = "INSERT INTO error_log (error_message) VALUES (?);";
    const params = JSON.stringify({ message: error.message });

    // Combine into a single string
    const combinedString = `${sqlQuery} Params: ${params}`;

    console.log(combinedString);

    // Insert error log as JSON
    db.execute(combinedString);
  }
} else {
  console.log("No participant tables found, so the combined view will not be created.");
}

// Close the database connection
db.close();
console.log(`Closed database: ${dbFilePath}`);
